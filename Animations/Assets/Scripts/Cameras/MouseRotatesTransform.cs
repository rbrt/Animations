using UnityEngine;
using UnityEngine.UI;
#if UNITY_EDITOR
using UnityEditor;
#endif
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.IO;

public class MouseRotatesTransform : MonoBehaviour {

    [SerializeField] protected Transform targetCamera;

    Quaternion initialRotation;

    float verticalInputBoost = 100;
    float horizontalInputBoost = 150;
    float horizontalRotation = 0;
    float verticalRotation = 0;

    void Awake(){
        initialRotation = transform.rotation;
    }

    void Update(){
        horizontalRotation += Input.GetAxis("Mouse X") * Time.deltaTime * horizontalInputBoost;
        verticalRotation += -Input.GetAxis("Mouse Y") * Time.deltaTime * verticalInputBoost;
        verticalRotation = Mathf.Clamp(verticalRotation, -20, 90);

        transform.rotation = Quaternion.Euler(verticalRotation, horizontalRotation, 0);

        if (Input.GetKeyDown(KeyCode.Space)){
            transform.rotation = initialRotation;
            horizontalRotation = 0;
            verticalRotation = 0;
        }

        float diff = Input.GetAxis("Mouse ScrollWheel") * 3;
        var temp = targetCamera.localPosition;
        temp.z = Mathf.Clamp(temp.z + diff, -15, -1);
        targetCamera.localPosition = temp;

        targetCamera.LookAt(transform);
    }

}
