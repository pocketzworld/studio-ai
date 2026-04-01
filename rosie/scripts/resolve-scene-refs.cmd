:; exec bash "$(dirname "$0")/resolve-scene-refs.sh" "$@"
@echo off
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0resolve-scene-refs.ps1" %1
exit /b %ERRORLEVEL%
