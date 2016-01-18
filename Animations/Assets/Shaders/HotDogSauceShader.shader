Shader "Custom/HotDogShader" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_EffectOn ("EffectOn", Range(0,1)) = 0.5
		_TargetPosition ("TargetPosition", Vector) = (0,0,0)
		_TargetDirection ("TargetDirection", Vector) = (0,0,0)
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
		fixed4 _Color;
		fixed3 _TargetPosition;
		fixed3 _TargetDirection;
		float _EffectOn;

		void vert (inout appdata_full v, out Input o) {
			UNITY_INITIALIZE_OUTPUT(Input, o);

			fixed4 worldPos = mul(_Object2World, v.vertex);
			if (_EffectOn > .5){
				if (_TargetPosition.z < worldPos.z){
					worldPos.xyz = _TargetPosition.xyz;
					/*v.vertex.z = _TargetPosition.y * .8;
					v.vertex.x = _TargetPosition.x;
					v.vertex.y = _TargetPosition.z;*/
				}
			}

			v.vertex = mul(_World2Object, worldPos);
			o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
      	}

		void surf (Input IN, inout SurfaceOutputStandard o) {
			// Albedo comes from a texture tinted by color
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = c.rgb;
			o.Alpha = c.a;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
