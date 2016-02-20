using UnityEngine;
using UnityEngine.UI;
#if UNITY_EDITOR
using UnityEditor;
#endif
using System.Collections.Generic;
using System.Collections;
using System.Linq;
using System.IO;


public class DataGhostText : MonoBehaviour {

	[SerializeField] protected Text text;
	[SerializeField] protected Image cursor;

	string ghostText = "DATA GHOST";

	RectTransform cursorRect;
	Vector2 baseCursorPos;

	void Awake(){
		cursorRect = cursor.GetComponent<RectTransform>();
		baseCursorPos = cursorRect.anchoredPosition;

		this.StartSafeCoroutine(DisplayText());
		this.StartSafeCoroutine(FlashCursor());
	}

	IEnumerator DisplayText(){
		while (true){
			text.text = "";
			yield return new WaitForSeconds(.2f);

			for (int i = 0; i <= ghostText.Length; i++){
				text.text = ghostText.Substring(0,i);

				float offset = (cursorRect.rect.width + 5) * i;
				var pos = cursorRect.anchoredPosition;
				pos.x = baseCursorPos.x + offset;
				cursorRect.anchoredPosition = pos;

				if (i % 3 == 0 && i < 7){
					yield return new WaitForSeconds(.4f);
				}
				else {
					yield return new WaitForSeconds(.1f);
				}

			}

			yield return new WaitForSeconds(3);
		}
	}

	IEnumerator FlashCursor(){
		while (true){
			cursor.enabled = true;
			yield return new WaitForSeconds(.4f);
			cursor.enabled = false;
			yield return new WaitForSeconds(.4f);
		}
	}
}
