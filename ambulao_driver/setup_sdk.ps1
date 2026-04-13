$ErrorActionPreference = "Stop"
$sdkPath = "$env:LOCALAPPDATA\Android\Sdk"
$cmdlineToolsPath = "$sdkPath\cmdline-tools"
$zipPath = "$env:TEMP\cmdline-tools.zip"
$zipUrl = "https://dl.google.com/android/repository/commandlinetools-win-11076708_latest.zip"

Write-Host "Creating SDK directories..."
New-Item -ItemType Directory -Force -Path $cmdlineToolsPath | Out-Null

Write-Host "Downloading Android SDK Command-line Tools via curl..."
curl.exe -L -o $zipPath $zipUrl

Write-Host "Extracting Command-line Tools..."
Expand-Archive -Path $zipPath -DestinationPath $cmdlineToolsPath -Force

Write-Host "Renaming folder to 'latest'..."
$extractedFolder = "$cmdlineToolsPath\cmdline-tools"
$latestFolder = "$cmdlineToolsPath\latest"
if (Test-Path $latestFolder) {
    Remove-Item -Recurse -Force $latestFolder
}
Rename-Item -Path $extractedFolder -NewName "latest"

Write-Host "Installed cmdline-tools."
