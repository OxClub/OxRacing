using System.IO;
using UnityEngine;

namespace OxRacing
{
    [System.Serializable]
    public class PlayerSaveData
    {
        public int coins = 1000;
        public int selectedCar = 0;
        public int engineLevel = 1;
        public int tireLevel = 1;
        public int nitroLevel = 1;
        public int handlingLevel = 1;
        public float bestTime = -1f;
    }

    public static class SaveSystem
    {
        static string PathName => System.IO.Path.Combine(Application.persistentDataPath, "oxracing_save.json");
        public static PlayerSaveData Data { get; private set; } = new PlayerSaveData();

        public static void Load()
        {
            if (!File.Exists(PathName))
            {
                Data = new PlayerSaveData();
                return;
            }

            try { Data = JsonUtility.FromJson<PlayerSaveData>(File.ReadAllText(PathName)); }
            catch { Data = new PlayerSaveData(); }
        }

        public static void Save()
        {
            File.WriteAllText(PathName, JsonUtility.ToJson(Data, true));
        }
    }
}
