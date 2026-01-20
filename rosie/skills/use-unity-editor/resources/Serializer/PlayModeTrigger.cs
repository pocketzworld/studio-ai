using UnityEngine;
using UnityEditor;
using System.IO;
using System;
using System.Diagnostics;

namespace Rosie
{
    /// <summary>
    /// Monitors for trigger files in the project root:
    /// - .play: Toggles play mode (start if stopped, stop if playing)
    /// - .focus: Brings Unity editor window to foreground
    /// Works on both Windows and macOS.
    ///
    /// This file is automatically symlinked to Assets/Editor/Serializer/
    /// </summary>
    [InitializeOnLoad]
    public static class PlayModeTrigger
    {
#if UNITY_EDITOR_WIN
        // Windows API for focusing windows
        [System.Runtime.InteropServices.DllImport("user32.dll")]
        private static extern bool SetForegroundWindow(IntPtr hWnd);

        [System.Runtime.InteropServices.DllImport("user32.dll")]
        private static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);

        private const int SW_RESTORE = 9;
#endif

        private static double _lastCheckTime;
        private static double _lastSuccessfulPlayTriggerTime;
        private static readonly string PlayTriggerPath;
        private static readonly string FocusTriggerPath;
        private const double CHECK_INTERVAL = 1.0; // Check every 1 second
        private const double COOLDOWN_AFTER_PLAY_TRIGGER = 10.0; // 10 second cooldown between successful play triggers

        static PlayModeTrigger()
        {
            var projectRoot = Directory.GetParent(Application.dataPath).FullName;
            PlayTriggerPath = Path.Combine(projectRoot, ".play");
            FocusTriggerPath = Path.Combine(projectRoot, ".focus");
            EditorApplication.update += CheckTriggers;
        }

        static void CheckTriggers()
        {
            // Rate limit checks
            if (EditorApplication.timeSinceStartup - _lastCheckTime < CHECK_INTERVAL)
                return;

            _lastCheckTime = EditorApplication.timeSinceStartup;

            // Check for .focus file first (no cooldown needed)
            if (File.Exists(FocusTriggerPath))
            {
                try
                {
                    File.Delete(FocusTriggerPath);
                    UnityEngine.Debug.Log("[PlayModeTrigger] Focusing Unity window");
                    FocusUnityWindow();
                }
                catch (Exception e)
                {
                    UnityEngine.Debug.LogWarning("[PlayModeTrigger] Failed to process .focus file: " + e.Message);
                }
            }

            // Check for .play file
            if (!File.Exists(PlayTriggerPath))
                return;

            // Delete the file immediately
            try
            {
                File.Delete(PlayTriggerPath);
            }
            catch (Exception e)
            {
                UnityEngine.Debug.LogWarning("[PlayModeTrigger] Failed to delete .play file: " + e.Message);
                return;
            }

            // Enforce cooldown between successful play triggers
            if (EditorApplication.timeSinceStartup - _lastSuccessfulPlayTriggerTime < COOLDOWN_AFTER_PLAY_TRIGGER)
            {
                UnityEngine.Debug.Log("[PlayModeTrigger] Ignoring .play file - cooldown active");
                return;
            }

            _lastSuccessfulPlayTriggerTime = EditorApplication.timeSinceStartup;

            // Toggle play mode
            if (EditorApplication.isPlaying)
            {
                UnityEngine.Debug.Log("[PlayModeTrigger] Stopping play mode");
                EditorApplication.isPlaying = false;
            }
            else
            {
                UnityEngine.Debug.Log("[PlayModeTrigger] Rebuilding Lua and starting play mode");
                TriggerLuaRebuild();
                FocusUnityWindow();
                EditorApplication.isPlaying = true;
            }
        }

        static void TriggerLuaRebuild()
        {
            try
            {
                // Try to invoke the Highrise Lua rebuild menu item
                bool success = EditorApplication.ExecuteMenuItem("Highrise/Lua/Rebuild All");
                if (success)
                {
                    UnityEngine.Debug.Log("[PlayModeTrigger] Lua rebuild triggered via menu");
                    return;
                }

                // Fallback: trigger asset refresh which should recompile Lua
                UnityEngine.Debug.Log("[PlayModeTrigger] Menu item not found, triggering asset refresh...");
                AssetDatabase.Refresh(ImportAssetOptions.ForceUpdate);
            }
            catch (Exception e)
            {
                UnityEngine.Debug.LogWarning("[PlayModeTrigger] Failed to trigger Lua rebuild: " + e.Message);
                // Fallback to asset refresh
                AssetDatabase.Refresh(ImportAssetOptions.ForceUpdate);
            }
        }

        static void FocusUnityWindow()
        {
            try
            {
                // Focus the Game view specifically for play mode (cross-platform Unity API)
                var gameViewType = Type.GetType("UnityEditor.GameView,UnityEditor");
                if (gameViewType != null)
                {
                    var gameView = EditorWindow.GetWindow(gameViewType, false, "Game", true);
                    if (gameView != null)
                    {
                        gameView.Focus();
                    }
                }

                // Platform-specific window activation
#if UNITY_EDITOR_WIN
                FocusWindowWindows();
#elif UNITY_EDITOR_OSX
                FocusWindowMac();
#endif

                UnityEngine.Debug.Log("[PlayModeTrigger] Focused Unity window");
            }
            catch (Exception e)
            {
                UnityEngine.Debug.LogWarning("[PlayModeTrigger] Failed to focus window: " + e.Message);
            }
        }

#if UNITY_EDITOR_WIN
        static void FocusWindowWindows()
        {
            try
            {
                Process currentProcess = Process.GetCurrentProcess();
                IntPtr hWnd = currentProcess.MainWindowHandle;
                if (hWnd != IntPtr.Zero)
                {
                    ShowWindow(hWnd, SW_RESTORE);
                    SetForegroundWindow(hWnd);
                }
            }
            catch (Exception e)
            {
                UnityEngine.Debug.LogWarning("[PlayModeTrigger] Windows focus failed: " + e.Message);
            }
        }
#endif

#if UNITY_EDITOR_OSX
        static void FocusWindowMac()
        {
            try
            {
                // Use System Events to focus Unity (more reliable than "tell application")
                var script = @"tell application ""System Events""
set unityProcesses to every process whose name contains ""Unity"" and name does not contain ""Hub""
if (count of unityProcesses) > 0 then
set frontmost of item 1 of unityProcesses to true
end if
end tell";

                var startInfo = new ProcessStartInfo
                {
                    FileName = "/usr/bin/osascript",
                    UseShellExecute = false,
                    RedirectStandardInput = true,
                    RedirectStandardOutput = true,
                    RedirectStandardError = true,
                    CreateNoWindow = true
                };

                using (var process = Process.Start(startInfo))
                {
                    if (process != null)
                    {
                        process.StandardInput.Write(script);
                        process.StandardInput.Close();
                        process.WaitForExit(1000); // Wait max 1 second
                    }
                }
            }
            catch (Exception e)
            {
                UnityEngine.Debug.LogWarning("[PlayModeTrigger] Mac focus failed: " + e.Message);
            }
        }
#endif
    }
}
