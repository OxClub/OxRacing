#if UNITY_EDITOR
using UnityEditor;
using UnityEditor.Build.Reporting;
using System.IO;

namespace OxRacing.Editor
{
    public static class BuildScript
    {
        public static void BuildAndroid()
        {
            string[] scenes = { "Assets/Scenes/MVP.unity" };
            Directory.CreateDirectory("build/Android");

            var options = new BuildPlayerOptions
            {
                scenes = scenes,
                locationPathName = "build/Android/OxRacing.apk",
                target = BuildTarget.Android,
                options = BuildOptions.None
            };

            BuildReport report = BuildPipeline.BuildPlayer(options);
            if (report.summary.result != BuildResult.Succeeded)
                throw new System.Exception("Android build failed: " + report.summary.result);
        }
    }
}
#endif
