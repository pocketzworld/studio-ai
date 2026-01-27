using UnityEditor;
using UnityEngine;
using System.Collections.Generic;
using Newtonsoft.Json;
using System;

namespace Rosie
{
    [Serializable]
    public class ConsoleEntry
    {
        public string message;
        public string stackTrace;
        public string logType;
        public string timestamp;
    }

    public static class ConsoleWriter
    {
        // Use the same pref key as SceneWriter so both are controlled by the same menu toggle
        private const string RUNNING_PREF_KEY = "Highrise.SceneWriter.Running";
        private const int MAX_ENTRIES = 500;
        private static readonly string WRITE_DIRECTORY =
            System.IO.Path.Combine(System.IO.Path.GetFullPath("Temp"), "Highrise", "Serializer");
        private static readonly string CONSOLE_FILE_PATH =
            System.IO.Path.Combine(WRITE_DIRECTORY, "console.json");

        private static bool running = false;
        private static readonly List<ConsoleEntry> entries = new();
        private static readonly object entriesLock = new();
        private static bool initialized = false;
        private static bool isDirty = false;
        private static float lastWriteTime = 0f;
        private const float WRITE_INTERVAL = 0.5f;

        [InitializeOnLoadMethod]
        private static void OnEditorLoad()
        {
            if (initialized)
            {
                Application.logMessageReceivedThreaded -= OnLogMessageReceivedThreaded;
                EditorApplication.update -= OnUpdate;
                EditorApplication.playModeStateChanged -= OnPlayModeStateChanged;
                Highrise.ConsoleExtensions.OnRuntimeLogMessage -= OnRuntimeLogMessage;
            }

            if (!System.IO.Directory.Exists(WRITE_DIRECTORY))
            {
                System.IO.Directory.CreateDirectory(WRITE_DIRECTORY);
            }

            running = EditorPrefs.GetBool(RUNNING_PREF_KEY, true);

            // Only subscribe to logMessageReceivedThreaded - it captures all logs from any thread
            // Don't also subscribe to logMessageReceived as that would cause duplicates
            Application.logMessageReceivedThreaded += OnLogMessageReceivedThreaded;
            EditorApplication.update += OnUpdate;
            EditorApplication.playModeStateChanged += OnPlayModeStateChanged;
            Highrise.ConsoleExtensions.OnRuntimeLogMessage += OnRuntimeLogMessage;

            initialized = true;

            if (running)
            {
                WriteConsoleFile();
            }
        }

        private static void OnRuntimeLogMessage(string message, string timestamp)
        {
            if (string.IsNullOrEmpty(message)) return;
            AddEntry($"[{timestamp}] {message.TrimEnd('\n')}", string.Empty, "LuaRuntime");
        }

        private static void OnPlayModeStateChanged(PlayModeStateChange state)
        {
            if (state == PlayModeStateChange.ExitingEditMode)
            {
                // Clear console when entering play mode
                lock (entriesLock)
                {
                    entries.Clear();
                }
                WriteConsoleFile();
            }
        }

        private static void OnUpdate()
        {
            // Re-check the pref in case SceneWriter toggled it
            bool currentPref = EditorPrefs.GetBool(RUNNING_PREF_KEY, true);
            if (currentPref != running)
            {
                running = currentPref;
                if (running)
                {
                    WriteConsoleFile();
                }
            }

            if (!running) return;

            if (isDirty && Time.realtimeSinceStartup - lastWriteTime >= WRITE_INTERVAL)
            {
                WriteConsoleFile();
                isDirty = false;
                lastWriteTime = Time.realtimeSinceStartup;
            }
        }

        private static void OnLogMessageReceivedThreaded(string condition, string stackTrace, LogType type)
        {
            if (!running) return;
            AddEntry(condition, stackTrace, type.ToString());
        }

        private static void AddEntry(string condition, string stackTrace, string logType)
        {
            var entry = new ConsoleEntry
            {
                message = condition,
                stackTrace = stackTrace,
                logType = logType,
                timestamp = DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss.fff")
            };

            lock (entriesLock)
            {
                entries.Add(entry);

                // Trim old entries if we exceed max
                while (entries.Count > MAX_ENTRIES)
                {
                    entries.RemoveAt(0);
                }
            }

            isDirty = true;
        }

        private static void WriteConsoleFile()
        {
            try
            {
                List<ConsoleEntry> entriesToWrite;
                lock (entriesLock)
                {
                    entriesToWrite = new List<ConsoleEntry>(entries);
                }

                var json = JsonConvert.SerializeObject(entriesToWrite, Formatting.Indented);
                System.IO.File.WriteAllText(CONSOLE_FILE_PATH, json);
            }
            catch (Exception e)
            {
                Debug.LogError($"ConsoleWriter: Failed to write console file: {e.Message}");
            }
        }
    }
}
