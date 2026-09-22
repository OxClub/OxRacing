using UnityEngine;

namespace OxRacing
{
    [RequireComponent(typeof(Rigidbody))]
    public class CarController : MonoBehaviour
    {
        [Header("Arcade Stats")]
        public float acceleration = 28f;
        public float maxSpeed = 42f;
        public float steering = 90f;
        public float grip = 7f;
        public float driftGrip = 2.2f;
        public float brakePower = 35f;
        public float nitroPower = 22f;

        [Header("Input")]
        [Range(-1f,1f)] public float steer;
        [Range(0f,1f)] public float throttle;
        [Range(0f,1f)] public float brake;
        public bool drift;
        public bool nitro;

        Rigidbody rb;
        float baseGrip;

        void Awake()
        {
            rb = GetComponent<Rigidbody>();
            baseGrip = grip;
            rb.centerOfMass = new Vector3(0f, -0.35f, 0f);
        }

        void FixedUpdate()
        {
            Vector3 localVelocity = transform.InverseTransformDirection(rb.linearVelocity);
            float speed = rb.linearVelocity.magnitude;

            float currentGrip = drift ? driftGrip : baseGrip;
            localVelocity.x = Mathf.Lerp(localVelocity.x, 0f, currentGrip * Time.fixedDeltaTime);
            rb.linearVelocity = transform.TransformDirection(localVelocity);

            if (throttle > 0f && speed < maxSpeed + (nitro ? nitroPower : 0f))
                rb.AddForce(transform.forward * acceleration * throttle, ForceMode.Acceleration);

            if (brake > 0f)
                rb.AddForce(-transform.forward * brakePower * brake, ForceMode.Acceleration);

            float steerFactor = Mathf.Clamp01(speed / 5f);
            float direction = Mathf.Sign(Vector3.Dot(rb.linearVelocity, transform.forward));
            float yaw = steer * steering * steerFactor * direction * Time.fixedDeltaTime;
            rb.MoveRotation(rb.rotation * Quaternion.Euler(0f, yaw, 0f));

            if (nitro && throttle > 0f)
                rb.AddForce(transform.forward * nitroPower, ForceMode.Acceleration);

            rb.AddForce(-rb.linearVelocity * 0.025f, ForceMode.Acceleration);
        }
    }
}
