@REM exit if nssm_win64.exe is in PATH
where nssm_win64.exe >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo "Error: nssm_win64.exe not found in PATH"
    TIMEOUT /T 5
    exit /b 1
)


cd %~dp0
cd ..\..\
set current_dir=%cd%

@echo current_dir: %current_dir%

@REM check if cross-computer-file-link.exe exists
if not exist %current_dir%\bin\cross-computer-file-link.exe (
    echo "Error: cross-computer-file-link.exe not found"
    TIMEOUT /T 5
    exit /b 1
)

nssm_win64.exe install cross-computer-file-link %current_dir%\bin\cross-computer-file-link.exe
nssm_win64.exe set cross-computer-file-link AppDirectory %current_dir%
nssm_win64.exe set cross-computer-file-link AppStdout %current_dir%\stdout.log
nssm_win64.exe set cross-computer-file-link AppStderr %current_dir%\stderr.log
nssm_win64.exe set cross-computer-file-link AppNoConsole 1
nssm_win64.exe set cross-computer-file-link Start SERVICE_AUTO_START
nssm_win64.exe set cross-computer-file-link AppThrottle 1500
nssm_win64.exe set cross-computer-file-link AppExit Default Restart
nssm_win64.exe set cross-computer-file-link AppRestartDelay 0

@REM ask user for username and password
set /p USERNAME=Enter username: 
set /p USERPASSWORD=Enter password: 

nssm_win64.exe set cross-computer-file-link ObjectName  .\%USERNAME% %USERPASSWORD%
TIMEOUT /T 5
