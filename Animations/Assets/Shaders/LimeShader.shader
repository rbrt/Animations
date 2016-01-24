Shader "Custom/LimeShader" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_DeformTex ("Deform", 2D) = "white" {}
		_DeformStep ("DeformStep", Range(0,1)) = 0
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
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

		sampler2D _MainTex;
		sampler2D _DeformTex;
		fixed4 _Color;
		float _DeformStep;

		void vert (inout appdata_full v, out Input o) {
			UNITY_INITIALIZE_OUTPUT(Input, o);

			fixed4 worldPos = mul(_Object2World, v.vertex);
			float4 deform = tex2Dlod(_DeformTex, float4(v.texcoord.xy,0,0));

			float t = min((deform.r + _DeformStep) * _DeformStep, 1);

			v.vertex.xyz = lerp(v.vertex.xyz, float3(0,0,0), floor(t * 10) / 10);

			o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
      	}

		void surf (Input IN, inout SurfaceOutputStandard o) {
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = c.rgb;
			o.Alpha = c.a;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
