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

    void Update(){
        transform.Rotate(0,-1.5f,0);
    }

}
