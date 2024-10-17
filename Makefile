OS ?= $(shell uname -s)

ifeq ($(OS), Windows_NT)
	EXT = .exe
	PWD := $(shell cd)
	ifeq ($(SHELL),sh.exe)
		RUNNING_IN_WINDOWS_CMD := true
	else
		RUNNING_IN_WINDOWS_CMD := false
	endif
else
	EXT =
	PWD := $(shell pwd)
	RUNNING_IN_WINDOWS_CMD := false
endif


build:
	mkdir -p bin
	go build -o bin/cross-computer-file-link$(EXT) main.go

run:
	go run main.go

clean:
	rm -rf bin

install:
ifeq ($(OS), Windows_NT)
ifeq ($(RUNNING_IN_WINDOWS_CMD), true)
	@echo "Note: Creating a Windows service requires administrative privileges."
	@echo "Please run this command from an administrator Command Prompt or PowerShell."
	@scripts\windows\install.bat
else
	@echo "Creating a Windows service requires administrative privileges."
	@echo "Please run this command from an administrator Command Prompt or PowerShell."
	exit 1
endif
else ifeq ($(OS), Linux)

else ifeq ($(OS), Darwin)

endif

uninstall:
ifeq ($(OS), Windows_NT)
ifeq ($(RUNNING_IN_WINDOWS_CMD), true)
	@echo "Note: Creating a Windows service requires administrative privileges."
	@echo "Please run this command from an administrator Command Prompt or PowerShell."
	@scripts\windows\uninstall.bat
else
	@echo "Creating a Windows service requires administrative privileges."
	@echo "Please run this command from an administrator Command Prompt or PowerShell."
	exit 1
endif
else ifeq ($(OS), Linux)

else ifeq ($(OS), Darwin)

endif


status:
ifeq ($(OS), Windows_NT)
ifeq ($(RUNNING_IN_WINDOWS_CMD), true)
	@echo "Note: Creating a Windows service requires administrative privileges."
	@echo "Please run this command from an administrator Command Prompt or PowerShell."
	@scripts\windows\status.bat
else
	@echo "Creating a Windows service requires administrative privileges."
	@echo "Please run this command from an administrator Command Prompt or PowerShell."
	exit 1
endif
else ifeq ($(OS), Linux)
	#sudo systemctl status cross-computer-file-link
else ifeq ($(OS), Darwin)
	#sudo launchctl status cross-computer-file-link
endif

start:
ifeq ($(OS), Windows_NT)
	@scripts\windows\start.bat
else ifeq ($(OS), Linux)

else ifeq ($(OS), Darwin)

endif

stop:
ifeq ($(OS), Windows_NT)
	@scripts\windows\stop.bat
else ifeq ($(OS), Linux)

else ifeq ($(OS), Darwin)

endif

