using UnityEngine;
using UnityEditor;
using System.IO;
using System;
using System.Diagnostics;

namespace Rosie
{
    /// <summary>
    /// Monitors for trigger files in the project root:
    /// - .play: Starts play mode (stops first if already playing)
    /// - .stop: Stops play mode (silently ignored if not playing)
    /// - .focus: Brings Unity editor window to foreground
    /// - .rebuild: Triggers a Lua rebuild
    /// - .screenshot: Captures a screenshot of the Game view
    /// Works on both Windows and macOS.
    ///
    /// This file is automatically symlinked to Assets/Editor/Serializer/
    /// </summary>
    [InitializeOnLoad]
    public static class EditorTriggers
    {

        private static double _lastCheckTime;
        private static double _lastSuccessfulPlayTriggerTime;
        private static readonly string PlayTriggerPath;
        private static readonly string StopTriggerPath;
        private static readonly string FocusTriggerPath;
        private static readonly string RebuildTriggerPath;
        private static readonly string ScreenshotTriggerPath;
        private static readonly string ScreenshotOutputPath;
        private const double CHECK_INTERVAL = 1.0; // Check every 1 second
        private const double COOLDOWN_AFTER_PLAY_TRIGGER = 10.0; // 10 second cooldown between successful play triggers

        static EditorTriggers()
        {
            var projectRoot = Directory.GetParent(Application.dataPath).FullName;
            PlayTriggerPath = Path.Combine(projectRoot, ".play");
            StopTriggerPath = Path.Combine(projectRoot, ".stop");
            FocusTriggerPath = Path.Combine(projectRoot, ".focus");
            RebuildTriggerPath = Path.Combine(projectRoot, ".rebuild");
            ScreenshotTriggerPath = Path.Combine(projectRoot, ".screenshot");
            ScreenshotOutputPath = Path.Combine(projectRoot, "Temp", "Highrise", "Serializer", "screenshot.png");
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
                    FocusUnityWindow();
                }
                catch (Exception e)
                {
                    UnityEngine.Debug.LogWarning("[EditorTriggers] Failed to process .focus file: " + e.Message);
                }
            }

            // Check for .rebuild file
            if (File.Exists(RebuildTriggerPath))
            {
                try
                {
                    File.Delete(RebuildTriggerPath);
                    FocusUnityWindow();
                    TriggerLuaRebuild();
                }
                catch (Exception e)
                {
                    UnityEngine.Debug.LogWarning("[EditorTriggers] Failed to process .rebuild file: " + e.Message);
                }
            }

            // Check for .screenshot file
            if (File.Exists(ScreenshotTriggerPath))
            {
                try
                {
                    File.Delete(ScreenshotTriggerPath);
                    FocusUnityWindow();
                    ScreenCapture.CaptureScreenshot(ScreenshotOutputPath);
                }
                catch (Exception e)
                {
                    UnityEngine.Debug.LogWarning("[EditorTriggers] Failed to capture screenshot: " + e.Message);
                }
            }

            // Check for .stop file
            if (File.Exists(StopTriggerPath))
            {
                try
                {
                    File.Delete(StopTriggerPath);
                    if (EditorApplication.isPlaying)
                    {
                        EditorApplication.isPlaying = false;
                    }
                    // Silently consumed if not playing
                }
                catch (Exception e)
                {
                    UnityEngine.Debug.LogWarning("[EditorTriggers] Failed to process .stop file: " + e.Message);
                }
            }

            // Check for .play file
            if (File.Exists(PlayTriggerPath))
            {
                // Delete the file immediately
                try
                {
                    File.Delete(PlayTriggerPath);
                }
                catch (Exception e)
                {
                    UnityEngine.Debug.LogWarning("[EditorTriggers] Failed to delete .play file: " + e.Message);
                    return;
                }

                // Enforce cooldown between successful play triggers
                if (EditorApplication.timeSinceStartup - _lastSuccessfulPlayTriggerTime < COOLDOWN_AFTER_PLAY_TRIGGER)
                    return;

                _lastSuccessfulPlayTriggerTime = EditorApplication.timeSinceStartup;

                // Always start play mode (stop first if already playing)
                if (EditorApplication.isPlaying)
                {
                    EditorApplication.isPlaying = false;
                }
                FocusUnityWindow();
                TriggerLuaRebuild();
                // Defer play mode start to next frame to ensure stop completes
                EditorApplication.delayCall += () => EditorApplication.isPlaying = true;
            }
        }

        static void TriggerLuaRebuild()
        {
            try
            {
                // Try to invoke the Highrise Lua rebuild menu item
                bool success = EditorApplication.ExecuteMenuItem("Highrise/Lua/Rebuild All");
                if (success)
                    return;

                // Fallback: trigger asset refresh which should recompile Lua
                AssetDatabase.Refresh(ImportAssetOptions.ForceUpdate);
            }
            catch (Exception e)
            {
                UnityEngine.Debug.LogWarning("[EditorTriggers] Failed to trigger Lua rebuild: " + e.Message);
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
            }
            catch (Exception e)
            {
                UnityEngine.Debug.LogWarning("[EditorTriggers] Failed to focus window: " + e.Message);
            }
        }

#if UNITY_EDITOR_WIN
        static void FocusWindowWindows()
        {
            // No-op on Windows - use the external PowerShell script focus-unity.ps1 instead
            // Windows doesn't allow background processes to bring windows to the foreground
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
                UnityEngine.Debug.LogWarning("[EditorTriggers] Mac focus failed: " + e.Message);
            }
        }
#endif
    }
}
