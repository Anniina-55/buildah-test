package main

import (
	"fmt"
	"net/http"
	"time"
)

func main() {

	// 1. Static files (HTML, JS, CSS)
	fs := http.FileServer(http.Dir("./www"))
	http.Handle("/", fs)

	// 2. Interaktiivinen endpoint
	http.HandleFunc("/api/time", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintf(w, "Server time: %s", time.Now().Format(time.RFC3339))
	})

	// 3. Simple input example
	http.HandleFunc("/api/hello", func(w http.ResponseWriter, r *http.Request) {
		name := r.URL.Query().Get("name")
		if name == "" {
			name = "world"
		}
		fmt.Fprintf(w, "Hello %s!", name)
	})

	fmt.Println("Server running on :8082")
	http.ListenAndServe(":8082", nil)
}
