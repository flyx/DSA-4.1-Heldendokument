package main

import (
	"bytes"
	"context"
	_ "embed"
	"flag"
	"io/ioutil"
	"log"
	"net/http"
	"os"
	"os/exec"
	"os/signal"
	"path/filepath"
	"strconv"
	"strings"
	"syscall"

	"golang.org/x/net/websocket"
)

type processingRequest struct {
	c        *websocket.Conn
	finished chan struct{}
}

var rqChannel chan processingRequest

var data string

func index(w http.ResponseWriter, req *http.Request) {
	if req.Method != "GET" {
		w.WriteHeader(http.StatusMethodNotAllowed)
		return
	}

	if req.URL.Path != "/" && req.URL.Path != "/index.html" {
		w.WriteHeader(http.StatusNotFound)
		w.Write([]byte("404 File not found: " + req.URL.Path))
		return
	}

	file, err := ioutil.ReadFile(filepath.Join(data, "index.html"))
	if err != nil {
		panic(err)
	}
	w.Header().Add("Content-Type", "text/html;charset=utf-8")
	w.WriteHeader(200)
	w.Write(file)
}

func template(w http.ResponseWriter, req *http.Request) {
	file, err := ioutil.ReadFile(filepath.Join(data, "templates", req.URL.Path[1:]+".lua"))
	if err != nil {
		panic(err)
	}
	w.Header().Add("Content-Type", "text/plain;charset=utf-8")
	w.Header().Add("Content-Length", strconv.Itoa(len(file)))
	w.WriteHeader(200)
	w.Write(file)
}

func importHeld(w http.ResponseWriter, req *http.Request) {
	if req.Method != "POST" {
		w.WriteHeader(http.StatusMethodNotAllowed)
		return
	}
	if err := req.ParseMultipartForm(32 << 20); err != nil {
		w.WriteHeader(http.StatusBadRequest)
		w.Write([]byte(err.Error()))
		return
	}
	file, _, err := req.FormFile("data")
	if err != nil {
		w.WriteHeader(http.StatusBadRequest)
		w.Write([]byte(err.Error()))
		return
	}
	input, err := ioutil.ReadAll(file)
	if err != nil {
		w.WriteHeader(http.StatusBadRequest)
		w.Write([]byte(err.Error()))
		return
	}

	xsltproc := exec.Command("xsltproc", filepath.Join(data, "import.xsl"), "-")
	xsltproc.Stdin = bytes.NewReader(input)
	var stdout, stderr bytes.Buffer
	xsltproc.Stdout = &stdout
	xsltproc.Stderr = &stderr
	if err := xsltproc.Start(); err != nil {
		panic(err)
	}
	if err := xsltproc.Wait(); err != nil {
		res := stderr.Bytes()
		w.Header().Add("Content-Type", "text/plain")
		w.Header().Add("Content-Length", strconv.Itoa(len(res)))
		w.WriteHeader(400)
		w.Write(res)
	} else {
		res := stdout.Bytes()
		w.Header().Add("Content-Type", "text/x-lua")
		w.Header().Add("Content-Length", strconv.Itoa(len(res)))
		w.WriteHeader(200)
		w.Write(res)
	}
}

func main() {
	srcDir, err := os.Executable()
	if err != nil {
		panic(err)
	}
	data = filepath.Join(filepath.Dir(filepath.Dir(srcDir)), "share")
	
	num_threads := flag.Int("threads", 5, "Anzahl threads, mit denen gleichzeitig Dokumente erstellt werden können")
	flag.Parse()
	if len(flag.Args()) > 0 {
		log.Fatal("unerwarteter Parameter: " + flag.Arg(0))
	}

	var baseDir string
	if setupRAMdisk() {
		baseDir = "/ramdisk/"
	} else {
		baseDir = os.TempDir()
	}

	rqChannel = make(chan processingRequest)
	processors := make([]Processor, *num_threads, *num_threads)
	for i := 0; i < *num_threads; i++ {
		dir, err := ioutil.TempDir(baseDir, "heldendokument-")
		if err != nil {
			log.Fatal(err.Error())
		}
		log.Println("starting processor in " + dir)
		processors[i].init(dir)
		go processors[i].run(rqChannel)
	}
	defer func() {
		for _, p := range processors {
			os.RemoveAll(p.dir)
		}
	}()

	srv := &http.Server{Addr: ":80"}
	log.Println("Starting server")
	go worker(srv)
	http.HandleFunc("/", index)
	http.HandleFunc("/index.html", index)
	http.Handle("/process", websocket.Handler(wsHandler))
	http.HandleFunc("/import", importHeld)
	http.HandleFunc("/profan", template)
	http.HandleFunc("/geweiht", template)
	http.HandleFunc("/magier", template)
	srv.ListenAndServe()
}

func setupRAMdisk() bool {
	log.Println("Setting up RAM disk…")
	create := exec.Command("mount", "-t", "tmpfs", "-o", "size=64M", "tmpfs", "/ramdisk")
	if err := create.Run(); err != nil {
		log.Println("Cannot initialize RAM disk, running from normal storage")
		log.Println("  to run on a RAM disk, call docker run with --privileged.")
		return false
	}
	log.Println("Running on RAM disk.")
	return true
}

type Processor struct {
	dir string
}

func (p *Processor) init(dir string) {
	p.dir = dir
}

func (p *Processor) run(c chan processingRequest) {
	for {
		request := <-c
		if request.c == nil {
			break
		}
		p.buildPdf(request.c)
		request.finished <- struct{}{}
	}
}

func wsHandler(c *websocket.Conn) {
	resp := make(chan struct{})
	select {
	case rqChannel <- processingRequest{c, resp}:
		_ = <-resp
		break
	default:
		sendWithStatus(c, 3, []byte{})
	}
}

func sendWithStatus(c *websocket.Conn, status byte, content []byte) {
	content = append(content, status)
	if err := websocket.Message.Send(c, content); err != nil {
		os.Stderr.WriteString("While sending to websocket: " + err.Error() + "\n")
	}
	c.Close()
}

func (p *Processor) buildPdf(c *websocket.Conn) {
	var input string
	if err := websocket.Message.Receive(c, &input); err != nil {
		os.Stderr.WriteString("websocket error: " + err.Error() + "\n")
		c.Close()
		return
	}
	
	{
		f, err := os.Create(filepath.Join(p.dir, "held.lua"))
		if err != nil {
			os.Stderr.WriteString("error while writing held.lua: " + err.Error() + "\n")
			c.Close()
			return
		}
		if _, err := f.WriteString(input); err != nil {
			os.Stderr.WriteString("error while writing held.lua: " + err.Error() + "\n")
			c.Close()
			f.Close()
			return
		}
		f.Close()
	}
	
	held := exec.Command("dsa41held", "held.lua")
	checker := ProgressChecker{InitialState, c, 0, nil, strings.Builder{}, 0, "", bytes.Buffer{}}
	held.Stdout = &checker
	held.Stderr = &checker
	held.Dir = p.dir
	if err := held.Start(); err != nil {
		panic(err)
	}
	if err := held.Wait(); err != nil {
		log.Printf("error while processing: %s\n", err.Error())
		sendWithStatus(c, 1, checker.fullOutput.Bytes())
	} else {
		pdf, _ := ioutil.ReadFile(filepath.Join(p.dir, "held.pdf"))
		sendWithStatus(c, 2, pdf)
	}
}

type ProgressState int

const (
	InitialState ProgressState = iota
	FileListStartedState
	AwaitingNextRun
	ProgressReportState
)

type ProgressChecker struct {
	state    ProgressState
	c        *websocket.Conn
	cur      byte
	fileList []string
	builder  strings.Builder
	nextFile byte
	trailing string
	fullOutput bytes.Buffer
}

func (p *ProgressChecker) Write(b []byte) (n int, err error) {
	p.fullOutput.Write(b)
	str := p.trailing + string(b)
	for {
		switch p.state {
		case InitialState:
			index := strings.Index(str, "---\n")
			if index != -1 {
				str = str[index+4:]
				p.state = FileListStartedState
				continue
			}
		case FileListStartedState:
			index := strings.Index(str, "---\n")
			if index != -1 {
				p.builder.WriteString(str[:index])
				p.fileList = strings.Split(p.builder.String(), "\n")
				if len(p.fileList[len(p.fileList)-1]) == 0 {
					p.fileList = p.fileList[:len(p.fileList)-1]
				}
				str = str[index+4:]
				p.state = AwaitingNextRun
				continue
			}
			p.builder.WriteString(str)
		case AwaitingNextRun:
			if index := strings.Index(str, "Latexmk: applying rule 'lualatex'..."); index != -1 {
				p.nextFile = 0
				p.state = ProgressReportState
				payload := []byte{p.cur, 0}
				websocket.Message.Send(p.c, payload)
				str = str[index+len("Latexmk: applying rule 'lualatex'..."):]
				continue
			}
		case ProgressReportState:
			if index := strings.Index(str, p.fileList[p.nextFile]); index != -1 {
				var percentage byte = p.cur + 33*(p.nextFile+1)/byte(len(p.fileList)+1)
				payload := []byte{percentage, 0}
				websocket.Message.Send(p.c, payload)
				str = str[index+len(p.fileList[p.nextFile]):]
				p.nextFile += 1
				if p.nextFile == byte(len(p.fileList)) {
					p.state = AwaitingNextRun
					p.cur = p.cur + 33
				}
				continue
			}
		}
		break
	}

	if len(str) < 20 {
		p.trailing = str
	} else {
		p.trailing = str[len(str)-20:]
	}
	return len(b), nil
}

func worker(srv *http.Server) {
	done := make(chan os.Signal, 1)
	signal.Notify(done, os.Interrupt, syscall.SIGINT, syscall.SIGTERM)
	for {
		select {
		case <-done:
			srv.Shutdown(context.Background())
			umount := exec.Command("umount", "/ramdisk")
			umount.Run()
			return
		}
	}
}
