Shader "Custom/ProceduralSky"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float4 c0 : TEXCOORD1;
				float4 c1 : TEXCOORD2;
				float3 t0 : TEXCOORD3;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;

			uniform float3 v3InvWavelength; // 1 / pow(wavelength, 4) for RGB

			uniform float fKrESun;          // Kr * ESun

			uniform float fKmESun;          // Km * ESun
			uniform float fKr4PI;           // Kr * 4 * PI
			uniform float fKm4PI;           // Km * 4 * PI

			uniform float fScale;           // 1 / (fOuterRadius - fInnerRadius)
			uniform float fScaleOverScaleDepth; // fScale / fScaleDepth

			uniform float fScaleDepth;
			uniform float fInvScaleDepth;
			uniform float fSamples;
			uniform float nSamples;

			const float g = -0.95;
			const float g2 = g*g;

			float getNearIntersection(float3 pos, float3 ray, float distance2, float radius2) {
			    float B = 2.0 * dot(pos, ray);
			    float C = distance2 - radius2;
			    float det = max(0.0, B*B - 4.0 * C);
			    return 0.5 * (-B - sqrt(det));
			}

			float scale(float fCos) {
				float x = 1.0 - fCos;
				return fScaleDepth * exp(-0.00287 + x*(0.459 + x*(3.83 + x*(-6.80 + x*5.25))));
			}

			v2f vert (appdata v){
				// Get the ray from the camera to the vertex and its length (which
				// is the far point of the ray passing through the atmosphere)
				float3 v3Pos = v.vertex.xyz;
				float3 v3Ray = v3Pos - _WorldSpaceCameraPos;
				float fFar = length(v3Ray);
				v3Ray /= fFar;

				// Calculate the closest intersection of the ray with
				// the outer atmosphere (point A in Figure 16-3)

				float fCameraHeight2 = _WorldSpaceCameraPos.y * _WorldSpaceCameraPos.y;
				float fOuterRadius = 45;
				float fOuterRadius2 = fOuterRadius * fOuterRadius;
				float fInnerRadius = 70;
				float fInnerRadius2 = fInnerRadius * fInnerRadius;

				float fNear = getNearIntersection(_WorldSpaceCameraPos, v3Ray, fCameraHeight2, fOuterRadius2);

				// Calculate the ray's start and end positions in the atmosphere,
				// then calculate its scattering offset

				float3 v3Start = _WorldSpaceCameraPos + v3Ray * fNear;
				fFar -= fNear;
				float fStartAngle = dot(v3Ray, v3Start) / fOuterRadius;
				float fStartDepth = exp(-fInvScaleDepth);
				float fStartOffset = fStartDepth * scale(fStartAngle);


				// Initialize the scattering loop variables
				float fSampleLength = fFar / fSamples;
				float fScaledLength = fSampleLength * fScale;
				float3 v3SampleRay = v3Ray * fSampleLength;
				float3 v3SamplePoint = v3Start + v3SampleRay * 0.5;


				// Now loop through the sample points
				float3 v3FrontColor = float3(0.0, 0.0, 0.0);

				float3 v3LightDir = _WorldSpaceLightPos0 - _WorldSpaceCameraPos;

				for(int i=0; i<nSamples; i++) {
					float fHeight = length(v3SamplePoint);
					float fDepth = exp(fScaleOverScaleDepth * (fInnerRadius - fHeight));
					float fLightAngle = dot(v3LightDir, v3SamplePoint) / fHeight;
					float fCameraAngle = dot(v3Ray, v3SamplePoint) / fHeight;
					float fScatter = (fStartOffset + fDepth * (scale(fLightAngle) * scale(fCameraAngle)));
					float3 v3Attenuate = exp(-fScatter * (v3InvWavelength * fKr4PI + fKm4PI));

					v3FrontColor += v3Attenuate * (fDepth * fScaledLength);
					v3SamplePoint += v3SampleRay;
				}

				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);

				float3 color1 = v3FrontColor * (v3InvWavelength * fKrESun);
				float3 color2 = v3FrontColor * fKmESun;
				float3 direction = _WorldSpaceCameraPos - v3Pos;

				float fCos = dot(_WorldSpaceLightPos0, direction) / length(direction);
				float fRayleighPhase = 0.75 * (1.0 + fCos*fCos);
				float fMiePhase = 1.5 * ((1.0 - g2) / (2.0 + g2)) * (1.0 + fCos*fCos) / pow(1.0 + g2 - 2.0*g*fCos, 1.5);

				o.c0.rgb = fRayleighPhase * color1 + fMiePhase * color2;
				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				return i.c0;
			}
			ENDCG
		}
	}
}
