using UnityEngine;

namespace OxRacing
{
    public class ChaseCamera : MonoBehaviour
    {
        public Transform target;
        public Vector3 offset = new Vector3(0f, 4f, -8f);
        public float positionSmooth = 8f;
        public float rotationSmooth = 8f;

        void LateUpdate()
        {
            if (!target) return;
            Vector3 wanted = target.TransformPoint(offset);
            transform.position = Vector3.Lerp(transform.position, wanted, positionSmooth * Time.deltaTime);
            Quaternion wantedRot = Quaternion.LookRotation(target.position + target.forward * 8f - transform.position, Vector3.up);
            transform.rotation = Quaternion.Slerp(transform.rotation, wantedRot, rotationSmooth * Time.deltaTime);
        }
    }
}
