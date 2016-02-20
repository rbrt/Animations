using UnityEngine;
using UnityEngine.UI;
#if UNITY_EDITOR
using UnityEditor;
#endif
using System.Collections.Generic;
using System.Collections;
using System.Linq;
using System.IO;


public class GhostTrailRenderer : MonoBehaviour {

	LineRenderer line;
	[SerializeField] protected int vertexCount = 50;

	void Awake(){
		line = GetComponent<LineRenderer>();
		line.SetVertexCount(vertexCount);
		var pos = transform.position;

		for (int i = 0; i < vertexCount; i++){
			line.SetPosition(i, pos);
			pos += -transform.up * .1f;
		}
	}

	void Start () {

	}

	void Update () {
		for (int i = 0; i < vertexCount; i++){
			var pos = transform.position + (-transform.up * .1f) * i;
			pos += transform.forward * Mathf.Sin(Time.time * 10 - pos.x * 5) * .5f;
			line.SetPosition(i, pos);
		}
	}
}
