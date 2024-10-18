# kill the process
taskkill /f /im cross-computer-file-link.exe

# remove the shortcut
rm "$env:USERPROFILE\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\cross-computer-file-link.lnk"

