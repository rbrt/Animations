Shader "Custom/GroundShader" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200

		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard
		#pragma vertex vert

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		struct Input {
			float2 uv_MainTex: TEXCOORD0;
			float4 vertex: SV_POSITION;
			float percentage: TEXCOORD1;
		};

		fixed4 _Color;

		void vert (inout appdata_full v, out Input o) {
			UNITY_INITIALIZE_OUTPUT(Input, o);

			fixed4 worldPos = mul(_Object2World, v.vertex);

			o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
			o.percentage = (worldPos.y) / 50;
      	}

		void surf (Input IN, inout SurfaceOutputStandard o) {
			fixed4 c = _Color * IN.percentage;
			o.Albedo = c.rgb;
			o.Alpha = c.a;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
