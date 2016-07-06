Shader "Custom/VoronoiTest"
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
// Upgrade NOTE: excluded shader from DX11 and Xbox360 because it uses wrong array syntax (type[size] name)
#pragma exclude_renderers d3d11 xbox360
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
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}

			float3 palette(float t, float3 a, float3 b, float3 c, float3 d){
			    return a + b*cos( 6.28318*(c*t+d) );
			}

			float3 paletteConversion(float t){
				return palette(t, float3(0.5, 0.5, 0.5), float3(0.5, 0.5, 0.5), float3(2.0, 1.0, 0.0), float3(0.50, 0.20, 0.25));
			}

			fixed4 swirl(float2 uv, float2 effectParams){
				float theta = effectParams.x + _Time.z * .5;

				float centerCoordx = (uv.x * 2.0 - 1.0);
				float centerCoordy = (uv.y * 2.0 - 1.0);

				float len = sqrt(pow(centerCoordx, 2.0) + pow(centerCoordy, 2.0));

				float2 vecA = float2(centerCoordx, centerCoordy);
				float2 vecB = float2(len, 0);

				float initialValue = dot(vecA, vecB) / (len * 1.0);
				float degree = degrees(acos(initialValue));

				float thetamod = degree * len;

				// Input xy controls speed and intensity
				float intensity = effectParams.x * 20.0 + (_Time.z * 2 - 1) * .1;

				theta += thetamod * ((intensity) / 100.0);

				float2 newPoint = float2((cos(theta) * (uv.x * 2.0 - 1.0) + sin(theta) * (uv.y * 2.0 - 1.0) + 1.0)/2.0,
								  (-sin(theta) * (uv.x * 2.0 - 1.0) + cos(theta) * (uv.y * 2.0 - 1.0) + 1.0)/2.0);

				return tex2D(_MainTex, newPoint);
			}

			#define STEP 6

			fixed4 frag (v2f i) : SV_Target
			{
				float2[STEP] pos = float2[STEP](float2(.1,.1), float2(.3,.1), float2(.6,.6), float2(.8,.8), float2(.8,.1), float2(.9,.9));

				float4[STEP] coloring = float4[STEP](float4(1,1,1,1), float4(1,0,1,1), float4(1,1,0,1), float4(0,0,1,1), float4(1,0,0,1), float4(.5,.5,0,1));

				float dist = 100;
				float4 color = 1;
				for (int k = 0; k < STEP; k++){
					float current = distance(pos[k], i.uv);
					if (current < dist){
						dist = current;
						color = swirl(i.uv, fixed2(STEP/k * 360,0));
					}
				}

				return color;
			}
			ENDCG
		}
	}
}
