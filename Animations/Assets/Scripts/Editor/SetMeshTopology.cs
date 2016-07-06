using UnityEngine;
using UnityEditor;
using System.Collections;

public class SetMeshTopology : MonoBehaviour {

    [MenuItem("Custom/Mesh/Set Mesh To Point Cloud")]
    public static void SetMeshToPointCloud()
    {
        if (Selection.activeGameObject != null && Selection.activeGameObject.GetComponent<MeshFilter>() != null)
        {
            var indices = Selection.activeGameObject.GetComponent<MeshFilter>().mesh.GetIndices(0);
            Selection.activeGameObject.GetComponent<MeshFilter>().mesh.SetIndices(indices, MeshTopology.Points, 0);
        }
    }
}
