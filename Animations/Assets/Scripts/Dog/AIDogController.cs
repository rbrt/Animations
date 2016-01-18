using UnityEngine;
using UnityEngine.UI;
#if UNITY_EDITOR
using UnityEditor;
#endif
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.IO;

public class AIDogController : MonoBehaviour {

    List<Transform> dogTransforms;
    float forwardSpeed = 5;

    void Start(){
        dogTransforms = this.GetComponentsInChildren<Animator>().Select(x => x.transform).ToList();
        dogTransforms.ForEach(x => this.StartSafeCoroutine(WaitThenStart(x)));
    }

    IEnumerator WaitThenStart(Transform target){
        yield return new WaitForSeconds(Random.Range(.25f, 1f));
        target.GetComponent<Animator>().SetBool("Walking", true);
    }

    void Update(){
        dogTransforms.ForEach(x => {
                x.transform.position = x.transform.position - x.transform.forward * forwardSpeed * Time.deltaTime;
        });
    }

}
