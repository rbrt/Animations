using UnityEngine;
using System.Collections;

public class Bird : MonoBehaviour {

	protected Animator birdAnimator;
	const string glidebool = "Gliding";
	Transform target;

	float speed = 0;

	void Awake() {
		birdAnimator = GetComponent<Animator>();
		target = transform.parent;
		transform.parent = null;
		speed = Random.Range(.3f, .7f);
	}

	void Update(){
		transform.position = Vector3.MoveTowards(transform.position, target.position, speed);
		transform.rotation = Quaternion.RotateTowards(transform.rotation, target.rotation, 5);

		if (Vector3.Distance(transform.position, target.position) > 10){
			transform.position = target.position;
			transform.rotation = target.rotation;
		}
	}


	IEnumerator ChangeFlightAnimation(){
		bool gliding = false;
		while (true){
			yield return new WaitForSeconds(Random.Range(1, 5));
			birdAnimator.SetBool(glidebool, gliding);
			gliding = !gliding;

		}
	}

}
