using UnityEngine;

namespace OxRacing
{
    public class GarageManager : MonoBehaviour
    {
        public bool UpgradeEngine()
        {
            int cost = 250 * SaveSystem.Data.engineLevel;
            if (SaveSystem.Data.coins < cost) return false;
            SaveSystem.Data.coins -= cost;
            SaveSystem.Data.engineLevel++;
            SaveSystem.Save();
            return true;
        }

        public bool UpgradeTires()
        {
            int cost = 200 * SaveSystem.Data.tireLevel;
            if (SaveSystem.Data.coins < cost) return false;
            SaveSystem.Data.coins -= cost;
            SaveSystem.Data.tireLevel++;
            SaveSystem.Save();
            return true;
        }
    }
}
