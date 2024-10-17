package main

import (
	"fmt"
	"net/http"
	"os"
	"os/exec"
	"path/filepath"
	"runtime"
	"strings"
)

func main() {
	http.HandleFunc("/", homeHandler)
	http.HandleFunc("/redirect/", redirectHandler)
	http.ListenAndServe(":10114", nil)
}

func homeHandler(w http.ResponseWriter, r *http.Request) {
	homeDir, err := os.UserHomeDir()
	if err != nil {
		http.Error(w, "Unable to determine home directory", http.StatusInternalServerError)
		return
	}

	if runtime.GOOS == "windows" {
		homeDir = strings.ReplaceAll(homeDir, "\\", "\\\\")
	}
	// Serve a simple HTML page with a form and JavaScript for URL conversion and clipboard copying
	fmt.Fprintf(w, `
		<html>
		<body>
			<input type="text" id="path" placeholder="Enter local file path" />
			<button onclick="convertAndCopy()">Convert and Copy</button>
			<script>
				function convertAndCopy() {
					var localPath = document.getElementById('path').value;
					var homeDir = "%s";
					var relativePath = localPath.replace(homeDir, '').replace(/\\/g, '/');
					var url = "http://localhost:10114/redirect" + relativePath;
					navigator.clipboard.writeText(url).then(function() {
						alert('URL copied to clipboard: ' + url);
					}, function(err) {
						console.error('Could not copy text: ', err);
					});
				}
			</script>
		</body>
		</html>
	`, homeDir)
}

func redirectHandler(w http.ResponseWriter, r *http.Request) {
	homeDir, _ := os.UserHomeDir()
	relativePath := strings.TrimPrefix(r.URL.Path, "/redirect/")
	if runtime.GOOS == "windows" {
		relativePath = strings.ReplaceAll(relativePath, "/", "\\")
	}
	localPath := filepath.Join(homeDir, relativePath)
	fmt.Println(localPath)
	openFile(localPath)
	fmt.Fprintf(w, `
		<html>
		<body>
			<p>Opening file: %s</p>
			<p>This window cannot be automatically closed. You may close it manually.</p>
		</body>
		</html>
	`, localPath)
}

func openFile(path string) {
	var cmd *exec.Cmd
	switch runtime.GOOS {
	case "windows":
		cmd = exec.Command("cmd", "/c", "start", "", path)
	case "darwin":
		cmd = exec.Command("open", path)
	case "linux":
		cmd = exec.Command("xdg-open", path)
	}
	cmd.Start()
}
