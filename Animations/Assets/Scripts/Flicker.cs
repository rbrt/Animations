using UnityEngine;
using UnityEngine.UI;
#if UNITY_EDITOR
using UnityEditor;
#endif
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.IO;

public class Flicker : MonoBehaviour {

    [SerializeField] protected Renderer targetRenderer;

    void Start(){
        targetRenderer.material = new Material(targetRenderer.material);
        this.StartSafeCoroutine(AnimateFlicker());
    }

    IEnumerator AnimateFlicker(){
        int steps = 3;
        for (int i = 0; i < steps; i++){
            targetRenderer.enabled = false;
            yield return new WaitForSeconds(Random.Range(.025f, .5f));
            targetRenderer.enabled = true;
            yield return new WaitForSeconds(Random.Range(.01f, .07f));
        }
        yield return new WaitForSeconds(Random.Range(.2f, .6f));

        for (int j = 0; j < 3; j++){
            for (int i = 0; i < steps; i++){
                targetRenderer.material.SetFloat("_Switch", 1);
                yield return new WaitForSeconds(Random.Range(.025f, .5f));
                targetRenderer.material.SetFloat("_Switch", 0);
                yield return new WaitForSeconds(Random.Range(.01f, .5f));
            }
            yield return new WaitForSeconds(Random.Range(.2f, .6f));
        }

    }

}
