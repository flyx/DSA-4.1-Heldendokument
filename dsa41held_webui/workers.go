package main

import (
	"bytes"
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	
	"golang.org/x/net/websocket"
)

type Worker struct {
	workdir string
}

func (w *Worker) init(workdir string) {
	w.workdir = workdir
}

func (w *Worker) run(c chan processingRequest) {
	for {
		request := <-c
		if request.c == nil {
			break
		}
		defer func() {
			if err := recover(); err != nil {
				sendWithStatus(request.c, 1, []byte(fmt.Sprint("error while building PDF:", err)))
			}
		}()
		w.buildPdf(request.c)
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

func (w *Worker) buildPdf(c *websocket.Conn) {
	_, white := c.Config().Location.Query()["white"]
	
	var input []byte
	if err := websocket.Message.Receive(c, &input); err != nil {
		os.Stderr.WriteString("websocket error: " + err.Error() + "\n")
		c.Close()
		return
	}
	
	var baseDir string
	if w.workdir == "" {
		baseDir = os.TempDir()
	} else {
		baseDir = w.workdir
	}
	dir, err := ioutil.TempDir(baseDir, "heldendokument-")
	if err != nil {
		panic(err)
	}
	defer os.RemoveAll(dir)
	
	{
		f, err := os.Create(filepath.Join(dir, "held.lua"))
		if err != nil {
			os.Stderr.WriteString("error while writing held.lua: " + err.Error() + "\n")
			c.Close()
			return
		}
		if _, err := f.Write(input); err != nil {
			os.Stderr.WriteString("error while writing held.lua: " + err.Error() + "\n")
			c.Close()
			f.Close()
			return
		}
		f.Close()
	}
	
	validate := exec.Command("dsa41held", "validate", "held.lua")
	checker := ProgressChecker{InitialState, c, 0, nil, strings.Builder{}, 0, "", bytes.Buffer{}}
	validate.Stdout = &checker
	validate.Stderr = &checker
	validate.Dir = dir
	if err := validate.Start(); err != nil {
		panic(err)
	}
	if err := validate.Wait(); err != nil {
		log.Printf("error while validating input: %s\n", err.Error())
		sendWithStatus(c, 1, checker.fullOutput.Bytes())
	}
	
	var held *exec.Cmd
	if white {
		held = exec.Command("dsa41held", "pdf", "-w", "held.lua")
	} else {
		held = exec.Command("dsa41held", "pdf", "held.lua")
	}
	held.Stdout = &checker
	held.Stderr = &checker
	held.Dir = dir
	if err := held.Start(); err != nil {
		panic(err)
	}
	if err := held.Wait(); err != nil {
		log.Printf("error while processing: %s\n", err.Error())
		sendWithStatus(c, 1, checker.fullOutput.Bytes())
	} else {
		pdf, _ := ioutil.ReadFile(filepath.Join(dir, "held.pdf"))
		sendWithStatus(c, 2, pdf)
	}
}