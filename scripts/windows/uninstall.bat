@REM exit if nssm_win64.exe is in PATH
where nssm_win64.exe >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo "Error: nssm_win64.exe not found in PATH"
    TIMEOUT /T 5
    exit /b 1
)

nssm_win64.exe stop cross-computer-file-link
nssm_win64.exe remove cross-computer-file-link confirm
TIMEOUT /T 5

