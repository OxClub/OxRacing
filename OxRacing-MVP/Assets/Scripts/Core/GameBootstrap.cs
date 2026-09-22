using UnityEngine;

namespace OxRacing
{
    public class GameBootstrap : MonoBehaviour
    {
        private void Awake()
        {
            Application.targetFrameRate = 60;
            QualitySettings.vSyncCount = 0;
            Screen.sleepTimeout = SleepTimeout.NeverSleep;
            SaveSystem.Load();
        }
    }
}
