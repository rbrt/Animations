Shader "SubstandardShader"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Dissolve ("Texture", 2D) = "white" {}
		_Crush ("Crush", Range(0, 600)) = 600
		_Shift ("HueShift", Range(0,360)) = 0
		_Repeat ("Repeat", Range(0,100)) = 0
		_RepeatTest ("RepeatTest", Color) = (1,1,1,1)
		_PaletteSwap ("PaletteSwap", Range(0,1)) = 0
		_Rotation ("Rotation", Range(-.5,.5)) = 0
		_Chroma ("Chromatic", Range(0, 10)) = 0
		_DissolveThreshold("DissolveThreshold", Range(0,1)) = 0
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

			uniform float4 _MainTex_TexelSize;

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
			sampler2D _Dissolve;
			float4 _MainTex_ST;
			float _Crush;
			float _Shift;
			float _Repeat;
			float4 _RepeatTest;
			float _PaletteSwap;
			float _Rotation;
			float _Chroma;
			float _DissolveThreshold;

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

			float3 paletteConversionA(float t){
				return palette(t, float3(0.5, 0.5, 0.5), float3(0.5, 0.5, 0.5), float3(2.0, 1.0, 0.0), float3(0.50, 0.20, 0.25));
			}

			float3 paletteConversionB(float t){
				return palette(t, float3(0.5, 0.5, 0.5), float3(0.5, 0.5, 0.5), float3(1.0, 1.0, 0.0), float3(0.00, 0.10, 0.2));
			}

			float3 aberration(float2 uv, float3 color){
				half2 newCoords = uv + half2(_MainTex_TexelSize.x, _MainTex_TexelSize.y) * _Chroma;
				half3 newColor = tex2D(_MainTex, uv);

				half2 newCoords1 = uv + half2(_MainTex_TexelSize.x, _MainTex_TexelSize.y) * _Chroma;
				half2 newCoords2 = uv + half2(-_MainTex_TexelSize.x, -_MainTex_TexelSize.y) * _Chroma;

				half3 newColor1 = tex2D(_MainTex, newCoords1);
				half3 newColor2 = tex2D(_MainTex, newCoords2);
				return float3(newColor.r, newColor2.g, newColor1.b);
			}

			fixed4 repeat(fixed4 col, float2 uv){
				if (distance(col, _RepeatTest) < 1){
					float2 centeredCoords = float2((uv.x * 2.0 - 1.0), (uv.y * 2.0 - 1.0));
					float4 temp = col;

					for (float iter = 0; iter < _Repeat / 100; iter += .01){
						float2 newCoords = uv + half2(_MainTex_TexelSize.x * floor(iter * 1000) / 10,
													  _MainTex_TexelSize.y * floor(iter * 1000) / 10);

						if (distance(temp, float4(0,0,0,0)) < .5){
							temp += tex2D(_MainTex, newCoords) * .1;
						}
						else{
							temp -= tex2D(_MainTex, newCoords) * .1;
						}
					}

					temp *= ((_Repeat / 100) + 1);

					col = lerp(col, temp, _Repeat / 100);
				}
				return col;
			}

			fixed4 dissolve(fixed4 c, fixed2 uv){
				float val = tex2D(_Dissolve, uv).rgb - _DissolveThreshold;
				fixed3 testColor = shift(c.rgb, _Shift + 70);

				if(val <= -0.02){
					return c;
				}
	            if (val <= 0) {
	                val += 0.02;
	                c.rgb = testColor;
	                float a = lerp(0, c.a, 50*val);
	                c.a = a;
	                c.rgb *= c.a;
	                return c;
	            }
				else{
					c.rgb = testColor;
		            c.rgb *= c.a;
		            return c;
				}
			}

			float dissolveVal(fixed4 c, fixed2 uv){
				float val = tex2D(_Dissolve, uv).rgb - _DissolveThreshold;

				if(val <= -0.02){
					return 0;
				}
	            if (val <= 0) {
	                return 50*val;
	            }
				else{
					return 1;
				}
			}

			#define STEP 6

			float GetVoronoiForPoint(float2 uv){
				float2[STEP] pos = float2[STEP](float2(.6,.6), float2(.1,.1), float2(.8,.8), float2(.3,.1), float2(.9,.9), float2(.8,.1));
				float4[STEP] coloring = float4[STEP](float4(1,1,1,1), float4(1,0,1,1), float4(1,1,0,1), float4(0,0,1,1), float4(1,0,0,1), float4(.5,.5,0,1));

				float dist = 100;
				float returnVal = 1;
				for (int k = 0; k < STEP; k++){
					float current = distance(pos[k]  + (_SinTime.w) * float2(sin(pos[k].x),sin(pos[k].y)), uv);
					if (current < dist){
						dist = current;
						returnVal = STEP / k;
					}
				}

				return returnVal;
			}

			float GetVoronoiDistance(float2 uv){
				float2[STEP] pos = float2[STEP](float2(.6,.6), float2(.1,.1), float2(.8,.8), float2(.3,.1), float2(.9,.9), float2(.8,.1));

				float dist = 1;
				int index = 0;
				for (int k = 0; k < STEP; k++){
					float current = distance(pos[k] + (_SinTime.w) * float2(.1,.1), uv);
					if (current < dist){
						dist = current;
						index = k;
					}
				}

				return distance(pos[index], uv);
			}

			fixed4 swirl(float2 uv, float2 effectParams){
				float doit = GetVoronoiForPoint(uv);

				float theta = _Rotation + _Time.z * .5;

			    float centerCoordx = (uv.x * 2.0 - 1.0);
			    float centerCoordy = (uv.y * 2.0 - 1.0);

			    float len = sqrt(pow(centerCoordx, 2.0) + pow(centerCoordy, 2.0));

			    float2 vecA = float2(centerCoordx, centerCoordy);
			    float2 vecB = float2(len, 0);

			    float initialValue = dot(vecA, vecB) / (len * 1.0);
			    float degree = degrees(acos(initialValue));

			    float thetamod = degree * len;

				// Input xy controls speed and intensity

			    float intensity = doit * 20.0 + (_Time.z * 2 - 1) * .1;

			    theta += thetamod * ((intensity) / 100.0);

			    float2 newPoint = float2((cos(theta) * (uv.x * 2.0 - 1.0) + sin(theta) * (uv.y * 2.0 - 1.0) + 1.0)/2.0,
			                      (-sin(theta) * (uv.x * 2.0 - 1.0) + cos(theta) * (uv.y * 2.0 - 1.0) + 1.0)/2.0);

				if (fmod(doit, 1.5) < 1){
  					return tex2D(_MainTex, uv);
  				}
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

				if (_Chroma > 0){
					col.xyz = aberration(i.uv, col.xyz);
				}

				if (dissolveVal(col, i.uv) > 0){
					if (distance(col, _RepeatTest) < .75 && _Rotation != 0){
						col = swirl(i.uv, float2(0,0));
					}
				}

				col.xyz = lerp(col.xyz, shift(col.xyz, _Shift * GetVoronoiForPoint(i.uv)), GetVoronoiDistance(i.uv) * 10);

				col = repeat(col, i.uv);

				//col = dissolve(col, i.uv);

				col.xyz = lerp(col, paletteConversionB(col.r + col.g + col.b + _Time.y), _PaletteSwap);


				return col;
			}
			ENDCG
		}
	}
}
