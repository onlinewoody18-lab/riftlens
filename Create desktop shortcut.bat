@echo off
rem Puts a RiftLens shortcut (with its icon) on your desktop and in the Start menu.
cd /d "%~dp0"
if not exist "server\index.js" (
  echo Extract the zip first, then run this file from the extracted riftlens folder.
  pause
  exit /b
)
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$w = New-Object -ComObject WScript.Shell;" ^
  "foreach ($dir in @([Environment]::GetFolderPath('Desktop'), [Environment]::GetFolderPath('Programs'))) {" ^
  "  $s = $w.CreateShortcut((Join-Path $dir 'RiftLens.lnk'));" ^
  "  $s.TargetPath = (Join-Path '%~dp0' 'Start RiftLens.bat');" ^
  "  $s.WorkingDirectory = '%~dp0';" ^
  "  $s.IconLocation = (Join-Path '%~dp0' 'riftlens.ico');" ^
  "  $s.WindowStyle = 7;" ^
  "  $s.Description = 'RiftLens';" ^
  "  $s.Save() }"
if errorlevel 1 (
  echo Couldn't create the shortcut.
) else (
  echo Done. RiftLens is now on your desktop and in the Start menu.
)
pause
