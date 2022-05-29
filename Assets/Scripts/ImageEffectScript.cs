using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Camera))]
[ExecuteInEditMode]
[ImageEffectAllowedInSceneView]
public class ImageEffectScript : MonoBehaviour {

	public Material imageEffectMaterial;

	Camera cam;

	void OnRenderImage(RenderTexture src, RenderTexture dest) {
		if (imageEffectMaterial == null) {
			return;
        }

		if (cam == null) {
			cam = GetComponent<Camera>();
			cam.depthTextureMode |= DepthTextureMode.DepthNormals;
			imageEffectMaterial.SetFloat("_vFOV", cam.fieldOfView);
			imageEffectMaterial.SetFloat("_hFOV", Camera.VerticalToHorizontalFieldOfView(cam.fieldOfView, cam.aspect));
		}

		Graphics.Blit(src, dest, imageEffectMaterial);
	}
}
