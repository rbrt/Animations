Shader "SubstandardShader"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Crush ("Crush", Range(0, 600)) = 600
		_Shift ("HueShift", Range(0,360)) = 0
		_Repeat ("Repeat", Range(0,100)) = 0
		_RepeatTest ("RepeatTest", Color) = (1,1,1,1)
		_PaletteSwap ("PaletteSwap", Range(0,1)) = 0
		_Rotation ("Rotation", Range(0,.5)) = 0
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
				float2 depth : TEXCOORD1;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			sampler2D _CameraDepthTexture;
			float4 _MainTex_ST;
			float _Crush;
			float _Shift;
			float _Repeat;
			float4 _RepeatTest;
			float _PaletteSwap;
			float _Rotation;

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

			float3 palette(float t, float3 a, float3 b, float3 c, float3 d){
			    return a + b*cos( 6.28318*(c*t+d) );
			}

			float3 paletteConversion(float t){
				return palette(t, float3(0.5, 0.5, 0.5), float3(0.5, 0.5, 0.5), float3(2.0, 1.0, 0.0), float3(0.50, 0.20, 0.25));
			}

			fixed4 repeat(fixed4 col, float2 uv){
				if (distance(col, _RepeatTest) < .75){
					float2 centeredCoords = float2((uv.x * 2.0 - 1.0), (uv.y * 2.0 - 1.0));
					float4 temp = col;

					for (float iter = 0; iter < _Repeat / 100.0; iter += .01){
						float2 newCoords = uv;

						if (distance(temp, float4(0,0,0,0)) < .5){
							temp += tex2D(_MainTex, newCoords - newCoords * iter) * .1;
						}
						else{
							temp -= tex2D(_MainTex, newCoords + newCoords * iter) * .1;
						}
					}

					col = lerp(col, temp, saturate(distance(centeredCoords, float2(0,0) + 1)));
				}
				return col;
			}

			fixed4 swirl(float2 uv, float2 effectParams){
				float theta = _Rotation;

			    float centerCoordx = (uv.x * 2.0 - 1.0);
			    float centerCoordy = (uv.y * 2.0 - 1.0);

			    float len = sqrt(pow(centerCoordx, 2.0) + pow(centerCoordy, 2.0));

			    float2 vecA = float2(centerCoordx, centerCoordy);
			    float2 vecB = float2(len, 0);

			    float initialValue = dot(vecA, vecB) / (len * 1.0);
			    float degree = degrees(acos(initialValue));

			    float thetamod = degree * len;

				// Input xy controls speed and intensity
			    float intensity = _Rotation * 20.0;

			    theta += thetamod * ((intensity) / 100.0);

			    float2 newPoint = float2((cos(theta) * (uv.x * 2.0 - 1.0) + sin(theta) * (uv.y * 2.0 - 1.0) + 1.0)/2.0,
			                      (-sin(theta) * (uv.x * 2.0 - 1.0) + cos(theta) * (uv.y * 2.0 - 1.0) + 1.0)/2.0);


				return tex2D(_MainTex, newPoint);
			}

			v2f vert (appdata v) {
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				UNITY_TRANSFER_DEPTH(o.depth);
				return o;
			}

			fixed4 frag (v2f i) : SV_Target {
				i.uv = floor(i.uv * _Crush) / _Crush;
				fixed4 col = tex2D(_MainTex, i.uv);

				if (distance(col, _RepeatTest) < .75){
					col = swirl(i.uv, float2(0,0));
				}

				col.xyz = shift(col.xyz, _Shift);

				col = repeat(col, i.uv);

				col.xyz = lerp(col, paletteConversion(col.r + col.g + col.b + _Time.y), _PaletteSwap + i.uv.y * .8);

				//col.xyz = i.depth.x / i.depth.y;
				float depthValue =  Linear01Depth(tex2Dproj(_CameraDepthTexture, UNITY_PROJ_COORD(i.uv)).x);
				col.xyz = depthValue;

				return col;
			}
			ENDCG
		}
	}
}
