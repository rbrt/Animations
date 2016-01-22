using UnityEngine;
using UnityEngine.UI;
#if UNITY_EDITOR
using UnityEditor;
#endif
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.IO;

public class WhoWalksWho : MonoBehaviour {

    [SerializeField] protected Animator dogAnimator,
                                        personAnimator;

    [SerializeField] protected Transform personTarget,
                                         dogTarget,
                                         collarTarget,
                                         leashTarget,
                                         collar,
                                         leash;

    Vector3 personOriginal,
            dogOriginal,
            collarOriginal;

    Quaternion originalCollarRotation;
    Vector3 originalCollarScale;

    Transform dogTransform;
    Transform personTransform;
    Transform collarOriginalParent;
    Transform leashOriginalParent;

    static string dogWalkBool = "BiPedal",
                  personCrawlBool = "Crawl";

    float switchTime = 2,
          switchAnimationTime = .5f;

    void Awake(){
        dogTransform = dogAnimator.transform;
        personTransform = personAnimator.transform;

        collarOriginalParent = collar.parent;
        leashOriginalParent = leash.parent;

        personOriginal = personTransform.position;
        dogOriginal = dogTransform.position;

        originalCollarRotation = collar.rotation;
        originalCollarScale = collar.localScale;

        this.StartSafeCoroutine(SwitchRoles());
    }


    IEnumerator SwitchRoles(){
        while (true){
            var dog = dogAnimator.GetBool(dogWalkBool);
            dogAnimator.SetBool(dogWalkBool, !dog);
            var person = personAnimator.GetBool(personCrawlBool);
            personAnimator.SetBool(personCrawlBool, !person);

            yield return this.StartSafeCoroutine(SwapPositions(!dog));

            yield return new WaitForSeconds(switchTime - switchAnimationTime);
        }
    }

    IEnumerator SwapPositions(bool target){
        if (target){
            collar.rotation = originalCollarRotation;
            collar.localScale = originalCollarScale;
            collar.SetParent(collarTarget);
            leash.SetParent(leashTarget);
        }
        else{
            collar.SetParent(collarOriginalParent);
            leash.SetParent(leashOriginalParent);
        }

        Vector3 currentLeash = leash.localPosition;
        Vector3 currentCollar = collar.localPosition;

        for (float i = 0; i < 1; i += Time.deltaTime / switchAnimationTime){
            if (target){
                dogTransform.position = Vector3.Lerp(dogOriginal, dogTarget.position, i);
                personTransform.position = Vector3.Lerp(personOriginal, personTarget.position, i);
            }
            else{
                dogTransform.position = Vector3.Lerp(dogTarget.position, dogOriginal, i);
                personTransform.position = Vector3.Lerp(personTarget.position, personOriginal, i);
            }

            leash.localPosition = Vector3.Lerp(currentLeash, Vector3.zero, i);
            collar.localPosition = Vector3.Lerp(currentCollar, Vector3.zero, i);

            yield return null;
        }

        if (target){
            dogTransform.position = dogTarget.position;
            personTransform.position = personTarget.position;
        }
        else{
            dogTransform.position = dogOriginal;
            personTransform.position = personOriginal;
        }

        leash.localPosition = Vector3.zero;
        collar.localPosition = Vector3.zero;
    }

}
