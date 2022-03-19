package main

import (
	"flag"
	"log"
	"net/http"
	"os"
	"path/filepath"
	
	"golang.org/x/net/websocket"
)

func main() {
	srcDir, err := os.Executable()
	if err != nil {
		panic(err)
	}
	data = filepath.Join(filepath.Dir(filepath.Dir(srcDir)), "share")
	
	num_threads := flag.Int("threads", 5, "Anzahl threads, mit denen gleichzeitig Dokumente erstellt werden können")
	addr := flag.String("addr", ":80", "Netwerkadresse, an der der Server binden soll (gemäß Go http Modul)")
	workdir := flag.String("workdir", "", "Basis-Verzeichnis, in dem gearbeitet wird. Kann auf einer RAM-Disk liegen, um Festplattenzugriffe zu vermeiden. Falls leer, wird ein temporäres Verzeichnis benutzt.")
	flag.Parse()
	if len(flag.Args()) > 0 {
		log.Fatal("unerwarteter Parameter: " + flag.Arg(0))
	}

	rqChannel = make(chan processingRequest)
	workers := make([]Worker, *num_threads, *num_threads)
	for i := 0; i < *num_threads; i++ {
		workers[i].init(*workdir)
		go workers[i].run(rqChannel)
	}

	srv := &http.Server{Addr: *addr}
	log.Println("Starting server at " + *addr)
	go signalHandler(srv)
	http.HandleFunc("/", index)
	http.HandleFunc("/index.html", index)
	http.Handle("/process", websocket.Handler(wsHandler))
	http.HandleFunc("/import", importHeld)
	http.HandleFunc("/events", calcEvents)
	http.HandleFunc("/profan", template)
	http.HandleFunc("/geweiht", template)
	http.HandleFunc("/magier", template)
	srv.ListenAndServe()
}