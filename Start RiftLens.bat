@echo off
title RiftLens
cd /d "%~dp0"
if not exist "server\index.js" (
  echo.
  echo  RiftLens is being run from inside the zip file.
  echo  Right-click RiftLens.zip, choose "Extract All...", then open the
  echo  extracted riftlens folder and double-click "Start RiftLens.bat" there.
  echo.
  pause
  exit /b
)
where node >nul 2>nul
if errorlevel 1 (
  echo Node.js isn't installed. Download the LTS version from https://nodejs.org, install it, then run this file again.
  start https://nodejs.org
  pause
  exit /b
)
rem RiftLens opens in its own window once the server is ready. Closing this window stops RiftLens.
set RIFTLENS_OPEN=1
node server\index.js
pause
