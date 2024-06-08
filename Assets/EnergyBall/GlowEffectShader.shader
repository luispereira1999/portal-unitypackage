Shader "Custom/GlowEffectShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "defaulttexture" {}
        [HDR]_BaseColor ("Base Color", Color) = (1, 1, 1, 1)
        [HDR]_GlowColor ("Glow Color", Color) = (1, 1, 1, 1)
        _GlowIntensity ("Glow Intensity", Range(0, 5)) = 1.0
        _GlowSpeed ("Glow Speed", Range(0, 10)) = 1.0
        _Transparency ("Transparency", Range(0, 1)) = 1.0
    }
    SubShader
    {
        Tags { "Queue"="Transparent" "RenderType"="Transparent" }
        LOD 100

        // Enable blending for transparency
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 viewDir : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _BaseColor;
            float4 _GlowColor;
            float _GlowIntensity;
            float _GlowSpeed;
            float _Transparency;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);

                float angle = _Time.y * 0.1; // Adjust the speed of rotation here
                float cosA = cos(angle);
                float sinA = sin(angle);
                float2x2 rotationMatrix = float2x2(cosA, -sinA, sinA, cosA);
                o.uv = mul(rotationMatrix, v.uv);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // Calculate the animated glow effect
                float glow = (sin( _Time.y * _GlowSpeed) + 1.0) * 0.5 * _GlowIntensity;
                fixed4 glowColor = _GlowColor * glow;
                fixed4 texColor = tex2D(_MainTex, i.uv);
                
                float _Threshold = _Transparency;
                


                fixed4 finalColor = ( _BaseColor + glowColor) * texColor;

                if (texColor.r < _Threshold || texColor.g < _Threshold || texColor.b < _Threshold) {
                    finalColor.a = 0.25;

                }

                return finalColor;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
