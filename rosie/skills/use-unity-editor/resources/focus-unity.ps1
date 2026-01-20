Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class Win32 {
    [DllImport("user32.dll")]
    public static extern bool SetForegroundWindow(IntPtr hWnd);
    [DllImport("user32.dll")]
    public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
}
"@

$unity = Get-Process -Name Unity -ErrorAction SilentlyContinue | Select-Object -First 1
if ($unity) {
    [Win32]::ShowWindow($unity.MainWindowHandle, 9)  # SW_RESTORE
    [Win32]::SetForegroundWindow($unity.MainWindowHandle)
    Write-Host "Unity window focused"
} else {
    Write-Host "Unity not found"
}
