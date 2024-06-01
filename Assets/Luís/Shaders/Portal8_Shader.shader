Shader "Custom/Portal8"
{
    Properties
    {
        _DistortionView ("Distortion View", Range(0.0, 0.3)) = 0.03
        _SpeedView ("Speed View", Range(0.0, 1.0)) = 0.5
        _NoiseViewX ("Noise View X", 2D) = "white" {}
        _NoiseViewY ("Noise View Y", 2D) = "white" {}
        _ScreenTexture ("Screen Texture", 2D) = "white" {}
        _TintColor ("Tint Color", Color) = (1,1,1,1)
        _FesnelAmount ("Fresnel Amount", Range(0.0, 5.0)) = 0.1
        _DistortionVertex ("Distortion Vertex", Range(0.0, 0.3)) = 0.03
        _SpeedVertex ("Speed Vertex", Range(0.0, 1.0)) = 0.1
        _NoiseVertex ("Noise Vertex", 2D) = "white" {}

        [HDR] _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Normal("Normal map", 2D) = "bump" {}

        _NoiseTex ("Noise", 2D) = "white" {}
        _MovementDirection ("Movement Direction", float) = (0, -1, 0, 1)
        
        [Enum(UnityEngine.Rendering.CullMode)] _Cull ("Cull", Float) = 2
    }
    SubShader
    {
        // Tags { "RenderType" = "Opaque" }
        Tags { "RenderType" = "Transparent" "Queue" = "Transparent" }
     
        Blend SrcAlpha OneMinusSrcAlpha
        Cull [_Cull]
        LOD 200

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            #pragma target 3.0

            // fragment uniforms
            sampler2D _NoiseViewX;
            sampler2D _NoiseViewY;
            sampler2D _ScreenTexture;
            float4 _TintColor;
            float _FesnelAmount;
            float _DistortionView;
            float _SpeedView;

            // vertex uniforms
            sampler2D _NoiseVertex;
            float _DistortionVertex;
            float _SpeedVertex;

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _NoiseTex;
            fixed4 _Color;
            sampler2D _Normal;
            half2 _MovementDirection;

            UNITY_INSTANCING_BUFFER_START(Props)
            UNITY_INSTANCING_BUFFER_END(Props)

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float2 uv_MainTex : TEXCOORD0;
                // float2 uv_Normal : TEXCOORD1;
                // float2 uv_NoiseTex : TEXCOORD2;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv_MainTex : TEXCOORD0;
                float2 uv : TEXCOORD0;
                // float2 uv_NoiseTex : TEXCOORD2;
                // float2 uv_Normal : TEXCOORD1;
                float3 normal : NORMAL;
                float3 viewDir : TEXCOORD1;
            };

            v2f vert(appdata v)
            {
                v2f o;

                // o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.uv_MainTex = v.uv_MainTex;
                // o.normal = UnityObjectToWorldNormal(v.normal);
                // o.viewDir = normalize(UnityWorldSpaceViewDir(v.vertex));

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.viewDir = normalize(UnityWorldSpaceViewDir(v.vertex));

                // use tex2Dlod for texture sampling in vertex shader
                float4 noiseSample = tex2Dlod(_NoiseVertex, float4(v.uv + (_Time.y * _SpeedVertex), 0, 0));
                float noiseVal = (noiseSample.r * 2.0) - 1.0; // Range: -1.0 to 1.0
                float3 displacement = v.normal * noiseVal * _DistortionVertex;
                v.vertex.xyz += displacement;

                o.vertex = UnityObjectToClipPos(v.vertex);

                return o;
            }

            float fresnel(float amount, float3 normal, float3 view)
            {
                return pow((1.0 - saturate(dot(normalize(normal), normalize(view)))), amount);
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

            fixed4 frag(v2f i) : SV_Target
            {
                // adicionar deslocamento ao UV para movimentação
                // float2 uv_MainTex = i.uv_MainTex + _MovementDirection * _Time.y;
                // float2 uv_MainTex = RotateUV(i.uv_MainTex, _Time.y * 3.5);
                // float2 uv_Normal = i.viewDir + _MovementDirection * _Time.y / 2.0;
                // float2 uv_NoiseTex = i.uv_NoiseTex + _MovementDirection * _Time.y / 2.0;

                // amostragem da textura de ruído
                // fixed4 alphaPixel = tex2D(_NoiseTex, uv_NoiseTex);
    
                // Amostragem da textura principal e cálculo da cor final com efeito de desfoque radial
                // float2 center = float2(0.5, 0.5);
                // float distance = length(uv_MainTex - center);
                // float blurAmount = smoothstep(0.3, 0.5, distance); // Ajuste os valores conforme necessário

                // float2 blurUV = lerp(uv_MainTex, center, blurAmount * 0.5);
                // fixed4 blurredPixel = tex2D(_MainTex, blurUV);

                // Aplicar pulsação à cor
                // float pulse = 1.5 + 1 * sin(_Time.y * 3.0); // Pulsação com frequência de 3 Hz
                // fixed4 pixel = tex2D(_MainTex, uv_MainTex) * _Color * alphaPixel.r;
                // fixed4 pixel = tex2D(_MainTex, uv_MainTex) * _Color;
                // fixed4 pixel = blurredPixel * _Color * pulse;
                // fixed4 pixel = blurredPixel * _Color * pulse;

                // mostrar a textura da normal
                // fixed3 normal = tex2D(_Normal, uv_Normal).rgb;

                // fixed4 finalColor;
                // finalColor.rgb = pixel.rgb;
                // finalColor.a = alphaPixel.r;
                // finalColor.a = 0.85;
                // return finalColor;


                float noiseValueX = (tex2D(_NoiseViewX, i.uv + (_Time.y * _SpeedView)).r * 2.0) - 1.0; // Range: -1.0 to 1.0
                float noiseValueY = (tex2D(_NoiseViewY, i.uv + (_Time.y * _SpeedView)).r * 2.0) - 1.0; // Range: -1.0 to 1.0
                float2 noiseDistort = float2(noiseValueX, noiseValueY) * _DistortionView;

                i.uv = RotateUV(i.uv, _Time.y * 3.5);
                float3 distortedScreenTexture = tex2D(_ScreenTexture, i.uv + noiseDistort).rgb;
                float3 fresnelTint = (_TintColor.rgb * fresnel(_FesnelAmount, i.normal, i.viewDir));

                return float4(distortedScreenTexture + fresnelTint, 1.0);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}