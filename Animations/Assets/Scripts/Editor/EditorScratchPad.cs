using UnityEngine;
using UnityEditor;
using System.Collections;
using System.Linq;

public class EditorScratchPad : MonoBehaviour {

	[MenuItem("Custom/BirdParent")]
	public static void BirdParent(){
		FindObjectsOfType<Bird>().ToList().ForEach(bird => {
			GameObject intermediate = new GameObject("BirdParent");
			intermediate.transform.parent = bird.transform.parent;
			intermediate.transform.position = bird.transform.position;
			intermediate.transform.localScale = bird.transform.localScale;
			intermediate.transform.rotation = bird.transform.rotation;
			bird.transform.parent = intermediate.transform;
		});
	}
}
