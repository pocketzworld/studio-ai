#if !HR_STUDIO_SIMULATOR
using UnityEngine;
using UnityEditor;
using System.IO;
using System;
using System.Diagnostics;
using System.Threading.Tasks;
using Newtonsoft.Json;
using Highrise;
using Highrise.Studio;
using Highrise.Create;
using Highrise.Create.Models;
using Highrise.Studio.Tools;

namespace Rosie
{
    /// <summary>
    /// Monitors for trigger files in the project root:
    /// - .play: Starts play mode (stops first if already playing)
    /// - .stop: Stops play mode (silently ignored if not playing)
    /// - .focus: Brings Unity editor window to foreground
    /// - .rebuild: Triggers a Lua rebuild
    /// - .screenshot: Captures a screenshot of the Game view
    /// - .rebake: Rebakes lightmaps and NavMesh for the scene
    /// - .upload: Uploads the world to Highrise
    /// - .catalog: Exports auth credentials for the asset catalog CLI
    /// - .install: Downloads and installs an asset from the catalog
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
        private static readonly string RebakeTriggerPath;
        private static readonly string UploadTriggerPath;
        private static readonly string UploadResultPath;
        private static readonly string CatalogTriggerPath;
        private static readonly string CatalogResultPath;
        private static readonly string InstallTriggerPath;
        private static readonly string InstallResultPath;
        private static bool _uploadInProgress;
        private static bool _installInProgress;
        private const double CHECK_INTERVAL = 1.0; // Check every 1 second
        private const double COOLDOWN_AFTER_PLAY_TRIGGER = 10.0; // 10 second cooldown between successful play triggers
        private const string RESTART_PLAY_PREF_KEY = "EditorTriggers_RestartPlay";

        static EditorTriggers()
        {
            var projectRoot = Directory.GetParent(Application.dataPath).FullName;
            PlayTriggerPath = Path.Combine(projectRoot, ".play");
            StopTriggerPath = Path.Combine(projectRoot, ".stop");
            FocusTriggerPath = Path.Combine(projectRoot, ".focus");
            RebuildTriggerPath = Path.Combine(projectRoot, ".rebuild");
            ScreenshotTriggerPath = Path.Combine(projectRoot, ".screenshot");
            ScreenshotOutputPath = Path.Combine(projectRoot, "Temp", "Highrise", "Serializer", "screenshot.png");
            RebakeTriggerPath = Path.Combine(projectRoot, ".rebake");
            UploadTriggerPath = Path.Combine(projectRoot, ".upload");
            UploadResultPath = Path.Combine(projectRoot, "Temp", "Highrise", "Serializer", "upload_result.json");
            CatalogTriggerPath = Path.Combine(projectRoot, ".catalog");
            CatalogResultPath = Path.Combine(projectRoot, "Temp", "Highrise", "Serializer", "catalog_result.json");
            InstallTriggerPath = Path.Combine(projectRoot, ".install");
            InstallResultPath = Path.Combine(projectRoot, "Temp", "Highrise", "Serializer", "install_result.json");
            EditorApplication.update += CheckTriggers;
            EditorApplication.playModeStateChanged += OnPlayModeStateChanged;
        }

        static void OnPlayModeStateChanged(PlayModeStateChange state)
        {
            // When play mode has fully stopped, check if we need to restart it
            if (state == PlayModeStateChange.EnteredEditMode && EditorPrefs.GetBool(RESTART_PLAY_PREF_KEY, false))
            {
                EditorPrefs.DeleteKey(RESTART_PLAY_PREF_KEY);
                FocusUnityWindow();
                FocusPlayModeWindow();
                TriggerLuaRebuild();
                EditorApplication.delayCall += () => EditorApplication.isPlaying = true;
            }
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
                    FocusPlayModeWindow();
                    ScreenCapture.CaptureScreenshot(ScreenshotOutputPath);
                }
                catch (Exception e)
                {
                    UnityEngine.Debug.LogWarning("[EditorTriggers] Failed to capture screenshot: " + e.Message);
                }
            }

            // Check for .rebake file
            if (File.Exists(RebakeTriggerPath))
            {
                try
                {
                    File.Delete(RebakeTriggerPath);
                    FocusUnityWindow();
                    TriggerSceneBake();
                }
                catch (Exception e)
                {
                    UnityEngine.Debug.LogWarning("[EditorTriggers] Failed to trigger scene bake: " + e.Message);
                }
            }

            // Check for .upload file
            if (!_uploadInProgress && File.Exists(UploadTriggerPath))
            {
                try
                {
                    var json = File.ReadAllText(UploadTriggerPath);
                    File.Delete(UploadTriggerPath);
                    HandleUploadTrigger(json);
                }
                catch (Exception e)
                {
                    UnityEngine.Debug.LogWarning("[EditorTriggers] Failed to process .upload file: " + e.Message);
                }
            }

            // Check for .catalog file
            if (File.Exists(CatalogTriggerPath))
            {
                try
                {
                    File.Delete(CatalogTriggerPath);
                    HandleCatalogTrigger();
                }
                catch (Exception e)
                {
                    UnityEngine.Debug.LogWarning("[EditorTriggers] Failed to process .catalog file: " + e.Message);
                }
            }

            // Check for .install file
            if (!_installInProgress && File.Exists(InstallTriggerPath))
            {
                try
                {
                    var json = File.ReadAllText(InstallTriggerPath);
                    File.Delete(InstallTriggerPath);
                    HandleInstallTrigger(json);
                }
                catch (Exception e)
                {
                    UnityEngine.Debug.LogWarning("[EditorTriggers] Failed to process .install file: " + e.Message);
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
                    // Set flag to restart play mode after it fully stops (survives domain reload)
                    EditorPrefs.SetBool(RESTART_PLAY_PREF_KEY, true);
                    EditorApplication.isPlaying = false;
                }
                else
                {
                    FocusUnityWindow();
                    FocusPlayModeWindow();
                    TriggerLuaRebuild();
                    EditorApplication.delayCall += () => EditorApplication.isPlaying = true;
                }
            }
        }

        private class UploadRequest
        {
            public string sessionToken;
            public string username;
            public string password;
            public string worldId;
            public string tag;
            public string packageVersionOverride;
        }

        static void HandleUploadTrigger(string json)
        {
            try
            {
                _uploadInProgress = true;
                var request = JsonConvert.DeserializeObject<UploadRequest>(json);

                // Save assets and scenes before building the archive (mirrors the UI upload flow)
                AssetDatabase.SaveAssets();
                UnityEditor.SceneManagement.EditorSceneManager.SaveOpenScenes();
                AssetDatabase.Refresh();

                if (File.Exists(UploadResultPath))
                    File.Delete(UploadResultPath);
                bool uploadSucceeded = false;
                Action onSuccess = () => uploadSucceeded = true;

                // Use Async.Run to set up the AsyncContext that UploadWorld internally depends on
                Async.Run(async () =>
                {
                    PublishWorld.UploadWorldSucceeded += onSuccess;
                    try
                    {
                        // Authenticate: prefer username/password login, fall back to session token
                        if (!string.IsNullOrEmpty(request.username) && !string.IsNullOrEmpty(request.password))
                        {
                            await StudioCreatePortal.LoginAsync(new CreatePortalCredentials
                            {
                                Username = request.username,
                                Password = request.password
                            });
                        }
                        else if (!string.IsNullOrEmpty(request.sessionToken))
                        {
                            StudioSettings.SessionToken = request.sessionToken;
                        }

                        var worldId = !string.IsNullOrEmpty(request.worldId)
                            ? request.worldId
                            : WorldSettings.instance.PublishedId;

                        if (string.IsNullOrEmpty(worldId))
                        {
                            WriteUploadResult(false, error: "No world ID found");
                            _uploadInProgress = false;
                            return;
                        }

                        await InvokeUploadWorld(worldId, request.tag, request.packageVersionOverride);

                        if (uploadSucceeded)
                        {
                            WriteUploadResult(true, worldId: worldId, buildNumber: StudioSettings.LastBuildNumber);
                        }
                        else
                        {
                            WriteUploadResult(false, error: "Upload did not succeed");
                            _uploadInProgress = false;
                        }
                    }
                    catch (Exception e)
                    {
                        UnityEngine.Debug.LogWarning("[EditorTriggers] Upload failed: " + e.Message);
                        WriteUploadResult(false, error: e.Message);
                        _uploadInProgress = false;
                    }
                    finally
                    {
                        PublishWorld.UploadWorldSucceeded -= onSuccess;
                        _uploadInProgress = false;
                    }
                });
            }
            catch (Exception e)
            {
                UnityEngine.Debug.LogWarning("[EditorTriggers] Upload failed: " + e.Message);
                WriteUploadResult(false, error: e.Message);
                _uploadInProgress = false;
            }
        }

        static async System.Threading.Tasks.Task InvokeUploadWorld(string worldId, string tag, string packageVersionOverride)
        {
            // Use reflection to support both 4-param and 5-param versions of UploadWorld
            var method = typeof(PublishWorld).GetMethod("UploadWorld",
                System.Reflection.BindingFlags.Public | System.Reflection.BindingFlags.Static);
            var paramCount = method.GetParameters().Length;
            object[] args = paramCount == 5
                ? new object[] { worldId, null, tag, packageVersionOverride, null }
                : new object[] { worldId, null, tag, packageVersionOverride };
            await (System.Threading.Tasks.Task)method.Invoke(null, args);
        }

        static void WriteUploadResult(bool success, string worldId = null, int buildNumber = 0, string error = null)
        {
            try
            {
                Directory.CreateDirectory(Path.GetDirectoryName(UploadResultPath));

                string resultJson;
                if (success)
                {
                    resultJson = JsonConvert.SerializeObject(new { success = true, worldId, buildNumber });
                }
                else
                {
                    resultJson = JsonConvert.SerializeObject(new { success = false, error });
                }

                File.WriteAllText(UploadResultPath, resultJson);
            }
            catch (Exception e)
            {
                UnityEngine.Debug.LogWarning("[EditorTriggers] Failed to write upload result: " + e.Message);
            }
        }

        static void HandleCatalogTrigger()
        {
            try
            {
                var sessionToken = StudioSettings.SessionToken;
                var environment = StudioSettings.CurrentEnvironment;

                if (string.IsNullOrEmpty(sessionToken))
                {
                    WriteCatalogResult(false, error: "Not logged in. Please log in to Highrise Studio first.");
                    return;
                }

                if (string.IsNullOrEmpty(environment))
                    environment = CreatePortal.EnvironmentProd;

                var baseUrl = string.Format("https://{0}-create.highrise.game/api", environment);

                WriteCatalogResult(true, sessionToken: sessionToken, environment: environment, baseUrl: baseUrl);
            }
            catch (Exception e)
            {
                UnityEngine.Debug.LogWarning("[EditorTriggers] Catalog trigger failed: " + e.Message);
                WriteCatalogResult(false, error: e.Message);
            }
        }

        static void WriteCatalogResult(bool success, string sessionToken = null, string environment = null, string baseUrl = null, string error = null)
        {
            try
            {
                Directory.CreateDirectory(Path.GetDirectoryName(CatalogResultPath));

                string resultJson;
                if (success)
                {
                    resultJson = JsonConvert.SerializeObject(new
                    {
                        success = true,
                        session_token = sessionToken,
                        environment,
                        base_url = baseUrl,
                        timestamp = DateTime.UtcNow.ToString("o")
                    });
                }
                else
                {
                    resultJson = JsonConvert.SerializeObject(new { success = false, error });
                }

                File.WriteAllText(CatalogResultPath, resultJson);
            }
            catch (Exception e)
            {
                UnityEngine.Debug.LogWarning("[EditorTriggers] Failed to write catalog result: " + e.Message);
            }
        }

        private class InstallRequest
        {
            public string assetId;
        }

        static void HandleInstallTrigger(string json)
        {
            try
            {
                _installInProgress = true;
                var request = JsonConvert.DeserializeObject<InstallRequest>(json);

                if (string.IsNullOrEmpty(request?.assetId))
                {
                    WriteInstallResult(false, error: "Missing assetId in .install request");
                    _installInProgress = false;
                    return;
                }

                if (File.Exists(InstallResultPath))
                    File.Delete(InstallResultPath);

                Async.Run(async () =>
                {
                    try
                    {
                        // Fetch asset details from the API
                        var response = await CreatePortal.GetAssetAsync(request.assetId);
                        var storeAsset = response.Asset;

                        if (storeAsset == null)
                        {
                            WriteInstallResult(false, error: $"Asset '{request.assetId}' not found");
                            _installInProgress = false;
                            return;
                        }

                        // Check if already installed
                        if (AssetStore.instance.IsInstalled(storeAsset.Id))
                        {
                            var existingPath = AssetStore.instance.StoreIdToAssetPath(storeAsset.Id);
                            WriteInstallResult(true, assetId: storeAsset.Id, assetName: storeAsset.Name, installedPath: existingPath, alreadyInstalled: true);
                            _installInProgress = false;
                            return;
                        }

                        // Check if purchase is needed
                        if (storeAsset.DoesAssetNeedPurchasing(StudioSettings.User))
                        {
                            WriteInstallResult(false, error: $"Asset '{storeAsset.Name}' requires purchase ({storeAsset.Price} gold). Purchase it first.");
                            _installInProgress = false;
                            return;
                        }

                        // Call the private InstallAssetAsync method via reflection
                        var method = typeof(AssetStore).GetMethod("InstallAssetAsync",
                            System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance);

                        if (method == null)
                        {
                            WriteInstallResult(false, error: "Could not find InstallAssetAsync method — AssetStore API may have changed");
                            _installInProgress = false;
                            return;
                        }

                        await (Task)method.Invoke(AssetStore.instance, new object[] { storeAsset });

                        var assetPath = AssetStore.instance.StoreIdToAssetPath(storeAsset.Id);
                        WriteInstallResult(true, assetId: storeAsset.Id, assetName: storeAsset.Name, installedPath: assetPath);
                    }
                    catch (Exception e)
                    {
                        UnityEngine.Debug.LogWarning("[EditorTriggers] Install failed: " + e.Message);
                        WriteInstallResult(false, error: e.Message);
                    }
                    finally
                    {
                        _installInProgress = false;
                    }
                });
            }
            catch (Exception e)
            {
                UnityEngine.Debug.LogWarning("[EditorTriggers] Install failed: " + e.Message);
                WriteInstallResult(false, error: e.Message);
                _installInProgress = false;
            }
        }

        static void WriteInstallResult(bool success, string assetId = null, string assetName = null, string installedPath = null, bool alreadyInstalled = false, string error = null)
        {
            try
            {
                Directory.CreateDirectory(Path.GetDirectoryName(InstallResultPath));

                string resultJson;
                if (success)
                {
                    resultJson = JsonConvert.SerializeObject(new { success = true, asset_id = assetId, asset_name = assetName, installed_path = installedPath, already_installed = alreadyInstalled });
                }
                else
                {
                    resultJson = JsonConvert.SerializeObject(new { success = false, error });
                }

                File.WriteAllText(InstallResultPath, resultJson);
            }
            catch (Exception e)
            {
                UnityEngine.Debug.LogWarning("[EditorTriggers] Failed to write install result: " + e.Message);
            }
        }

        static void TriggerLuaRebuild()
        {
            try
            {
                // Try to invoke the Highrise Lua rebuild menu item
                if (!EditorApplication.ExecuteMenuItem("Highrise/Lua/Rebuild All"))
                    UnityEngine.Debug.LogWarning("[EditorTriggers] Failed to trigger Lua rebuild: menu item not found");
            }
            catch (Exception e)
            {
                UnityEngine.Debug.LogWarning("[EditorTriggers] Failed to trigger Lua rebuild: " + e.Message);
            }
        }

        static void TriggerSceneBake()
        {
            // Bake lightmaps
            try
            {
                // Cancel any existing bake first
                if (Lightmapping.isRunning)
                {
                    Lightmapping.Cancel();
                }

                // Clear existing baked data
                Lightmapping.Clear();

                // Start async bake to avoid blocking the editor
                Lightmapping.BakeAsync();
                UnityEngine.Debug.Log("[EditorTriggers] Lightmap bake started");
            }
            catch (Exception e)
            {
                UnityEngine.Debug.LogWarning("[EditorTriggers] Failed to start lightmap bake: " + e.Message);
            }

            // Bake NavMesh - try NavMeshSurface components first (modern), then fall back to legacy
            try
            {
                int surfaceCount = 0;
                // Find all NavMeshSurface components in the scene and bake them
                // NavMeshSurface is in Unity.AI.Navigation namespace (AI Navigation package)
                var surfaceType = Type.GetType("Unity.AI.Navigation.NavMeshSurface, Unity.AI.Navigation");
                if (surfaceType != null)
                {
                    var surfaces = UnityEngine.Object.FindObjectsByType(surfaceType, FindObjectsSortMode.None);
                    var buildMethod = surfaceType.GetMethod("BuildNavMesh", System.Reflection.BindingFlags.Public | System.Reflection.BindingFlags.Instance);
                    if (buildMethod != null)
                    {
                        foreach (var surface in surfaces)
                        {
                            buildMethod.Invoke(surface, null);
                            surfaceCount++;
                        }
                    }
                }

                if (surfaceCount > 0)
                {
                    UnityEngine.Debug.Log($"[EditorTriggers] NavMesh bake completed ({surfaceCount} surface(s))");
                }
            }
            catch (Exception e)
            {
                UnityEngine.Debug.LogWarning("[EditorTriggers] Failed to bake NavMesh: " + e.Message);
            }
        }

        static void FocusUnityWindow()
        {
            try
            {
                // Platform-specific window activation to bring Unity to foreground
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

        static void FocusPlayModeWindow()
        {
            // Prefer Simulator window if one is already open
            var simulatorType = Type.GetType("UnityEditor.DeviceSimulation.SimulatorWindow,UnityEditor.DeviceSimulatorModule");
            if (simulatorType != null)
            {
                var existingSimulators = Resources.FindObjectsOfTypeAll(simulatorType);
                if (existingSimulators.Length > 0)
                {
                    (existingSimulators[0] as EditorWindow)?.Focus();
                    return;
                }
            }

            // Fall back to Game view
            var gameViewType = Type.GetType("UnityEditor.GameView,UnityEditor");
            if (gameViewType != null)
            {
                EditorWindow.GetWindow(gameViewType, false, "Game", true)?.Focus();
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
#endif
