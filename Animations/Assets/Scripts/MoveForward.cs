using UnityEngine;
using UnityEngine.UI;
#if UNITY_EDITOR
using UnityEditor;
#endif
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.IO;

public class MoveForward : MonoBehaviour {
    [SerializeField] protected float speed;
    [SerializeField] protected bool globalForward = false;

    void Update(){
        if (globalForward){
            transform.position = transform.position + Vector3.forward * Time.deltaTime * speed;
        }
        else{
            transform.position = transform.position + transform.forward * Time.deltaTime * speed;
        }
    }
}
