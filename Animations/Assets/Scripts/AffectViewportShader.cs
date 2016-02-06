using UnityEngine;
using System.Collections;

public class AffectViewportShader : MonoBehaviour {

	[SerializeField] protected string param1;
	[SerializeField] protected float pingPongTime;

	Material mat;

	void Start () {
		mat = new Material(GetComponent<Renderer>().material);
		GetComponent<Renderer>().material = mat;
		this.StartSafeCoroutine(AffectProperty());
	}

	IEnumerator AffectProperty(){
		while (true){
			for (float i = 0; i < 1; i += Time.deltaTime / pingPongTime / 2){
				mat.SetFloat(param1, i);
				yield return null;
			}
			for (float i = 0; i < 1; i += Time.deltaTime / pingPongTime / 2){
				mat.SetFloat(param1, 1-i);
				yield return null;
			}	
		}

	}
}
