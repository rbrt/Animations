Shader "Unlit/GhostBody"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Color ("Color", Color) = (1,1,1,1)
	}
	SubShader
	{
		Tags { "RenderType"="Transparent" "IgnoreProjector"="True" "RenderQueue"="Transparent" }
		LOD 100
		Cull Off
		Blend SrcAlpha OneMinusSrcAlpha

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog

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
			float4 _Color;

			v2f vert (appdata v){
				v2f o;
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				if (v.vertex.x > .8){
					v.vertex.x += sin(_Time.z * 10 + v.vertex.y * 10) * .1;
				}

				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				return o;
			}

			fixed4 frag (v2f i) : SV_Target{
				fixed4 col = tex2D(_MainTex, i.uv) * _Color;
				return col;
			}
			ENDCG
		}
	}
}
