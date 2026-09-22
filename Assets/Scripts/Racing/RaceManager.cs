using UnityEngine;

namespace OxRacing
{
    public class RaceManager : MonoBehaviour
    {
        public int totalLaps = 3;
        public int currentLap = 1;
        public int checkpointsPassed;
        public int checkpointsRequired = 4;
        public bool finished;

        public void PassCheckpoint()
        {
            if (finished) return;
            checkpointsPassed++;
            if (checkpointsPassed >= checkpointsRequired)
            {
                checkpointsPassed = 0;
                currentLap++;
                if (currentLap > totalLaps)
                {
                    finished = true;
                    Debug.Log("Race finished!");
                    SaveSystem.Save();
                }
            }
        }
    }
}
