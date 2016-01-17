using UnityEngine;
using UnityEngine.UI;
#if UNITY_EDITOR
using UnityEditor;
#endif
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.IO;

public class DogController : MonoBehaviour {
    [SerializeField] protected Animator dogAnimator;

    static string lookTrigger = "Look",
                  sitBool = "Sit",
                  walkBool = "Walking";

    bool walking = false,
         sitting = false;

    float lastStartTime = 0,
          randomWait = 0;

    void Update(){
        if (Input.GetKeyDown(KeyCode.W)){
            StartWalking();
        }
        else if (Input.GetKeyDown(KeyCode.S)){
            StartWalking();
        }
        else if (Input.GetKeyDown(KeyCode.A)){
            StartWalking();
        }
        else if (Input.GetKeyDown(KeyCode.D)){
            StartWalking();
        }

        if (Input.GetKeyDown(KeyCode.C)){
            sitting = true;
        }

        if (Input.GetKeyUp(KeyCode.W)){
            StopWalking();
        }
        else if (Input.GetKeyUp(KeyCode.S)){
            StopWalking();
        }
        else if (Input.GetKeyUp(KeyCode.A)){
            StopWalking();
        }
        else if (Input.GetKeyUp(KeyCode.D)){
            StopWalking();
        }

        if (Input.GetKeyUp(KeyCode.C)){
            sitting = false;
        }

        dogAnimator.SetBool(walkBool, walking);
        dogAnimator.SetBool(sitBool, sitting);

        if (lastStartTime != 0 && Time.time - lastStartTime >= randomWait){
            dogAnimator.SetTrigger(lookTrigger);
            lastStartTime = Time.time;
        }
    }

    void StartWalking(){
        sitting = false;
        walking = true;
        lastStartTime = 0;
    }

    void StopWalking(){
        walking = false;
        lastStartTime = Time.time;
        randomWait = Random.Range(2,6);
    }

}
