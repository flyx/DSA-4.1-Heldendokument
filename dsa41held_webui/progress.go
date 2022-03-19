package main

import (
	"bytes"
	"strings"
	
	"golang.org/x/net/websocket"
)

type ProgressState int

const (
	InitialState ProgressState = iota
	FileListStartedState
	AwaitingNextRun
	ProgressReportState
)

type ProgressChecker struct {
	state		ProgressState
	c				*websocket.Conn
	cur			byte
	fileList []string
	builder	strings.Builder
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