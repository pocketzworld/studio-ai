Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class Win32 {
    [DllImport("user32.dll")]
    public static extern bool SetForegroundWindow(IntPtr hWnd);
    [DllImport("user32.dll")]
    public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
    [DllImport("user32.dll")]
    public static extern IntPtr GetForegroundWindow();
    [DllImport("user32.dll")]
    public static extern uint GetWindowThreadProcessId(IntPtr hWnd, IntPtr lpdwProcessId);
    [DllImport("kernel32.dll")]
    public static extern uint GetCurrentThreadId();
    [DllImport("user32.dll")]
    public static extern bool AttachThreadInput(uint idAttach, uint idAttachTo, bool fAttach);
    [DllImport("user32.dll")]
    public static extern bool BringWindowToTop(IntPtr hWnd);
    [DllImport("user32.dll")]
    public static extern bool IsIconic(IntPtr hWnd);
}
"@

$unity = Get-Process -Name Unity -ErrorAction SilentlyContinue | Select-Object -First 1
if ($unity) {
    $hwnd = $unity.MainWindowHandle
    $foregroundHwnd = [Win32]::GetForegroundWindow()
    $currentThreadId = [Win32]::GetCurrentThreadId()
    $foregroundThreadId = [Win32]::GetWindowThreadProcessId($foregroundHwnd, [IntPtr]::Zero)

    # Attach to the foreground thread to bypass SetForegroundWindow restrictions
    [Win32]::AttachThreadInput($currentThreadId, $foregroundThreadId, $true) | Out-Null

    # Restore if minimized
    if ([Win32]::IsIconic($hwnd)) {
        [Win32]::ShowWindow($hwnd, 9) | Out-Null  # SW_RESTORE
    }

    [Win32]::BringWindowToTop($hwnd) | Out-Null
    [Win32]::SetForegroundWindow($hwnd) | Out-Null

    # Detach from the foreground thread
    [Win32]::AttachThreadInput($currentThreadId, $foregroundThreadId, $false) | Out-Null

    Write-Host "Unity window focused"
} else {
    Write-Host "Unity not found"
}
