using UnityEngine;
using UnityEngine.UI;
#if UNITY_EDITOR
using UnityEditor;
#endif
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.IO;

public class AffectHueShift : MonoBehaviour {

    Renderer targetRenderer;
    [SerializeField] protected float interval;
    [SerializeField] protected float intervalB;
    [SerializeField] protected float cap = 360;
    [SerializeField] protected float capB = 300;

    void Awake(){
        targetRenderer = GetComponent<Renderer>();
        targetRenderer.material = new Material(targetRenderer.material);
        this.StartSafeCoroutine(Shift());
        //this.StartSafeCoroutine(Crush());
    }

    IEnumerator Shift(){
        while (true){
            for (float i = 0; i < 1; i += Time.deltaTime / interval){
                targetRenderer.material.SetFloat("_Shift", i * cap);
                yield return null;
            }
        }
    }

    IEnumerator Crush(){
        while (true){
            for (float i = 0; i < 1; i += Time.deltaTime / intervalB){
                targetRenderer.material.SetFloat("_Crush", i * i * capB + 25);
                yield return null;
            }
            for (float i = 0; i < 1; i += Time.deltaTime / intervalB / 2){
                targetRenderer.material.SetFloat("_Crush", capB + 25 - (i * i * capB + 25));
                yield return null;
            }
        }
    }
}
