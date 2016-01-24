using UnityEngine;
using UnityEngine.UI;
#if UNITY_EDITOR
using UnityEditor;
#endif
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.IO;

[ExecuteInEditMode]
 public class EnableDepthTexture : MonoBehaviour
 {
     [Range(0f, 3f)]
     public float depthLevel = 0.5f;

     [Range(0,1)]
     public float depthTest = 0.5f;

     private Shader _shader;
     private Shader shader
     {
         get { return _shader != null ? _shader : (_shader = Shader.Find("Custom/RenderDepth")); }
     }

     private Material _material;
     private Material material
     {
         get
         {
             if (_material == null)
             {
                 _material = new Material(shader);
                 _material.hideFlags = HideFlags.HideAndDontSave;
             }
             return _material;
         }
     }

     private void Start ()
     {
         if (!SystemInfo.supportsImageEffects)
         {
             print("System doesn't support image effects");
             enabled = false;
             return;
         }
         if (shader == null || !shader.isSupported)
         {
             enabled = false;
             print("Shader " + shader.name + " is not supported");
             return;
         }

         // turn on depth rendering for the camera so that the shader can access it via _CameraDepthTexture
         GetComponent<Camera>().depthTextureMode = DepthTextureMode.Depth;
     }

     private void OnDisable()
     {
         if (_material != null)
             DestroyImmediate(_material);
     }

     private void OnRenderImage(RenderTexture src, RenderTexture dest)
     {
         if (shader != null)
         {
             material.SetFloat("_DepthLevel", depthLevel);
             material.SetFloat("_DepthTest", depthTest);
             Graphics.Blit(src, dest, material);
         }
         else
         {
             Graphics.Blit(src, dest);
         }
     }
 }
