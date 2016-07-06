Shader "Custom/PointCloud" {
	Properties{
		_AParam ("A Param", Range(-3,3)) = 0
		_BParam ("B Param", Range(-3,3)) = 0
		_CParam ("C Param", Range(-3,3)) = 0
		_DParam ("D Param", Range(-3,3)) = 0
		_EParam ("E Param", Range(-3,3)) = 0
		_FParam ("F Param", Range(-3,3)) = 0
		}
		SubShader{
		Tags{ "RenderType" = "Opaque" }
		LOD 200

		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
#pragma surface surf Standard fullforwardshadows
#pragma vertex vert

		// Use shader model 3.0 target, to get nicer looking lighting
#pragma target 3.0

	struct Input {
		float2 uv_MainTex: TEXCOORD0;
		float4 vertex: SV_POSITION;
	};

	float _AParam;
	float _BParam;
	float _CParam;
	float _DParam;
	float _EParam;
	float _FParam;

	void vert(inout appdata_full v, out Input o) {
		UNITY_INITIALIZE_OUTPUT(Input, o);

		v.vertex = mul(UNITY_MATRIX_MVP, v.vertex);

		_AParam += _Time.x * .1;
		_BParam += _Time.x * .01;
		_FParam += _Time.x * .01;
		_DParam += _Time.x * .01;

		v.vertex.x = sin(_AParam * v.vertex.y) + cos(_BParam * v.vertex.x) - cos(_CParam * v.vertex.z);
		v.vertex.y = sin(_DParam * v.vertex.x) + cos(_EParam * v.vertex.y) - cos(_FParam * v.vertex.z);
		v.vertex.z = v.vertex.x * v.vertex.y;

		o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
	}

	void surf(Input IN, inout SurfaceOutputStandard o) {
		fixed4 c = fixed4(sin(_AParam + _Time.y), sin(_BParam), sin(_AParam * _BParam), 1);
		o.Albedo = c.rgb;
		o.Alpha = c.a;
	}
	ENDCG
	}
}
