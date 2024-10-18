# get the path of the current powershell script
$scriptPath = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent

write-output $scriptPath

# cross-computer-file-link.exe is in ..\..\bin\

$exePath = "$scriptPath\..\..\bin\cross-computer-file-link.exe"


# create a shortcut to shell:startup
$shortcutPath = "$env:USERPROFILE\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\cross-computer-file-link.lnk"
$targetPath = "$exePath"
$arguments = ""
$description = "cross-computer-file-link"
$iconLocation = "$targetPath, 0"
$workingDirectory = "$scriptPath\..\..\bin\"

# # Create the shortcut
$shell = New-Object -ComObject WScript.Shell
$shortcut = $shell.CreateShortcut($shortcutPath)
$shortcut.TargetPath = $targetPath
$shortcut.Arguments = $arguments
$shortcut.Description = $description
$shortcut.IconLocation = $iconLocation
$shortcut.WorkingDirectory = $workingDirectory
$shortcut.Save()



# open shell:startup folder so user can see the shortcut
explorer "$env:USERPROFILE\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup"
