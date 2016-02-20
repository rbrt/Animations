Shader "Unlit/GhostParticles"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Color ("Color", Color) = (1,1,1,1)
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100
		Blend SrcAlpha OneMinusSrcAlpha
		ZWrite Off

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
				float4 color : COLOR;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float3 pos: TEXCOORD1;
				float4 col: TEXCOORD2;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float4 _Color;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.pos = o.vertex.xyz;
				o.col = v.color;
				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = _Color;
				col.a = .5;

				if (i.pos.x > 1){
					if (i.col.x + i.col.y + i.col.z > 1.5){
						i.uv.x = i.uv.x / 2;
					}
					else{
						i.uv.x = (i.uv.x + 1) / 2;
					}
					fixed4 tempCol = tex2D(_MainTex, i.uv) * _Color;
					float interpolation = i.pos.x / 3;
					col = lerp(col, tempCol, interpolation);
					if (i.col.x + i.col.y + i.col.z < 1){
						col.a = 0;
					}
				}

				return col;
			}
			ENDCG
		}
	}
}
