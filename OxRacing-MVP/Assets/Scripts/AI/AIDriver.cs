using UnityEngine;

namespace OxRacing
{
    public class AIDriver : MonoBehaviour
    {
        public CarController car;
        public Transform[] waypoints;
        public float waypointDistance = 8f;
        public float steeringGain = 1.4f;
        public float cruiseThrottle = 0.8f;
        int index;

        void Awake()
        {
            if (!car) car = GetComponent<CarController>();
        }

        void FixedUpdate()
        {
            if (waypoints == null || waypoints.Length == 0) return;

            Transform target = waypoints[index];
            Vector3 local = transform.InverseTransformPoint(target.position);
            car.steer = Mathf.Clamp(local.x / waypointDistance * steeringGain, -1f, 1f);
            car.throttle = cruiseThrottle;
            car.brake = 0f;
            car.drift = Mathf.Abs(car.steer) > 0.65f;
            car.nitro = false;

            if (Vector3.Distance(transform.position, target.position) < waypointDistance)
                index = (index + 1) % waypoints.Length;
        }
    }
}
