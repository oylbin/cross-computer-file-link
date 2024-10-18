OS ?= $(shell uname -s)
ifeq ($(OS), Windows_NT)
ifneq ($(shell where uname 2>NUL),)
	# git bash for windows 中存在 uname 命令
	RUNNING_IN_WINDOWS_CMD := false
else
	# cmd 或 powershell 中不存在 uname 命令
	RUNNING_IN_WINDOWS_CMD := true
endif
else
	RUNNING_IN_WINDOWS_CMD := false
endif

.PHONY: build test clean install uninstall status env

env:
	@echo "OS: $(OS)"
	@echo "RUNNING_IN_WINDOWS_CMD: $(RUNNING_IN_WINDOWS_CMD)"

build:
	-mkdir bin
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
ifeq ($(OS), Windows_NT)
	echo $(RUNNING_IN_WINDOWS_CMD)
ifeq ($(RUNNING_IN_WINDOWS_CMD), true)
	powershell -ExecutionPolicy Bypass -File scripts/windows/install.ps1
else
	echo "please run this command in cmd or powershell"
	exit 1
endif
endif

uninstall:
ifeq ($(OS), Darwin)
	-launchctl unload ~/Library/LaunchAgents/com.oylbin.cross-computer-file-link.plist
	-rm ~/Library/LaunchAgents/com.oylbin.cross-computer-file-link.plist
	-sudo rm /usr/local/bin/cross-computer-file-link
endif
ifeq ($(OS), Windows_NT)
	echo $(RUNNING_IN_WINDOWS_CMD)
ifeq ($(RUNNING_IN_WINDOWS_CMD), true)
	powershell -ExecutionPolicy Bypass -File scripts/windows/uninstall.ps1
else
	echo "please run this command in cmd or powershell"
	exit 1
endif
endif

status:
ifeq ($(OS), Darwin)
	launchctl list | grep com.oylbin.cross-computer-file-link
endif
ifeq ($(OS), Windows_NT)
	powershell -ExecutionPolicy Bypass -File scripts/windows/status.ps1
endif
