Shader "Custom/RenderDepth"
{
	Properties
	{
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_DepthLevel ("Depth Level", Range(1, 3)) = 1
		_DepthTest ("Depth Test", Range(0,1)) = 0
	}
	SubShader
	{
		Pass
		{
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			uniform sampler2D _MainTex;
			uniform sampler2D _CameraDepthTexture;
			uniform fixed _DepthLevel;
			uniform half4 _MainTex_TexelSize;

			float _DepthTest;

			struct appdata
			{
				float4 pos : POSITION;
				half2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				half2 uv : TEXCOORD0;
			};


			v2f vert(appdata i)
			{
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP, i.pos);
				o.uv = MultiplyUV(UNITY_MATRIX_TEXTURE0, i.uv);
				#if UNITY_UV_STARTS_AT_TOP
				if (_MainTex_TexelSize.y < 0)
						o.uv.y = 1 - o.uv.y;
				#endif


				return o;
			}

			float edgeDistort(float uvx){
				return sin(uvx * 10 + _Time.y * 5);
			}

			fixed4 frag(v2f o) : COLOR {
				float depth = UNITY_SAMPLE_DEPTH(tex2D(_CameraDepthTexture, o.uv));
				depth = pow(Linear01Depth(depth), _DepthLevel);

				fixed4 color = tex2D(_MainTex, o.uv);

				if (depth < _DepthTest + .02 * (edgeDistort(o.uv.x))){
					return color;
				}
				else{
					if (depth < _DepthTest + .02 * (edgeDistort(o.uv.x)) + .01){
						color.r += .5;
						color.g *= .5;
						color.b *= .5;
					}
					else{
						color.r += .3;
						color.g -= .3;
						color.b -= .3;
					}

					return color;
				}

				return color;
			}

			ENDCG
		}
	}
}
