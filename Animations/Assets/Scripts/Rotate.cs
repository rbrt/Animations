using UnityEngine;
using UnityEngine.UI;
#if UNITY_EDITOR
using UnityEditor;
#endif
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.IO;

public class Rotate : MonoBehaviour {

    float speed = 0;
    void Awake() {
        speed = Random.Range(-.5f, .5f);
    }

    void Update(){
        transform.Rotate(0,0,speed);
    }

}
