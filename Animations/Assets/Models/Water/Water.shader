Shader "Custom/Water" {
Properties {
	_Color ("Main Color", Color) = (1,1,1,1)
	_Lambda ("Lambda", Float) = 0
	_WaveVector ("Wave Vector", Float) = 0
	_Frequency ("Frequency", Float) = 0
	_Amplitude ("Amplitude", Float) = 0
}

SubShader {
	LOD 100

	Pass
		{
		CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile DUMMY PIXELSNAP_ON
			#include "UnityCG.cginc"

			struct appdata_t
			{
				float4 vertex   : POSITION;
				float4 color    : COLOR;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex   : SV_POSITION;
				fixed4 color    : COLOR;
				float3 normal	: NORMAL;
				float3 lightDir : TEXCOORD2;
			};

			fixed4 _Color;

			float _Amplitude;
			float _Frequency;
			float _WaveVector;
			float _Lambda;

			fixed2 gerstnerSumXZ(fixed2 x0, fixed2 waveVector, float freq, float amplitude, float phase, float doIt){
				float lambda = _Lambda;
				float g = 9.8;
				float frequency = sqrt(g * freq);
				float k = 2 * 3.14159 / lambda;
				float waterRipple = 3;
				float t = doIt > 0 ? _Time.z * waterRipple : _Time.y;
				fixed2 wave;
				float amp = amplitude * _Amplitude;

				wave.xy = (waveVector / k) * amp * sin(dot(waveVector, x0) - frequency * t + phase);

				return wave;
			}

			float gerstnerSumY(fixed2 x0, fixed2 waveVector, float freq, float amplitude, float phase, float doIt){
				float lambda = _Lambda;
				float g = 9.8;
				float frequency = sqrt(g * freq * _Frequency);
				float k = 2 * 3.14159 / lambda;
				float waterRipple = 3;
				float t = doIt > 0 ? _Time.z * waterRipple : _Time.y;
				fixed3 wave;

				float amp = amplitude * _Amplitude;

				return amp * cos(dot(waveVector, x0) - frequency * t + phase);
			}

			fixed3 gerstnerSumGenerator(fixed2 x0, float doIt){
				fixed3 wave;

				wave.xz = gerstnerSumXZ(x0, fixed2(1,1), .2, .2, .2, doIt);
				wave.y = gerstnerSumY(x0, fixed2(1,1), .2, .2, .2, doIt);
				wave.xz += gerstnerSumXZ(x0, fixed2(1,-1), 1, .5, .1, doIt);
				wave.y += gerstnerSumY(x0, fixed2(1,-1), 1, .5, .1, doIt);

				wave.xz = x0 - wave.xz;

				return wave;
			}

			float sign (float2 p1, float2 p2, float2 p3){
			    return (p1.x - p3.x) * (p2.y - p3.y) - (p2.x - p3.x) * (p1.y - p3.y);
			}

			bool PointInTriangle (float2 pt, float2 v1, float2 v2, float2 v3){
			    bool b1, b2, b3;

			    b1 = sign(pt, v1, v2) < 0.0f;
			    b2 = sign(pt, v2, v3) < 0.0f;
			    b3 = sign(pt, v3, v1) < 0.0f;

			    return ((b1 == b2) && (b2 == b3));
			}

			v2f vert(appdata_base IN){
				v2f OUT;
				float4 vertex = IN.vertex;
				vertex.xyz = gerstnerSumGenerator(vertex.xz, 0);
				OUT.vertex = mul(UNITY_MATRIX_MVP, vertex);
				OUT.normal = IN.normal;
				OUT.lightDir = ObjSpaceLightDir(vertex);
				return OUT;
			}

			fixed4 frag(v2f IN) : COLOR{
				float diffuse = dot(IN.lightDir, IN.normal) + .5;
				return fixed4(_Color * diffuse);
			}

		ENDCG
		}
}

}
