$ErrorActionPreference = "Stop"
$sdkmanager = "$env:LOCALAPPDATA\Android\Sdk\cmdline-tools\latest\bin\sdkmanager.bat"

Write-Host "Accepting all SDK licenses..."
1..100 | ForEach-Object { "y" } | & $sdkmanager --licenses

Write-Host "Installing platform-tools, platforms;android-34, build-tools;34.0.0..."
1..100 | ForEach-Object { "y" } | & $sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0"

Write-Host "Accepting flutter licenses..."
1..100 | ForEach-Object { "y" } | flutter doctor --android-licenses

flutter doctor -v
