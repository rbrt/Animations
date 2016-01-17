Shader "RimLight"
{
	Properties
	{
		_Color ("Color", Color) = (1,1,1,1)
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
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float4 color : COLOR;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float4 _Color;

			v2f vert (appdata v){
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				float3 viewDirection = normalize(WorldSpaceViewDir(v.vertex));

				float angle = (1 - saturate(dot(viewDirection, UnityObjectToWorldNormal(v.normal))));

				fixed4 colorA = 0;

				o.color = _Color * (angle + (sin(_Time.z) + 2.3) / 4);
				return o;
			}

			fixed4 frag (v2f i) : COLOR {
				fixed4 color = i.color;
				return color;
			}
			ENDCG
		}
	}
}
