using UnityEngine;
using System.Collections;

public class AnimateLimeTime : MonoBehaviour {

	[SerializeField] protected Camera targetCamera;

	[SerializeField] protected Animator knifeAnimator;
	[SerializeField] protected Animator limeAnimator;
	[SerializeField] protected Animator glassAnimator;
	[SerializeField] protected Animator cameraAnimator;


	static string knifeTrigger = "Slice",
				  limeRaiseTrigger = "Raise",
				  limeSplit = "Split",
				  limeMove = "MoveToGlass",
				  limeSqueeze = "Squeeze",
				  fillGlass = "FillGlass",
				  cameraSwoop = "Swoop";

	void Awake () {
		this.StartSafeCoroutine(Sequence());
	}

	IEnumerator Sequence(){
		knifeAnimator.SetTrigger(knifeTrigger);
		limeAnimator.SetTrigger(limeRaiseTrigger);

		yield return new WaitForSeconds(1.25f);

		limeAnimator.SetTrigger(limeSplit);

		yield return new WaitForSeconds(.7f);

		limeAnimator.SetTrigger(limeMove);
		cameraAnimator.SetTrigger(cameraSwoop);

		yield return new WaitForSeconds(.5f);

		limeAnimator.SetTrigger(limeSqueeze);
		glassAnimator.SetTrigger(fillGlass);
	}
}
