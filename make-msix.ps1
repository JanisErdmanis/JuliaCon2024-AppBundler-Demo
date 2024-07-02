param (
    [string]$APPDIR
)


New-Alias -Name makeappx -Value "C:\Program Files (x86)\Windows Kits\10\bin\10.0.20348.0\x64\makeappx.exe"
New-Alias -Name signtool -Value "C:\Program Files (x86)\Windows Kits\10\bin\10.0.20348.0\x64\signtool.exe"
New-Alias -Name editbin -Value "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Tools\MSVC\14.37.32822\bin\Hostx64\x64\editbin.exe"

$APPDIR = $APPDIR.TrimEnd('\')
$APP = Split-Path $APPDIR -Leaf
$DATE = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$TMPDIR = "$env:TEMP\$APP-$DATE"

# Necessary whne MAC folder is used in Parallelis Desktop
Write-Host "INFO: Copying to $TMPDIR"
Copy-Item -Path $APPDIR -Destination $TMPDIR -Recurse

Write-Host "INFO: Precompiling"
& "$TMPDIR\precompile.ps1"

if (Test-Path "$APPDIR\debug") {
    Write-Host "INFO: Debug mode detected"
}else{
    Write-Host "INFO: Changing subsystem for executables"
    editbin /SUBSYSTEM:WINDOWS "$TMPDIR\julia\bin\lld.exe"
    editbin /SUBSYSTEM:WINDOWS "$TMPDIR\julia\bin\julia.exe"
}

Write-Host "INFO: Forming MSIX archive $APPDIR.msix"

$MSIX = "$APPDIR.msix"

if (Test-Path $MSIX) {
    Remove-Item $MSIX
}

makeappx pack /d "$TMPDIR" /p "$MSIX" > $null

Write-Host "INFO: Signing MSIX archive"
signtool sign /fd SHA256 /a /f "SigningKey.pfx" /p "YourPassword" "$MSIX"
