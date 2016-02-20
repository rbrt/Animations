Shader "Grid" {



    Properties {

      _GridThickness ("Grid Thickness", Float) = 0.01

      _GridSpacingX ("Grid Spacing X", Float) = 1.0

      _GridSpacingY ("Grid Spacing Y", Float) = 1.0

      _GridOffsetX ("Grid Offset X", Float) = 0

      _GridOffsetY ("Grid Offset Y", Float) = 0

      _GridColour ("Grid Colour", Color) = (0.5, 1.0, 1.0, 1.0)

      _BaseColour ("Base Colour", Color) = (0.0, 0.0, 0.0, 0.0)

    }



    SubShader {

      Tags { "RenderType"="Opaque" }



      Pass {

        ZWrite On
        Blend SrcAlpha OneMinusSrcAlpha


        CGPROGRAM



        // Define the vertex and fragment shader functions

        #pragma vertex vert

        #pragma fragment frag

		// make fog work
		#pragma multi_compile_fog
		#include "UnityCG.cginc"


        // Access Shaderlab properties

        uniform float _GridThickness;

        uniform float _GridSpacingX;

        uniform float _GridSpacingY;

        uniform float _GridOffsetX;

        uniform float _GridOffsetY;

        uniform float4 _GridColour;

        uniform float4 _BaseColour;



        // Input into the vertex shader

        struct vertexInput {

            float4 vertex : POSITION;


        };

        // Output from vertex shader into fragment shader

        struct vertexOutput {

		  float2 worldPos : TEXCOORD0;
  		  UNITY_FOG_COORDS(1)
  		  float4 pos : SV_POSITION;

        };



        // VERTEX SHADER

        vertexOutput vert(vertexInput input) {
          vertexOutput output;
		  UNITY_INITIALIZE_OUTPUT(vertexOutput, output);
          output.pos = mul(UNITY_MATRIX_MVP, input.vertex);

          // Calculate the world position coordinates to pass to the fragment shader

          output.worldPos = mul(_Object2World, input.vertex);
		  UNITY_TRANSFER_FOG(output, output.pos);

          return output;

        }



        // FRAGMENT SHADER

        float4 frag(vertexOutput input) : COLOR {
		  float offset = _GridOffsetX - _Time.z * 3;

          if (frac((input.worldPos.x + offset)/_GridSpacingX) < (_GridThickness / _GridSpacingX) ||
              frac((input.worldPos.y + _GridOffsetY)/_GridSpacingY) < ((_GridThickness * .3) / _GridSpacingY)) {

			fixed4 color = _GridColour;
			UNITY_APPLY_FOG(input.fogCoord, color);
            return color;

          }

          else {

            fixed4 color = _BaseColour;
			UNITY_APPLY_FOG(input.fogCoord, color);
            return color;

          }

        }

    ENDCG

    }

  }

}
