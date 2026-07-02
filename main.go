package main

import (
	"fmt"
	"net/http"
	"time"
	"encoding/json"
	"os"
	"runtime"
)

var startTime = time.Now()

func main() {

	// 1. Static files (HTML, JS, CSS)
	fs := http.FileServer(http.Dir("./www"))
	http.Handle("/", fs)

	// 2. endpoint for fetching date and time
	http.HandleFunc("/api/time", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "text/plain")
		fmt.Fprint(w, time.Now().UTC().Format(time.RFC3339))
	})

	http.HandleFunc("/api/info", func(w http.ResponseWriter, r *http.Request) {
		var mem runtime.MemStats
		runtime.ReadMemStats(&mem)

		hostname, _ := os.Hostname()

		info := map[string]interface{}{
			"hostname": hostname,
			"uptime":   time.Since(startTime).String(),
			"go":       runtime.Version(),
			"cpu":      runtime.NumCPU(),
			"os":       runtime.GOOS,
			"arch":     runtime.GOARCH,
			"alloc_mb": mem.Alloc / 1024 / 1024,
			"sys_mb":   mem.Sys / 1024 / 1024,
		}

		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(info)
	})

	http.HandleFunc("/api/surprise", func(w http.ResponseWriter, r *http.Request) {
		name := r.URL.Query().Get("name")
		if name == "" {
			name = "mysterious user"
		}
		var message = "You have been selected as today’s official cloud administrator of imaginary servers"
		w.Header().Set("Content-Type", "application/json")

    		json.NewEncoder(w).Encode(map[string]string{
        		"name":    name,
        		"message": message,
    		})
	})

	fmt.Println("Server running on :8082")
	if err := http.ListenAndServe(":8082", nil); err != nil {
	fmt.Println("Server error:", err)
	}
}
