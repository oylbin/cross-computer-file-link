package main

import (
	"fmt"
	"net/http"
	"os"
	"os/exec"
	"os/user"
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
	// current process username
	username, err := user.Current()
	if err != nil {
		http.Error(w, "Unable to determine current user", http.StatusInternalServerError)
		return
	}

	if runtime.GOOS == "windows" {
		homeDir = strings.ReplaceAll(homeDir, "\\", "\\\\")
	}
	// Serve a simple HTML page with a form and JavaScript for URL conversion and clipboard copying
	fmt.Fprintf(w, `
		<html>
		<body>
			<input type="text" id="path" placeholder="Enter local file path" style="width: 300px; height: 30px; font-size: 16px;" onfocus="this.select();" onkeypress="if(event.keyCode==13) convertAndCopy();" />
			<button onclick="convertAndCopy()">Convert and Copy</button>
			<p>Home: %s</p>
			<p>Username: %s</p>
			<p id="status"></p>
	`, homeDir, username.Username)
	fmt.Fprint(w, `<script>
			function customEncodeURI(uri) {
					// return uri.replace(/[^A-Za-z0-9\-_.!~*'();/?:@&=+$,#]+/g, function(c) {
					// 	return encodeURIComponent(c);
					// });
					return uri.replace(/[ #&%?]/g, function(c) {
						return encodeURIComponent(c);
					});
			}
	`)
	fmt.Fprintf(w, `
				function convertAndCopy() {
					var localPath = document.getElementById('path').value;
					var homeDir = "%s";
					var relativePath = localPath.replace(homeDir, '').replace(/\\/g, '/');
					// var encodedPath = encodeURIComponent(relativePath); 会把 / 也进行编码，不太好看
					// var encodedPath = encodeURI(relativePath); 不会把 / 编码，但是仍然会把中文进行编码。
					var encodedPath = customEncodeURI(relativePath);
					var url = "http://localhost:10114/redirect" + encodedPath;
					navigator.clipboard.writeText(url).then(function() {
						document.getElementById('status').innerHTML = '<a href="' + url + '" target="_blank">URL copied to clipboard: ' + url + '</a>';
					}, function(err) {
						document.getElementById('status').textContent = 'Could not copy text: ' + err;
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
	// current process username
	username, err := user.Current()
	if err != nil {
		http.Error(w, "Unable to determine current user", http.StatusInternalServerError)
		return
	}
	fmt.Println("username:", username.Username)
	fmt.Println("localPath:", localPath)
	openFile(localPath)
	fmt.Fprintf(w, `
		<html>
		<body>
			<p>Opening file: %s</p>
			<p>This window may not be automatically closed. You may close it manually.</p>
			<script>
				setTimeout(function() {
					window.close();
				}, 5000);
			</script>
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
	// run and get the return code
	err := cmd.Run()
	if err != nil {
		fmt.Println("Error opening file:", err)
	}
}
