using UnityEngine;
using UnityEditor;
using System.IO;
using System;
using System.Diagnostics;

namespace Rosie
{
    /// <summary>
    /// Monitors for a .play trigger file in the project root.
    /// When detected, toggles play mode (start if stopped, stop if playing).
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
        private static double _lastSuccessfulTriggerTime;
        private static readonly string TriggerPath;
        private const double CHECK_INTERVAL = 1.0; // Check every 1 second
        private const double COOLDOWN_AFTER_TRIGGER = 10.0; // 10 second cooldown between successful triggers

        static PlayModeTrigger()
        {
            var projectRoot = Directory.GetParent(Application.dataPath).FullName;
            TriggerPath = Path.Combine(projectRoot, ".play");
            EditorApplication.update += CheckTrigger;
        }

        static void CheckTrigger()
        {
            // Rate limit checks
            if (EditorApplication.timeSinceStartup - _lastCheckTime < CHECK_INTERVAL)
                return;

            _lastCheckTime = EditorApplication.timeSinceStartup;

            // Check if .play file exists
            if (!File.Exists(TriggerPath))
                return;

            // Delete the file immediately
            try
            {
                File.Delete(TriggerPath);
            }
            catch (Exception e)
            {
                UnityEngine.Debug.LogWarning("[PlayModeTrigger] Failed to delete .play file: " + e.Message);
                return;
            }

            // Enforce cooldown between successful triggers
            if (EditorApplication.timeSinceStartup - _lastSuccessfulTriggerTime < COOLDOWN_AFTER_TRIGGER)
            {
                UnityEngine.Debug.Log("[PlayModeTrigger] Ignoring .play file - cooldown active");
                return;
            }

            _lastSuccessfulTriggerTime = EditorApplication.timeSinceStartup;

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
                // Use AppleScript to activate Unity
                var startInfo = new ProcessStartInfo
                {
                    FileName = "/usr/bin/osascript",
                    Arguments = "-e 'tell application \"Unity\" to activate'",
                    UseShellExecute = false,
                    RedirectStandardOutput = true,
                    RedirectStandardError = true,
                    CreateNoWindow = true
                };

                using (var process = Process.Start(startInfo))
                {
                    process?.WaitForExit(1000); // Wait max 1 second
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
