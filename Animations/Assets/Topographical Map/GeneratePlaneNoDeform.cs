using UnityEngine;
using System.Collections;

public class GeneratePlaneNoDeform : MonoBehaviour {

	MeshFilter meshFilter;

	Vector3[] vertices;
	Vector2[] uvs;

	int[] triangles;

	[SerializeField] protected float scalingFactor;
	[SerializeField] protected float length;
	[SerializeField] protected float width;
	[SerializeField] protected int resX;
	[SerializeField] protected int resZ;

	void Awake(){
		GenerateNewPlane();
	}

	void GenerateNewPlane () {
		Mesh mesh = new Mesh();
		meshFilter = GetComponent<MeshFilter>();
		meshFilter.mesh = mesh;

		Vector3[] vertices = new Vector3[ resX * resZ ];
		for(int z = 0; z < resZ; z++)
		{
			// [ -length / 2, length / 2 ]
			float zPos = ((float)z / (resZ - 1) - .5f) * length;
			for(int x = 0; x < resX; x++)
			{
				// [ -width / 2, width / 2 ]
				float xPos = ((float)x / (resX - 1) - .5f) * width;
				vertices[ x + z * resX ] = CreateNewVector(xPos, zPos);
			}
		}

		Vector3[] normals = new Vector3[ vertices.Length ];
		for( int n = 0; n < normals.Length; n++ ){
			normals[n] = Vector3.up;
		}

		Vector2[] uvs = new Vector2[ vertices.Length ];
		for(int v = 0; v < resZ; v++)
		{
			for(int u = 0; u < resX; u++)
			{
				uvs[ u + v * resX ] = new Vector2( (float)u / ((resX) - 1), (float)v / (resZ - 1) );
			}
		}

		int nbFaces = (resX - 1) * (resZ - 1);
		int[] triangles = new int[ nbFaces * 6 ];
		int t = 0;
		for(int face = 0; face < nbFaces; face++ )
		{
			int i = face % (resX - 1) + (face / (resZ - 1) * resX);

			triangles[t++] = i + resX;
			triangles[t++] = i + 1;
			triangles[t++] = i;

			triangles[t++] = i + resX;
			triangles[t++] = i + resX + 1;
			triangles[t++] = i + 1;
		}
		mesh.vertices = vertices;
		mesh.normals = normals;
		mesh.uv = uvs;
		mesh.triangles = triangles;

		mesh.RecalculateBounds();
		mesh.Optimize();


		MeshFilter mf = GetComponent<MeshFilter>();

		// Create the duplicate game object
		//GameObject go = Instantiate (gameObject) as GameObject;
		//mf = go.GetComponent<MeshFilter>();
		mesh = Instantiate (mf.sharedMesh) as Mesh;
		mf.sharedMesh = mesh;

		//Process the triangles
		Vector3[] oldVerts = mesh.vertices;
		triangles = mesh.triangles;
		vertices = new Vector3[triangles.Length];
		for (int i = 0; i < triangles.Length; i++) {
			vertices[i] = oldVerts[triangles[i]];
			triangles[i] = i;
		}
		mesh.vertices = vertices;
		mesh.triangles = triangles;
		mesh.RecalculateBounds();
		mesh.RecalculateNormals();
		mesh.Optimize();

		Debug.Log("Generated mesh with " + vertices.Length + " vertices.");
	}

	Vector3 CreateNewVector(float x, float z){
		var vec =  new Vector3(x,
						   	   Mathf.PerlinNoise(x,z) * scalingFactor - scalingFactor,
						   	   z);
		return vec;
	}


}
