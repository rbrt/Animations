using UnityEngine;
using UnityEngine.UI;
#if UNITY_EDITOR
using UnityEditor;
#endif
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.IO;

public class PingPongRotate : MonoBehaviour {

    [SerializeField] protected float interval;
    [SerializeField] protected Vector3 rotationVector;

    void Awake(){
        this.StartSafeCoroutine(PingPongRotation());
    }

    IEnumerator PingPongRotation(){
        while (true){
            for (float i = 0; i < 1; i += Time.deltaTime / interval){
                transform.Rotate(rotationVector);
                yield return null;
            }
            for (float i = 0; i < 1; i += Time.deltaTime / interval){
                transform.Rotate(-rotationVector);
                yield return null;
            }
        }
    }
}
