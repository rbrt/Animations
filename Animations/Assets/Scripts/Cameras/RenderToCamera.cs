using UnityEngine;
using System.Collections;

[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]
public class RenderToCamera : MonoBehaviour {

    [SerializeField] protected RenderTexture sourceRenderTexture;
    [SerializeField] protected Shader shader;

    protected Material material;

    void OnRenderImage(RenderTexture source, RenderTexture destination){

        if (material == null){
            material = new Material(shader);
            material.hideFlags = HideFlags.DontSave;
        }

        Graphics.Blit (sourceRenderTexture, destination, material);

    }

}
