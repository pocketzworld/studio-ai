:; exec bash "$(dirname "$0")/check-version.sh" "$@"
@echo off
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0check-version.ps1" %1
exit /b %ERRORLEVEL%
