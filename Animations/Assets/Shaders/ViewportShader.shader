Shader "Unlit/ViewportShader"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Crush ("Crush", Range(0, 600)) = 600
		_Shift ("Shift", Range(0,360)) = 0
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

			struct appdata {
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f {
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _Crush;
			float _Shift;

			float3x3 generateRotation(float degrees){
				float3x3 newMatrix = float3x3(1,0,0, 0,1,0, 0,0,1);

				float cosA = cos(radians(degrees));
				float sinA = sin(radians(degrees));
		        newMatrix[0][0] = cosA + (1.0 - cosA) / 3.0;
		        newMatrix[0][1] = 1./3. * (1.0 - cosA) - sqrt(1./3.) * sinA;
		        newMatrix[0][2] = 1./3. * (1.0 - cosA) + sqrt(1./3.) * sinA;
		        newMatrix[1][0] = 1./3. * (1.0 - cosA) + sqrt(1./3.) * sinA;
		        newMatrix[1][1] = cosA + 1./3.*(1.0 - cosA);
		        newMatrix[1][2] = 1./3. * (1.0 - cosA) - sqrt(1./3.) * sinA;
		        newMatrix[2][0] = 1./3. * (1.0 - cosA) - sqrt(1./3.) * sinA;
		        newMatrix[2][1] = 1./3. * (1.0 - cosA) + sqrt(1./3.) * sinA;
		        newMatrix[2][2] = cosA + 1./3. * (1.0 - cosA);

				return newMatrix;
			}

			float myClamp(float x){
				if (x < 0){
					return 0;
				}
				else if (x > 1){
					return 1;
				}
				return x + (1 / 255);
			}

			float3 shift(float3 color, float degrees){
				float3x3 shiftMatrix = generateRotation(degrees);
				float3 newColor = color;

				newColor.r = color.r * shiftMatrix[0][0] + color.g * shiftMatrix[0][1] + color.b * shiftMatrix[0][2];
				newColor.g = color.r * shiftMatrix[1][0] + color.g * shiftMatrix[1][1] + color.b * shiftMatrix[1][2];
				newColor.b = color.r * shiftMatrix[2][0] + color.g * shiftMatrix[2][1] + color.b * shiftMatrix[2][2];

				return float3(myClamp(newColor.r), myClamp(newColor.g), myClamp(newColor.b));
			}

			v2f vert (appdata v) {
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}

			fixed4 frag (v2f i) : SV_Target {
				i.uv = floor(i.uv * _Crush) / _Crush;
				fixed4 col = tex2D(_MainTex, i.uv);

				col.xyz = shift(col.xyz, _Shift);

				return col;
			}
			ENDCG
		}
	}
}
