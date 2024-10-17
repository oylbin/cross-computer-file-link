OS ?= $(shell uname -s)

.PHONY: build test clean

build:
	mkdir -p bin
ifeq ($(OS), Windows_NT)
	go build -ldflags="-H=windowsgui" -o bin/cross-computer-file-link.exe main.go
else
	go build -o bin/cross-computer-file-link main.go
endif

test:
	bin/cross-computer-file-link

clean:
	rm -rf bin


install:
ifeq ($(OS), Darwin)
	sudo cp bin/cross-computer-file-link /usr/local/bin/
	cp scripts/macOS/com.oylbin.cross-computer-file-link.plist ~/Library/LaunchAgents/
	launchctl load ~/Library/LaunchAgents/com.oylbin.cross-computer-file-link.plist
endif

uninstall:
ifeq ($(OS), Darwin)
	-launchctl unload ~/Library/LaunchAgents/com.oylbin.cross-computer-file-link.plist
	-rm ~/Library/LaunchAgents/com.oylbin.cross-computer-file-link.plist
	-sudo rm /usr/local/bin/cross-computer-file-link
endif

status:
ifeq ($(OS), Darwin)
	launchctl list | grep com.oylbin.cross-computer-file-link
endif
