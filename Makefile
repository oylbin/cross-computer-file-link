OS ?= $(shell uname -s)

ifeq ($(OS), Windows_NT)
	EXT = .exe
else
	EXT =
endif

.PHONY: build test clean install uninstall status start stop

build:
	mkdir -p bin
	go build -ldflags="-H=windowsgui" -o bin/cross-computer-file-link$(EXT) main.go

test:
	bin/cross-computer-file-link$(EXT)

clean:
	rm -rf bin
