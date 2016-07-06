Shader "Custom/TopoTerrain" {
	Properties{
		_MainTex("Albedo (RGB)", 2D) = "white" {}
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

	sampler2D _MainTex;

	void vert(inout appdata_full v, out Input o) {
		UNITY_INITIALIZE_OUTPUT(Input, o);

		float2 uv = v.texcoord.xy;
		
		uv.x += _Time.x / 5;

		v.texcoord.yx = uv;

		fixed4 height = tex2Dlod(_MainTex, float4(uv, 0, 0));

		float offset = dot(height.rgb, 1);
		
		

		v.vertex.z = offset * 10;

		o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
	}

	void surf(Input IN, inout SurfaceOutputStandard o) {
		fixed4 c = tex2D(_MainTex, IN.uv_MainTex.yx * sin(IN.uv_MainTex.y * 1.5));
		o.Albedo = c.rgb;
		o.Alpha = c.a;
	}
	ENDCG
	}
}
