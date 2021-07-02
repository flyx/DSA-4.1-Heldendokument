package main

import (
	"bytes"
	"context"
	"io/ioutil"
	"log"
	"net/http"
	"os"
	"os/exec"
	"os/signal"
	"strconv"
	"strings"
	"syscall"

	"golang.org/x/net/websocket"
)

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

	file, err := ioutil.ReadFile("index.html")
	if err != nil {
		panic(err)
	}
	w.Header().Add("Content-Type", "text/html;charset=utf-8")
	w.WriteHeader(200)
	w.Write(file)
}

func template(w http.ResponseWriter, req *http.Request) {
	file, err := ioutil.ReadFile("templates/" + req.URL.Path[1:] + ".lua")
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

	xsltproc := exec.Command("/usr/bin/xsltproc", "import.xsl", "-")
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
	setupRAMdisk()
	srv := &http.Server{Addr: ":80"}
	log.Println("Starting server")
	go worker(srv)
	http.HandleFunc("/", index)
	http.HandleFunc("/index.html", index)
	http.Handle("/process", websocket.Handler(buildPdf))
	http.HandleFunc("/import", importHeld)
	http.HandleFunc("/profan", template)
	http.HandleFunc("/geweiht", template)
	http.HandleFunc("/magier", template)
	srv.ListenAndServe()
}

func setupRAMdisk() {
	log.Println("Setting up RAM disk…")
	create := exec.Command("mount", "-t", "tmpfs", "-o", "size=64M", "tmpfs", "/ramdisk")
	if err := create.Run(); err != nil {
		log.Println("Cannot initialize RAM disk, running from normal storage")
		log.Println("  to run on a RAM disk, call docker run with --privileged.")
		return
	}
	cp := exec.Command("cp", "-a", "/heldendokument/.", "/ramdisk/")
	if err := cp.Run(); err != nil {
		panic("while copying to ramdisk: " + err.Error())
	}
	if err := os.Chdir("/ramdisk"); err != nil {
		panic("while chdir to ramdisk: " + err.Error())
	}
	log.Println("Running on RAM disk.")
}

func wsHandler(c *websocket.Conn) {
	go buildPdf(c)
}

func sendWithStatus(c *websocket.Conn, status byte, content []byte) {
	content = append(content, status)
	if err := websocket.Message.Send(c, content); err != nil {
		os.Stderr.WriteString("While sending to websocket: " + err.Error() + "\n")
	}
	c.Close()
}

type ProgressChecker struct {
	c   *websocket.Conn
	cur byte
}

func (p *ProgressChecker) Write(b []byte) (n int, err error) {
	str := string(b)
	if strings.Contains(str, "Latexmk: applying rule 'lualatex'...") {
		p.cur += 25
		payload := []byte{p.cur, 0}
		websocket.Message.Send(p.c, payload)
	}
	return len(b), nil
}

func buildPdf(c *websocket.Conn) {
	var input string
	if err := websocket.Message.Receive(c, &input); err != nil {
		os.Stderr.WriteString("websocket error: " + err.Error() + "\n")
		c.Close()
		return
	}
	held := exec.Command("/bin/sh", "held.sh")
	held.Stdin = strings.NewReader(input)
	held.Stdout = &ProgressChecker{c, 0}
	if err := held.Start(); err != nil {
		panic(err)
	}
	if err := held.Wait(); err != nil {
		log, _ := ioutil.ReadFile("src/heldendokument.log")
		sendWithStatus(c, 1, log)
	} else {
		pdf, _ := ioutil.ReadFile("src/heldendokument.pdf")
		sendWithStatus(c, 2, pdf)
	}
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
