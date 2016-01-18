using UnityEngine;
using UnityEngine.UI;
#if UNITY_EDITOR
using UnityEditor;
#endif
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.IO;

public class BigDogController : MonoBehaviour {

    [SerializeField] protected Animator dogAnimator;
    [SerializeField] protected Renderer dogRenderer;
    [SerializeField] protected bool affectColor;

    void Start(){
        dogAnimator.SetTrigger("Sit");

        if (affectColor){
            StartCoroutine(TransitionColours(Random.Range(2f, 5f)));
        }

        dogRenderer.material = new Material(dogRenderer.material);
    }

    IEnumerator TransitionColours(float duration){
        Color current = dogRenderer.material.GetColor("_Color");
        Color newColor = new Color(Random.Range(0.0f,1.0f),Random.Range(0.0f,1.0f),Random.Range(0.0f,1.0f));

        for (float i = 0; i < 1; i += Time.deltaTime / duration){
            dogRenderer.material.SetColor("_Color", Color.Lerp(current, newColor, i));
            yield return null;
        }

        StartCoroutine(TransitionColours(Random.Range(2f, 5f)));
    }

}
