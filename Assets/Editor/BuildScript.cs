#if UNITY_EDITOR
using UnityEditor;
using UnityEditor.Build.Reporting;
using UnityEngine;
using System.IO;

namespace OxRacing.Editor
{
    public static class BuildScript
    {
        public static void BuildAndroid()
        {
            CreateSceneIfMissing();

            Directory.CreateDirectory("build/Android");

            var options = new BuildPlayerOptions
            {
                scenes = new[] { "Assets/Scenes/MVP.unity" },
                locationPathName = "build/Android/OxRacing.apk",
                target = BuildTarget.Android,
                options = BuildOptions.None
            };

            var report = BuildPipeline.BuildPlayer(options);

            if (report.summary.result != BuildResult.Succeeded)
            {
                throw new System.Exception(
                    "OxRacing Android build failed: " + report.summary.result
                );
            }

            Debug.Log("OxRacing APK successfully built.");
        }

        static void CreateSceneIfMissing()
        {
            const string scenePath = "Assets/Scenes/MVP.unity";

            if (File.Exists(scenePath))
            {
                Debug.Log("MVP scene already exists.");
                return;
            }

            Debug.Log("MVP scene missing. Generating it automatically...");

            OxRacingSceneBuilder.CreateMVPScene();

            AssetDatabase.SaveAssets();
            AssetDatabase.Refresh();

            if (!File.Exists(scenePath))
            {
                throw new System.Exception(
                    "MVP scene generation failed. File was not created: " + scenePath
                );
            }

            Debug.Log("MVP scene generated successfully.");
        }
    }
}
#endif
