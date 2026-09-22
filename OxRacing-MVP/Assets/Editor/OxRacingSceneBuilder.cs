#if UNITY_EDITOR
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;

namespace OxRacing.Editor
{
    public static class OxRacingSceneBuilder
    {
        [MenuItem("OxRacing/Create MVP Scene")]
        public static void Create()
        {
            var scene = EditorSceneManager.NewScene(NewSceneSetup.EmptyScene, NewSceneMode.Single);

            var bootstrap = new GameObject("GameBootstrap");
            bootstrap.AddComponent<GameBootstrap>();

            var ground = GameObject.CreatePrimitive(PrimitiveType.Cube);
            ground.name = "Track";
            ground.transform.position = new Vector3(0,-0.5f,0);
            ground.transform.localScale = new Vector3(120,1,500);

            var car = GameObject.CreatePrimitive(PrimitiveType.Cube);
            car.name = "PlayerCar";
            car.transform.position = new Vector3(0,1,0);
            car.transform.localScale = new Vector3(2,0.8f,4);
            var body = car.AddComponent<Rigidbody>();
            body.mass = 1200f;
            var controller = car.AddComponent<CarController>();
            car.AddComponent<PlayerCarInput>();

            var camObj = new GameObject("ChaseCamera");
            var cam = camObj.AddComponent<Camera>();
            camObj.AddComponent<ChaseCamera>().target = car.transform;
            camObj.transform.position = new Vector3(0,5,-10);

            var lightObj = new GameObject("Directional Light");
            var light = lightObj.AddComponent<Light>();
            light.type = LightType.Directional;
            light.intensity = 1.2f;
            light.transform.rotation = Quaternion.Euler(50,-30,0);

            EditorSceneManager.SaveScene(scene, "Assets/Scenes/MVP.unity");
            AssetDatabase.SaveAssets();
            Debug.Log("OxRacing MVP scene created.");
        }
    }
}
#endif
