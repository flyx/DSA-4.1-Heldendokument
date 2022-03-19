package main

import (
	"bytes"
	"context"
	_ "embed"
	"io/ioutil"
	"mime/multipart"
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

func expectData(w http.ResponseWriter, req *http.Request) (content []byte,
	header *multipart.FileHeader, ok bool) {
	if req.Method != "POST" {
		w.WriteHeader(http.StatusMethodNotAllowed)
		return nil, nil, false
	}
	if err := req.ParseMultipartForm(32 << 20); err != nil {
		w.WriteHeader(http.StatusBadRequest)
		w.Write([]byte(err.Error()))
		return nil, nil, false
	}
	var err error
	var file multipart.File
	file, header, err = req.FormFile("data")
	if err != nil {
		w.WriteHeader(http.StatusBadRequest)
		w.Write([]byte(err.Error()))
		return nil, nil, false
	}
	content, err = ioutil.ReadAll(file)
	if err != nil {
		w.WriteHeader(http.StatusBadRequest)
		w.Write([]byte(err.Error()))
		return nil, nil, false
	}
	ok = true
	return
}

func importHeld(w http.ResponseWriter, req *http.Request) {
	input, header, ok := expectData(w, req)
	if !ok {
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
		name := strings.TrimSuffix(header.Filename, filepath.Ext(header.Filename))
		res := stdout.Bytes()
		w.Header().Add("Content-Type", "text/x-lua")
		w.Header().Add(
			"Content-Disposition", "attachment; filename=\"" + name + ".lua\"")
		w.Header().Add("Content-Length", strconv.Itoa(len(res)))
		w.WriteHeader(200)
		w.Write(res)
	}
}

func calcEvents(w http.ResponseWriter, req *http.Request) {
	input, _, ok := expectData(w, req)
	if !ok {
		return
	}
	proc := exec.Command("dsa41held", "ereignisse", "/dev/stdin")
	proc.Stdin = bytes.NewReader(input)
	var stdout, stderr bytes.Buffer
	proc.Stdout = &stdout
	proc.Stderr = &stderr
	if err := proc.Start(); err != nil {
		panic(err)
	}
	if err := proc.Wait(); err != nil {
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

func signalHandler(srv *http.Server) {
	done := make(chan os.Signal, 1)
	signal.Notify(done, os.Interrupt, syscall.SIGINT, syscall.SIGTERM)
	for {
		select {
		case <-done:
			srv.Shutdown(context.Background())
			return
		}
	}
}
