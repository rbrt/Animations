Shader "Custom/WaterSurface" {
	Properties {
		_Color ("Color", Color) = (0,0,1,0)
		_Lambda ("Lambda", Float) = 0
		_Frequency ("Frequency", Float) = 0
		_Amplitude ("Amplitude", Float) = 0
		_PlayerPosition("Player Position", Vector) = (0,0,0,0)
		_PlayerForward("Player Forward", Vector) = (0,0,0,0)
		_PlayerRight("Player Right", Vector) = (0,0,0,0)
		_DeltaY("DeltaY", Float) = 0
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200

		CGPROGRAM
		#pragma surface surf Lambert vertex:vert
		#pragma target 3.0

		struct Input {
			float3 pos : SV_POSITION;
            float3 normal : TEXCOORD;
			float4 color : COLOR;
			float3 worldPos;
			float test;
        };

		float _Amplitude;
		float _Frequency;
		float _Lambda;
		float _DeltaY;
		fixed4 _Color;

		fixed4 _PlayerPosition;
		fixed4 _PlayerForward;
		fixed4 _PlayerRight;

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
			float frequency = sqrt(g * freq);
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

		void vert (inout appdata_full v, out Input o){
			float4 p = v.vertex;

			float deltaY = _DeltaY;

			float scaleWidth = deltaY * 2;
			float scaleLength = deltaY * 2;
			float4 forwardPoint = _PlayerPosition + _PlayerForward * 80;
			float4 rearPoint = _PlayerPosition - _PlayerForward * scaleLength;

			float3 rightPoint = rearPoint + _PlayerRight * scaleWidth;
			float3 leftPoint = rearPoint - _PlayerRight * scaleWidth;

			if (_PlayerPosition.x != -9999 && PointInTriangle(v.vertex.xz, rightPoint.xz, leftPoint.xz, forwardPoint.xz)){
				float maxDist = distance(forwardPoint.xz, rearPoint.xz);
				float offset = pow(distance(forwardPoint.xz, v.vertex.xz) / maxDist, 2);
				v.vertex.xyz = gerstnerSumGenerator(v.vertex.xz, 1);
				v.vertex.y -= offset;
			}
			else{
				v.vertex.xyz = gerstnerSumGenerator(v.vertex.xz, 0);
			}
		}

		void surf (Input IN, inout SurfaceOutput o) {
			if (IN.test > 0){
				o.Albedo = fixed4(1,0,0,1);
			}
			o.Albedo = _Color;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
