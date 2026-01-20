#!/bin/bash

# Focus the Unity editor window
# This brings Unity to the foreground so it can process pending changes

case "$(uname -s)" in
    Darwin)
        osascript -e 'tell application "Unity" to activate'
        ;;
    MINGW*|MSYS*|CYGWIN*|Windows_NT)
        powershell.exe -Command "
            Add-Type @'
                using System;
                using System.Runtime.InteropServices;
                public class Win32 {
                    [DllImport(\"user32.dll\")]
                    public static extern bool SetForegroundWindow(IntPtr hWnd);
                }
'@
            \$unity = Get-Process -Name Unity -ErrorAction SilentlyContinue | Select-Object -First 1
            if (\$unity) {
                [Win32]::SetForegroundWindow(\$unity.MainWindowHandle)
            }
        "
        ;;
    *)
        echo "Unsupported platform: $(uname -s)" >&2
        exit 1
        ;;
esac
