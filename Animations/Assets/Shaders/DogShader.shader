Shader "Custom/DogShader" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_WireframeTex ("Albedo (RGB)", 2D) = "white" {}
		_WireframeOn ("Wireframe On", Range(0,1)) = 0.0
		_RuinMesh ("Ruin Mesh", Range(0,1)) = 0.0
	}
	SubShader {
		Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
		LOD 200
		Blend SrcAlpha OneMinusSrcAlpha
		Cull Off

		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard fullforwardshadows keepalpha
		#pragma vertex vert

		sampler2D _MainTex;
		sampler2D _WireframeTex;
		float _WireframeOn;
		float _RuinMesh;

		struct Input {
			float2 uv_MainTex: TEXCOORD0;
			float3 normal;
			float4 vertex;
		};

		half2 rotate(half2 vec){
			return half2(sin(vec.x) + cos(vec.x), -cos(vec.y) + sin(vec.y));
		}

		void vert (inout appdata_base v, out Input o) {
		  UNITY_INITIALIZE_OUTPUT(Input, o);
		  if (_RuinMesh > .5){
			  half4 deform = v.vertex;
			  float3 offset = cross(fixed3(sin(v.vertex.x + _Time.x), sin(v.vertex.y + _Time.y), sin(v.vertex.z + _Time.z)), v.normal);
			  deform.xy = rotate(v.vertex.xy);
			  deform.xyz += offset * (sin(_Time.z * 3) + 1) * 3;

			  v.vertex = lerp(v.vertex, deform, (sin(_Time.w * 5) + 1) / 2);
		  }
		  fixed4 vertex = mul(UNITY_MATRIX_MVP,v.vertex);

		  o.vertex = vertex;
		  o.normal = v.normal;
      	}

		fixed4 _Color;

		float TestWireframe(half3 test){
			return distance(test.rgb, half3(0,0,0));
		}

		void surf (Input IN, inout SurfaceOutputStandard o) {
			// Albedo comes from a texture tinted by color
			fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
			fixed4 wireframeColor = tex2D(_WireframeTex, IN.uv_MainTex);
			if (_WireframeOn > .5){
				if (TestWireframe(wireframeColor.rgb) > 1){
					float sign = 1;
					if (fmod(IN.vertex.x, 2) > 1){
						sign = -1;
					}
					fixed4 testColor = tex2D(_WireframeTex, IN.uv_MainTex * (1.05 + sin(_Time.z * IN.vertex.x / IN.vertex.y + IN.vertex.z) * .5 * sign));
					if (TestWireframe(testColor) < 1){
						wireframeColor.rb = 0;
						wireframeColor.ga = 1;
					}
					else{
						wireframeColor.a = 0;
					}
				}
				else{
					wireframeColor.rb = 0;
					wireframeColor.ga = 1;
				}
			}
			else {
				c.a = 1 - _WireframeOn;
			}

			fixed4 finalColor = lerp(c, wireframeColor, _WireframeOn);

			o.Albedo = finalColor;
			o.Alpha = finalColor.a;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
