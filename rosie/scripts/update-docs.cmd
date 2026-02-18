:; exec bash "$(dirname "$0")/update-docs.sh" "$@"
@echo off
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0update-docs.ps1" %1
exit /b %ERRORLEVEL%
