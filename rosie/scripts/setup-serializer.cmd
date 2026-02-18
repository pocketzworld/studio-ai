:; exec bash "$(dirname "$0")/setup-serializer.sh" "$@"
@echo off
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0setup-serializer.ps1" %1
exit /b %ERRORLEVEL%
