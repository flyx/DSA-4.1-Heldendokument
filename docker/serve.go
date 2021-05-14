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
	"syscall"
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

type result struct {
	success bool
	output  []byte
}

type request struct {
	input      []byte
	resultChan chan result
}

var requests chan request

func process(w http.ResponseWriter, req *http.Request) {
	if req.Method != "POST" {
		w.WriteHeader(http.StatusMethodNotAllowed)
		return
	}
	if err := req.ParseForm(); err != nil {
		w.WriteHeader(http.StatusBadRequest)
		w.Write([]byte(err.Error()))
		return
	}
	input := req.Form.Get("data")
	if input == "" {
		w.WriteHeader(http.StatusBadRequest)
		w.Write([]byte(`missing or empty data in request!`))
		return
	}

	resultChan := make(chan result, 1)
	requests <- request{
		input:      []byte(input),
		resultChan: resultChan,
	}
	result := <-resultChan
	if result.success {
		w.Header().Add("Content-Type", "application/pdf")
		w.Header().Add("Content-Transfer-Encoding", "binary")
		w.Header().Add("Content-Disposition", "attachment; filename=heldendokument.pdf")
		w.Header().Add("Content-Length", strconv.Itoa(len(result.output)))
		w.WriteHeader(200)
		w.Write(result.output)
	} else {
		w.Header().Add("Content-Type", "text/plain;charset=utf-8")
		w.Header().Add("Content-Length", strconv.Itoa(len(result.output)))
		w.WriteHeader(400)
		w.Write(result.output)
	}
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

func main() {
	setupRAMdisk()
	requests = make(chan request, 10)
	srv := &http.Server{Addr: ":80"}
	log.Println("Starting server")
	go worker(srv)
	http.HandleFunc("/", index)
	http.HandleFunc("/index.html", index)
	http.HandleFunc("/process", process)
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

func worker(srv *http.Server) {
	done := make(chan os.Signal, 1)
	signal.Notify(done, os.Interrupt, syscall.SIGINT, syscall.SIGTERM)
	for {
		select {
		case req := <-requests:
			held := exec.Command("/bin/sh", "held.sh")
			held.Stdin = bytes.NewReader(req.input)
			if err := held.Start(); err != nil {
				panic(err)
			}
			if err := held.Wait(); err != nil {
				log, _ := ioutil.ReadFile("src/heldendokument.log")
				req.resultChan <- result{
					success: false, output: log,
				}
			} else {
				pdf, _ := ioutil.ReadFile("src/heldendokument.pdf")
				req.resultChan <- result{
					success: true, output: pdf,
				}
			}
		case <-done:
			srv.Shutdown(context.Background())
			umount := exec.Command("umount", "/ramdisk")
			umount.Run()
			return
		}
	}
}
