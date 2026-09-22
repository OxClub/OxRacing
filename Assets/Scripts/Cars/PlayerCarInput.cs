using UnityEngine;

namespace OxRacing
{
    public class PlayerCarInput : MonoBehaviour
    {
        public CarController car;
        public bool useTilt = false;
        public float tiltSensitivity = 1.5f;

        void Awake()
        {
            if (!car) car = GetComponent<CarController>();
        }

        void Update()
        {
            float steer = Input.GetAxis("Horizontal");
            if (useTilt)
                steer = Mathf.Clamp(Input.acceleration.x * tiltSensitivity, -1f, 1f);

            car.steer = steer;
            car.throttle = Mathf.Clamp01(Input.GetAxis("Vertical"));
            car.brake = Input.GetKey(KeyCode.Space) ? 1f : 0f;
            car.drift = Input.GetKey(KeyCode.LeftShift);
            car.nitro = Input.GetKey(KeyCode.N);
        }
    }
}
