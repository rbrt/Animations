using UnityEngine;
using UnityEngine.UI;
#if UNITY_EDITOR
using UnityEditor;
#endif
using System.Collections.Generic;
using System.Collections;
using System.Linq;
using System.IO;


public class ChangePlaneToWireframe : MonoBehaviour {

	MeshFilter filter;
	Mesh mesh;

	[ContextMenu("Set To Wireframe")]
	public void SetToWireFrame(){
		var tempFilter = GetComponent<MeshFilter>();
		var indices = tempFilter.mesh.GetIndices(0);

		tempFilter.mesh.SetIndices(indices, MeshTopology.Lines, 0);
	}

	void Awake(){
		filter = GetComponent<MeshFilter>();
		this.StartSafeCoroutine(MessAbout());
	}

	IEnumerator MessAbout(){
		List<int> indices;
		List<Vector3> targetVertices;
		List<Vector3> baseVertices;

		int shuffleCount = 4;
		while (true){
			var vertices = filter.mesh.vertices;

			indices = new List<int>();
			targetVertices = new List<Vector3>();
			baseVertices = new List<Vector3>();

			for (int i = 0; i < shuffleCount; i++){
				int index = Random.Range(0, vertices.Length);
				while (indices.Contains(index)){
					index = Random.Range(0, vertices.Length);
				}
				indices.Add(index);
				var tempVertex = vertices[Random.Range(0, vertices.Length)];

				targetVertices.Add(tempVertex);
				baseVertices.Add(vertices[index]);
			}

			for (float i = 0; i < 1; i += Time.deltaTime / 1.5f){
				for (int j = 0; j < indices.Count; j++){
					vertices[indices[j]] = Vector3.Lerp(baseVertices[j], targetVertices[j], i);
				}
				filter.mesh.vertices = vertices;
				yield return null;
			}
			yield return new WaitForSeconds(.2f);

		}
	}

}
