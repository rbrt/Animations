using UnityEngine;
using UnityEngine.UI;
#if UNITY_EDITOR
using UnityEditor;
#endif
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.IO;

public class AffectRepeat : MonoBehaviour {

    Renderer targetRenderer;
    [SerializeField] protected float interval;
    [SerializeField] protected float cap = 100;

    void Awake(){
        targetRenderer = GetComponent<Renderer>();
        targetRenderer.material = new Material(targetRenderer.material);
        this.StartSafeCoroutine(Repeat());
    }

    IEnumerator Repeat(){
        while (true){
            for (float i = 0; i < 1; i += Time.deltaTime / interval){
                targetRenderer.material.SetFloat("_Repeat", i * cap);
                yield return null;
            }
            for (float i = 0; i < 1; i += Time.deltaTime / interval){
                targetRenderer.material.SetFloat("_Repeat", (1 - i) * cap);
                yield return null;
            }
        }
    }
}
