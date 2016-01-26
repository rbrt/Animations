Shader "Custom/GlassFinal" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_FillColor ("FillColor", Color) = (1,1,1,1)
		_Fill ("Fill", Range(0,1)) = 0
	}

	SubShader {
		Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
		LOD 200



	CGPROGRAM
	#pragma surface surf  Standard fullforwardshadows alpha:fade
	#pragma vertex vert

	fixed4 _Color;
	fixed4 _FillColor;
	float _Fill;

	struct Input {
		float2 uv_MainTex: TEXCOORD0;
		float4 vertex: SV_POSITION;
		float4 pos: TEXCOORD1;
		float4 info: TEXCOORD2;
	};

	void vert (inout appdata_full v, out Input o) {
		UNITY_INITIALIZE_OUTPUT(Input, o);
		o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);

		o.pos.xyz = v.vertex.xyz;
		float3 viewDirection = normalize(WorldSpaceViewDir(v.vertex));
		float angle = acos(dot(viewDirection, UnityObjectToWorldNormal(v.normal)));
		o.pos.w = angle;
		o.info = 0;
		o.info.x = acos(dot(v.normal, v.vertex));
	}

	void surf (Input IN, inout SurfaceOutputStandard o) {
		o.Albedo = _Color.rgb;
		o.Alpha = _Color.a;

		float4 projVert = mul(UNITY_MATRIX_MVP, IN.pos);

		if (IN.pos.z > -.57 && IN.pos.z < _Fill - 1 + sin(projVert.x +_Time.w ) * .05){
			if (IN.pos.w < 1.15){
				if (IN.info.x > 1){
					o.Albedo = _FillColor.rgb ;
					o.Alpha = _FillColor.a * .6;
				}
				else{
					o.Albedo = _FillColor.rgb;
					o.Alpha = _FillColor.a;
				}
			}
		}
	}
	ENDCG
	}

}
