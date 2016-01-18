Shader "UI/DogFill"
{
	Properties
	{
		_Color ("Color", Color) = (1,1,1,1)
		_FillColor ("FillColor", Color) = (1,1,1,1)
		_FillAmount ("FillAmount", Range(0,1)) = 0
	}
	SubShader
	{
		Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
		Blend SrcAlpha OneMinusSrcAlpha
		Cull Off

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal: NORMAL;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float4 fillColor: TEXCOORD0;
				float4 color : COLOR;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float4 _Color;
			float4 _FillColor;
			float _FillAmount;

			v2f vert (appdata v){
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				float3 viewDirection = normalize(WorldSpaceViewDir(v.vertex));

				float angle = (1 - saturate(dot(viewDirection, UnityObjectToWorldNormal(v.normal)))) + .5;

				fixed4 colorA = 0;

				o.color = _Color * angle;
				o.fillColor = 0;
				if (v.vertex.z > 1.25 - _FillAmount * 3.1){
					o.fillColor = _FillColor;
				}
				return o;
			}

			fixed4 frag (v2f i) : COLOR {
				fixed4 color = i.color + i.fillColor;
				return color;
			}
			ENDCG
		}
	}
}
