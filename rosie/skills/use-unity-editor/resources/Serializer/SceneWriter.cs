using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEditorInternal;
using UnityEngine;
using System.Collections.Generic;
using System.Linq;
using Newtonsoft.Json;
using System;
using System.Reflection;

namespace Rosie
{
    public static class SceneWriter
    {
        private const string RUNNING_PREF_KEY = "Highrise.SceneWriter.Running";
        private static readonly string WRITE_DIRECTORY = 
            System.IO.Path.Combine(System.IO.Path.GetFullPath("Temp"), "Highrise", "Serializer");
        
        private static bool running = false;
        private static readonly Dictionary<UnityEngine.Object, string> objectToId = new();
        private static readonly Dictionary<string, UnityEngine.Object> idToObject = new();
        private static int shouldSerializeInNFrames = -1;
        private static float nextReadEditTime = -1f;
        private static bool initialized = false;

        [InitializeOnLoadMethod]
        private static void OnEditorLoad()
        {
            // Unsubscribe from events if already initialized (handles editor reloads)
            if (initialized)
            {
                EditorSceneManager.sceneSaved -= MarkShouldSerialize;
                EditorSceneManager.sceneOpened -= MarkShouldSerialize;
                EditorApplication.update -= OnUpdate;
            }

            if (!System.IO.Directory.Exists(WRITE_DIRECTORY))
            {
                System.IO.Directory.CreateDirectory(WRITE_DIRECTORY);
            }
            
            running = EditorPrefs.GetBool(RUNNING_PREF_KEY, true);
            if (running)
            {
                shouldSerializeInNFrames = 2;
            }
            
            EditorSceneManager.sceneSaved += MarkShouldSerialize;
            EditorSceneManager.sceneOpened += MarkShouldSerialize;
            EditorApplication.update += OnUpdate;
            
            initialized = true;
        }

        [MenuItem("Highrise/Studio/Serialize to JSON", false)]
        private static void ToggleSerialize()
        {
            bool currentRunning = EditorPrefs.GetBool(RUNNING_PREF_KEY, true);
            bool newRunning = !currentRunning;
            
            running = newRunning;
            EditorPrefs.SetBool(RUNNING_PREF_KEY, newRunning);
            if (newRunning)
            {
                shouldSerializeInNFrames = 2;
            }
            
            Menu.SetChecked("Highrise/Studio/Serialize to JSON", newRunning);
        }

        [MenuItem("Highrise/Studio/Serialize to JSON", true)]
        private static bool ToggleSerializeValidate()
        {
            bool running = EditorPrefs.GetBool(RUNNING_PREF_KEY, true);
            Menu.SetChecked("Highrise/Studio/Serialize to JSON", running);
            return true;
        }

        private static void OnUpdate()
        {
            if (!running) return;
            if (shouldSerializeInNFrames > 0)
            {
                shouldSerializeInNFrames--;
                if (shouldSerializeInNFrames == 0)
                {
                    SerializeScene(EditorSceneManager.GetActiveScene());
                }
            }
            if (nextReadEditTime > 0f && Time.realtimeSinceStartup >= nextReadEditTime)
            {
                nextReadEditTime = Time.realtimeSinceStartup + 0.5f;
                ReadEdits();
            }
        }

        private static void ReadEdits()
        {
            string filePath = System.IO.Path.Combine(WRITE_DIRECTORY, "edit.json");
            if (!System.IO.File.Exists(filePath))
                return;

            var editData = System.IO.File.ReadAllText(filePath);
            var edits = JsonConvert.DeserializeObject<List<SceneEdit>>(editData);
            System.IO.File.Delete(filePath);
            foreach (var edit in edits)
            {
                if (edit.editType == "delete")
                {
                    if (!idToObject.TryGetValue(edit.referenceIdToDelete, out var obj))
                    {
                        Debug.LogError("Could not find object to delete: " + edit.referenceIdToDelete);
                        continue;
                    }
                    Undo.DestroyObjectImmediate(obj);
                }
                else if (edit.editType == "setProperty")
                {
                    if (!idToObject.TryGetValue(edit.referenceIdOfObjectWithPropertyToSet, out var obj))
                    {
                        Debug.LogError("Could not find object to edit: " + edit.referenceIdOfObjectWithPropertyToSet);
                        continue;
                    }
                    Undo.RecordObject(obj, "Set Property " + edit.nameOfPropertyToSet);

                    // Special case for game object properties that cannot be set as fields or properties
                    if (obj is GameObject gameObject)
                    {
                        if (edit.nameOfPropertyToSet == "activeSelf")
                        {
                            gameObject.SetActive((bool)edit.newPropertyValue);
                            continue;
                        }
                        else if (edit.nameOfPropertyToSet == "tag")
                        {
                            if (!InternalEditorUtility.tags.Contains((string)edit.newPropertyValue))
                            {
                                InternalEditorUtility.AddTag((string)edit.newPropertyValue);
                            }
                            gameObject.tag = (string)edit.newPropertyValue;
                            continue;
                        }
                        else if (edit.nameOfPropertyToSet == "parentGameObject")
                        {
                            if (edit.newPropertyValue == null || (string)edit.newPropertyValue == "SceneRoot")
                            {
                                gameObject.transform.SetParent(null);
                            }
                            else
                            {
                                if (!idToObject.TryGetValue((string)edit.newPropertyValue, out var newParent))
                                {
                                    Debug.LogError("Could not find parent object: " + edit.newPropertyValue);
                                    continue;
                                }
                                gameObject.transform.SetParent(((GameObject)newParent).transform);
                            }
                            continue;
                        }
                    }
                    var field = obj.GetType().GetField(edit.nameOfPropertyToSet, System.Reflection.BindingFlags.Public | System.Reflection.BindingFlags.Instance) ??
                                obj.GetType().GetField(edit.nameOfPropertyToSet, System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance);
                    var property = obj.GetType().GetProperty(edit.nameOfPropertyToSet, System.Reflection.BindingFlags.Public | System.Reflection.BindingFlags.Instance) ??
                                obj.GetType().GetProperty(edit.nameOfPropertyToSet, System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance);
                    var propertyType = property?.PropertyType ?? field?.FieldType ?? null;
                    if (propertyType != null)
                    {
                        try {
                            var newValue = ValueSerializer.FromSerializable(edit.newPropertyValue, propertyType);
                            if (property != null)
                            {
                                property.SetValue(obj, newValue);
                            }
                            else if (field != null)
                            {
                                field.SetValue(obj, newValue);
                            }
                        }
                        catch (NotImplementedException e)
                        {
                            Debug.LogError("Could not set property or field: " + edit.nameOfPropertyToSet +": " + e.Message);
                        }
                    }
                    else
                    {
                        Debug.LogError("Could not find property or field to edit: " + edit.nameOfPropertyToSet);
                    }
                }
                else if (edit.editType == "createGameObject")
                {
                    var gameObject = new GameObject(edit.nameOfGameObjectToCreate);
                    if (edit.referenceIdOfParentGameObject != null && edit.referenceIdOfParentGameObject != "SceneRoot")
                    {
                        if (!idToObject.TryGetValue(edit.referenceIdOfParentGameObject, out var parentObj))
                        {
                            Debug.LogError("Could not find parent object to create game object: " + edit.referenceIdOfParentGameObject);
                            continue;
                        }
                        gameObject.transform.SetParent(((GameObject)parentObj).transform);
                    }
                    Undo.RegisterCreatedObjectUndo(gameObject, "Create Game Object");
                }
                else if (edit.editType == "addComponent")
                {
                    if (!idToObject.TryGetValue(edit.referenceIdOfGameObjectToAddComponent, out var gameObject))
                    {
                        Debug.LogError("Could not find game object to add component: " + edit.referenceIdOfGameObjectToAddComponent);
                        continue;
                    }
                    Type componentType = ((Type.GetType(edit.componentTypeToAdd) ?? Type.GetType("UnityEngine." + edit.componentTypeToAdd + ", UnityEngine.CoreModule")) ?? AppDomain.CurrentDomain.GetAssemblies()
                        .SelectMany(assembly => {
                            try
                            {
                                return assembly.GetTypes();
                            }
                            catch (ReflectionTypeLoadException ex)
                            {
                                // Return only successfully loaded types, filtering out null entries
                                return ex.Types.Where(t => t != null);
                            }
                        })
                        .FirstOrDefault(type => (type.Name == edit.componentTypeToAdd || type.FullName == edit.componentTypeToAdd) && type.IsSubclassOf(typeof(Component))));
                    if (componentType == null)
                    {
                        Debug.LogError("Could not find component type: " + edit.componentTypeToAdd);
                        continue;
                    }
                    Component existingComponent = ((GameObject)gameObject).GetComponent(componentType);
                    if (existingComponent != null)
                    {
                        Debug.LogError("Game object already has component: " + edit.componentTypeToAdd);
                        continue;
                    }
                    Undo.AddComponent((GameObject)gameObject, componentType);
                }
            }
            shouldSerializeInNFrames = 2;
        }

        private static void MarkShouldSerialize(UnityEngine.SceneManagement.Scene scene)
        {
            shouldSerializeInNFrames = 2;
        }

        private static void MarkShouldSerialize(UnityEngine.SceneManagement.Scene scene, OpenSceneMode mode)
        {
            shouldSerializeInNFrames = 2;
        }

        private static void SerializeScene(UnityEngine.SceneManagement.Scene scene)
        {
            string filePath = System.IO.Path.Combine(WRITE_DIRECTORY, "active_scene.json");
            System.IO.Directory.CreateDirectory(System.IO.Path.GetDirectoryName(filePath));
            if (System.IO.File.Exists(filePath))
                System.IO.File.Delete(filePath);
            var rootObject = new SerializedGameObject(scene.GetRootGameObjects().Select(go => new SerializedGameObject(go)).ToArray());
            System.IO.File.WriteAllText(filePath, rootObject.ToString());
            nextReadEditTime = Time.realtimeSinceStartup + 0.5f;

            // write all of the addable component types to a file
            var allComponentTypes = GetAllAddableComponentTypes().Select(t => t.FullName).ToList();
            var allComponentTypesFilePath = System.IO.Path.Combine(WRITE_DIRECTORY, "all_component_types.json");
            System.IO.File.WriteAllText(allComponentTypesFilePath, JsonConvert.SerializeObject(allComponentTypes, Formatting.Indented));
        }

        public static string GetId(UnityEngine.Object obj)
        {
            if (!objectToId.TryGetValue(obj, out var id))
            {
                id = System.Guid.NewGuid().ToString();
                objectToId[obj] = id;
                idToObject[id] = obj;
            }
            return id;
        }

        public static UnityEngine.Object GetObject(string id)
        {
            if (idToObject.TryGetValue(id, out var obj))
            {
                return obj;
            }
            throw new System.Exception("Object with id " + id + " not found");
        }

        /// <summary>
        /// Gets all component types that can be added to GameObjects in the editor.
        /// This includes both built-in Unity components (like BoxCollider) and user-created types (like Highrise.Client.Anchor).
        /// </summary>
        /// <returns>A list of all addable component types, sorted by full name.</returns>
        public static List<Type> GetAllAddableComponentTypes()
        {
            var componentTypes = new List<Type>();
            
            // Use Unity's TypeCache API for efficient type discovery
            var types = TypeCache.GetTypesDerivedFrom<Component>();
            
            foreach (var type in types)
            {
                // Filter out types that can't be added:
                // - Abstract classes can't be instantiated
                // - Generic types need type parameters
                // - Interfaces can't be instantiated
                if (type.IsAbstract || type.IsGenericType || type.IsInterface)
                    continue;
                
                // Check if the type has a public parameterless constructor
                // (MonoBehaviour doesn't need one, Unity handles it specially)
                if (type.IsSubclassOf(typeof(MonoBehaviour)))
                {
                    componentTypes.Add(type);
                }
                else
                {
                    // For non-MonoBehaviour components, check for a public constructor
                    var constructors = type.GetConstructors(BindingFlags.Public | BindingFlags.Instance);
                    if (constructors.Any(c => c.GetParameters().Length == 0))
                    {
                        componentTypes.Add(type);
                    }
                }
            }
            
            // Sort by full name for easier browsing
            componentTypes.Sort((a, b) => string.Compare(a.FullName, b.FullName, StringComparison.Ordinal));
            
            return componentTypes;
        }

        private class SceneEdit
        {
            public string editType;

            // delete
            public string referenceIdToDelete;

            // setProperty
            public string referenceIdOfObjectWithPropertyToSet;
            public string nameOfPropertyToSet;
            public object newPropertyValue;

            // createGameObject
            public string referenceIdOfParentGameObject;
            public string nameOfGameObjectToCreate;

            // addComponent
            public string referenceIdOfGameObjectToAddComponent;
            public string componentTypeToAdd;
        }
    }
}