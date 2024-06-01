Shader "Custom/Portal5"
{
    Properties
    {
        [HDR] _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Normal("Normal map", 2D) = "bump" {}

        _NoiseTex ("Noise", 2D) = "white" {}
        _MovementDirection ("Movement Direction", float) = (0, -1, 0, 1)
        
        [Enum(UnityEngine.Rendering.CullMode)] _Cull ("Cull", Float) = 2
    }
    SubShader
    {
        // Tags { "RenderType"="Transparent" "IgnoreProjector"="True" "Queue"="Transparent" }
        Tags{ "RenderType"="Transparent" "Queue"="Transparent"}
     
        Blend SrcAlpha OneMinusSrcAlpha
        LOD 200
        Cull [_Cull]

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            #ifndef SHADER_API_D3D11
                #pragma target 3.0
            #else
                #pragma target 4.0
            #endif

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv_MainTex : TEXCOORD0;
                float2 uv_Normal : TEXCOORD1;
                float2 uv_NoiseTex : TEXCOORD2;
            };

            struct v2f
            {
                float2 uv_MainTex : TEXCOORD0;
                float2 uv_Normal : TEXCOORD1;
                float2 uv_NoiseTex : TEXCOORD2;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _Color;
            sampler2D _Normal;
            sampler2D _NoiseTex;

            half2 _MovementDirection;

            UNITY_INSTANCING_BUFFER_START(Props)
            UNITY_INSTANCING_BUFFER_END(Props)

            v2f vert (appdata v)
            {
                v2f o;

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv_MainTex = v.uv_MainTex;
                o.uv_Normal = v.uv_Normal;
                o.uv_NoiseTex = v.uv_NoiseTex;

                return o;
            }

            float2 RotateUV(float2 uv, float angle)
            {
                float s = sin(angle);
                float c = cos(angle);
                uv -= 0.5;
                float2 rotatedUV;
                rotatedUV.x = uv.x * c - uv.y * s;
                rotatedUV.y = uv.x * s + uv.y * c;
                return rotatedUV + 0.5;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // adicionar deslocamento ao UV para movimentação
                // float2 uv_MainTex = i.uv_MainTex + _MovementDirection * _Time.y;
                float2 uv_MainTex = RotateUV(i.uv_MainTex, _Time.y * 3.5);
                float2 uv_Normal = i.uv_Normal + _MovementDirection * _Time.y / 2.0;
                float2 uv_NoiseTex = i.uv_NoiseTex + _MovementDirection * _Time.y / 2.0;

                // amostragem da textura de ruído
                fixed4 alphaPixel = tex2D(_NoiseTex, uv_NoiseTex);
    
                // Amostragem da textura principal e cálculo da cor final com efeito de desfoque radial
                float2 center = float2(0.5, 0.5);
                float distance = length(uv_MainTex - center);
                float blurAmount = smoothstep(0.3, 0.5, distance); // Ajuste os valores conforme necessário

                float2 blurUV = lerp(uv_MainTex, center, blurAmount * 0.5);
                fixed4 blurredPixel = tex2D(_MainTex, blurUV);

                // Aplicar pulsação à cor
                float pulse = 1.5 + 1 * sin(_Time.y * 3.0); // Pulsação com frequência de 3 Hz
                // fixed4 pixel = tex2D(_MainTex, uv_MainTex) * _Color * alphaPixel.r;
                // fixed4 pixel = tex2D(_MainTex, uv_MainTex) * _Color * pulse;
                fixed4 pixel = blurredPixel * _Color * pulse;

                // mostrar a textura da normal
                fixed3 normal = tex2D(_Normal, uv_Normal).rgb;

                fixed4 finalColor;
                finalColor.rgb = pixel.rgb;
                // finalColor.a = alphaPixel.r;
                finalColor.a = 0.85;
                return finalColor;
            }

            ENDCG
        }
    }
    FallBack "Diffuse"
}