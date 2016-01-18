using UnityEngine;
using UnityEngine.UI;
#if UNITY_EDITOR
using UnityEditor;
#endif
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.IO;

public class PourSauce : MonoBehaviour {

    [SerializeField] protected Renderer sauceRenderer;

    static string sauceDirection = "_TargetDirection",
                  saucePosition = "_TargetPosition";

    void Awake(){
        sauceRenderer.material = new Material(sauceRenderer.material);
    }


    void Update(){
        sauceRenderer.material.SetVector(sauceDirection, transform.forward);
        sauceRenderer.material.SetVector(saucePosition, transform.position);
    }

}
