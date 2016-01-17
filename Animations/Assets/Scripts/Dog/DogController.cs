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
    [SerializeField] protected Renderer dogRenderer;

    static string lookTrigger = "Look",
                  sitBool = "Sit",
                  walkBool = "Walking",
                  glitchTrigger = "_RuinMesh",
                  wireframeTrigger = "_WireframeOn";

    bool walking = false,
         sitting = false,
         glitching = false;

    float lastStartTime = 0,
          randomWait = 0;

    float forwardSpeed = 10;

    SafeCoroutine glitchCoroutine;

    void Awake(){
        dogRenderer.material = new Material(dogRenderer.material);
    }

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
        else if (Input.GetKeyDown(KeyCode.D)){
            StartWalking();
        }
        else if (Input.GetKeyDown(KeyCode.Q)){
            AffectGlitch();
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

        if (walking){
            transform.position = transform.position - transform.forward * forwardSpeed * Time.deltaTime;
        }
    }

    void AffectGlitch(){
        if (glitching){
            StopGlitching();
        }
        else{
            StartGlitching();
        }
    }

    void StartGlitching(){
        glitching = true;
        glitchCoroutine = this.StartSafeCoroutine(GlitchOut());
    }

    void StopGlitching(){
        glitching = false;
        dogRenderer.material.SetFloat(glitchTrigger, 0f);
        glitchCoroutine.Stop();
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

    IEnumerator GlitchOut(){
        while (true){
            //yield return this.StartSafeCoroutine(WireframeGlitch());

            float choice = Random.Range(0, 1000);

            if (choice > 250){
                yield return this.StartSafeCoroutine(EnableShaderGlitch(3f, 5f, 0f, 0f, 1));
            }
            else if (choice > 500){
                yield return this.StartSafeCoroutine(EnableShaderGlitch(.05f,.075f, .05f, .075f, 10));
            }
            else if (choice > 750){

            }
            else {
                yield return this.StartSafeCoroutine(StallAnimator());
            }
            yield return null;
        }
    }

    IEnumerator EnableShaderGlitch(float a, float b, float c, float d, int steps){
        for (int i = 0; i < steps; i++){
            dogRenderer.material.SetFloat(glitchTrigger, 1f);
            yield return new WaitForSeconds(Random.Range(a,b));
            dogRenderer.material.SetFloat(glitchTrigger, 0f);
            yield return new WaitForSeconds(Random.Range(c,d));
        }
    }

    IEnumerator WireframeGlitch(){
        for (int steps = 0; steps < 3; steps++){
            for (int i = 0; i < 10; i++){
                dogRenderer.material.SetFloat(wireframeTrigger, 1f);
                yield return new WaitForSeconds(Random.Range(.025f,.2f - i * .005f));
                dogRenderer.material.SetFloat(wireframeTrigger, 0f);
                yield return new WaitForSeconds(Random.Range(.025f,.2f));
            }
            yield return new WaitForSeconds(Random.Range(1,3));
        }
    }

    IEnumerator StallAnimator(){
        for (int steps = 0; steps < 5; steps++){
            float playback = dogAnimator.GetCurrentAnimatorStateInfo(0).normalizedTime;
            int hash = dogAnimator.GetCurrentAnimatorStateInfo(0).shortNameHash;
            for (int i = 0; i < 5; i++){
                dogAnimator.CrossFade(hash, 0f, layer: -1, normalizedTime: playback);
                yield return new WaitForSeconds(.05f);
                playback = Random.Range(0f, 1f);
            }
            yield return new WaitForSeconds(.1f);
        }
    }
}
