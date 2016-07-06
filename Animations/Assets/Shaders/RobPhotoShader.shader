Shader "Unlit/RobPhotoShader"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_CodeTex("Code", 2D) = "white" {}
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
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			sampler2D _CodeTex;
			float4 _MainTex_ST;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);
				fixed4 untouched = col;
				
				if (col.r + col.g + col.b > 2.1 )
				{
					col = tex2D(_MainTex, half2(sin(i.uv.x * 20) * 
												sin(i.uv.y + sin(_Time.y * i.uv.x)), 
												sin(i.uv.y * 10)));
					
					col.g *= sin(i.uv.y * 30 * _SinTime.x);
				}
				else if (dot(col.xyz, 1) > 1.9)
				{
					float2 tempUV = i.uv;
					tempUV *= sin(i.uv.x + _Time.x);
					col = tex2D(_MainTex, tempUV);
					col.r *= sin(_Time.y);
					col.b *= cos(_Time.z);
				}
				else if (col.g > .1 && 
						 col.r < .8 && 
						 col.b < .1 + sin(_Time.y + i.uv.x - sin(i.uv.y * 10)) * .1)
				{
					col = tex2D(_CodeTex, i.uv);
					half4 tempCol = col;
					if (dot(col, 1) < 1.5)
					{
						float2 tempUV = i.uv;
						tempUV.y += _Time.x;
						tempUV.x += .01;
						col = tex2D(_CodeTex, tempUV);
						if (dot(col, 1) < 1.5)
						{
							tempUV.y += _Time.x;
							tempUV.x -= .02;
							col = tex2D(_CodeTex, tempUV);
						}
						col = lerp(tempCol, col, (_SinTime.z * -1 + 1) / 2);
					}
					else
					{
						col.r = fmod(i.uv.x + _Time.y, .2);
						col.g = fmod(i.uv.y + _Time.x, .5);
						col.b = sin(i.uv.x);
					}
				}
				else
				{
					half4 tempCol = col;
					col = tex2D(_CodeTex, i.uv);
					if (dot(col, 1) < 1.5)
					{
						float2 tempUV = i.uv;
						tempUV.y += _Time.x;
						tempUV.x += .01;
						col = tex2D(_CodeTex, tempUV);
						if (dot(col, 1) < 1.5)
						{
							tempUV.y += _Time.y;
							tempUV.x -= .02;
							col = tex2D(_CodeTex, tempUV);
							half4 tempCol3 = col;
							tempCol3.r = fmod(i.uv.x + _Time.y, .2);
							tempCol3.g = cos(i.uv.x);
							tempCol3.b = sin(i.uv.y + _Time.z);

							col = tempCol3 * .2 * sin(i.uv.x * 10);
						}
						else
						{
							col.r = fmod(i.uv.x + _Time.y, .2);
							col.g = sin(i.uv.x);
							col.b = fmod(i.uv.y + _Time.x, .5); 
						}
					}

					col = lerp(tempCol, col, (_SinTime.z + 1) / 2);
				}

				return lerp(col, untouched, sin(i.uv.x * fmod(i.uv.y, .2)) * sin(i.uv.x * fmod(i.uv.y, .2)));
			}
			ENDCG
		}
	}
}
