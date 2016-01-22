using UnityEngine;
using UnityEngine.UI;
#if UNITY_EDITOR
using UnityEditor;
#endif
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.IO;

[RequireComponent(typeof(LineRenderer))]
public class Leash : MonoBehaviour {

    [SerializeField] protected Transform targetA,
                                         targetB;

    LineRenderer lineRenderer;

    void Awake(){
        lineRenderer = GetComponent<LineRenderer>();
    }

    void Update(){
        lineRenderer.SetPosition(0, targetA.position);
        lineRenderer.SetPosition(1, targetB.position);
    }

}
