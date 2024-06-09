Shader "Custom/Portal_UnlitShader"
{
    Properties
    {
        // CONFIGURAÇÕES GERAIS
        [Space(10)] [Header(Configuracoes Gerais)] [Space(5)]
        [HDR] _Color ("Color", Color) = (1, 1, 1, 1)
        _MainTexture ("Albedo (RGB)", 2D) = "white" {}


        // 1 - ROTAÇÃO
        [Space(10)] [Header(Rotacao)] [Space(5)]
        [Toggle] _HasRotation ("Tem Rotação?", Int) = 0
        [Toggle] _RotationIsFixed ("Rotação é fixa?", Int) = 0
        _RotationSpeed ("Velocidade de Rotação", Range(0, 20)) = 1
        _AngleDegrees ("Ângulo (em Graus)", Range(0, 360)) = 0


        // 2 - EFEITO FRESNEL
        [Space(10)] [Header(Fresnel)] [Space(5)]
        [Toggle] _HasFresnel ("Tem Fresnel?", Int) = 0
        _FresnelColor ("Fresnel Cor", Color) = (0, 0, 1, 1)
        _FresnelPower ("Fresnel Força", Range(0, 5)) = 1


        // 3 - RUÍDO
        [Space(10)] [Header(Ruido)] [Space(5)]
        [Toggle] _HasNoiseDistortion ("Tem Ruído?", Int) = 0
        _NoiseDirection ("Direção do Ruído", Vector) = (1, 0, 0)
        _NoiseSpeed ("Velocidade do Ruído", Range(0, 10)) = 2
        _NoiseTextureX ("Noise View X", 2D) = "white" {}
        _NoiseTextureY ("Noise View Y", 2D) = "white" {}

        
        // 4 - PULSAÇÃO
        [Space(10)] [Header(Pulsacao)] [Space(5)]
        [Toggle] _HasPulse ("Tem Pulsação?", Int) = 0
        _PulseColor ("Cor da Pulsação", Color) = (1, 0, 0, 1)
        _PulseSpeed ("Velocidade da Pulsação", Range(-2, 10)) = 2


        // 5 - LAZER
        [Space(10)] [Header(Lazer)] [Space(5)]
        [Toggle] _HasLazer ("Tem Lazer?", Int) = 0
        _LazerColor ("Cor do Lazer", Color) = (1, 0, 0, 1)
        _LazerSpeed ("Velocidade do Lazer", Range(0, 7)) = 1
        _LazerWidth ("Largura do Lazer", Range(0, 3)) = 2


        // 6 - DISTORÇÃO DE VÉRTICES
        [Space(10)] [Header(Distorcao de Vertices)] [Space(5)]
        [Toggle] _HasVertexDistortion ("Tem Distorção de Vértices?", Int) = 0
        _DistortionVertex ("Distorção dos Vértices", Range(0, 0.2)) = 0.03
        _SpeedVertex ("Velocidade dos Vvértices", Range(0, 1)) = 0.1
        _NoiseVertex ("Ruído dos Vértices", 2D) = "white" {}


        // CONFIGURAÇÕES DE RENDERIZAÇÃO
        [Space(10)] [Header(Configuracoes de Renderizacao)] [Space(5)]
        [Enum(UnityEngine.Rendering.CullMode)] _Cull ("Cull", Float) = 2
        [Enum(UnityEngine.Rendering.BlendMode)] _BlendSrc ("Blend Src", Float) = 1
        [Enum(UnityEngine.Rendering.BlendMode)] _BlendDst ("Blend Dst", Float) = 0
    }
    SubShader
    {
        Tags { "RenderType" = "Transparent" "Queue" = "Transparent" }
     
        Blend [_BlendSrc] [_BlendDst]
        Cull [_Cull]

        LOD 200

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            #pragma target 3.0


            // CONFIGURAÇÕES GERAIS
            sampler2D _MainTexture;
            float4 _Color;
            sampler2D _Normal;


            // 1 - ROTAÇÃO
            int _HasRotation;
            int _RotationIsFixed;
            float _AngleDegrees;
            float _RotationSpeed;


            // 2 - EFEITO FRESNEL
            int _HasFresnel;
            float4 _FresnelColor;
            float _FresnelPower;


            // 3 - RUÍDO
            int _HasNoiseDistortion;
            float3 _NoiseDirection;
            float _NoiseSpeed;
            sampler2D _NoiseTextureX;
            sampler2D _NoiseTextureY;


            // 4 - PULSAÇÃO
            int _HasPulse;
            float4 _PulseColor;
            float _PulseSpeed;


            // 5 - LAZER
            int _HasLazer;
            float4 _LazerColor;
            float _LazerSpeed;
            float _LazerWidth;


            // 6 - DISTORÇÃO DE VÉRTICES
            int _HasVertexDistortion;
            sampler2D _NoiseVertex;
            float _DistortionVertex;
            float _SpeedVertex;


            // estas diretivas definem um buffer que armazena dados de cada instância do objeto, o que permite a renderização eficiente de múltiplas cópias de um objeto com variações mínimas
            UNITY_INSTANCING_BUFFER_START(Props)
            UNITY_INSTANCING_BUFFER_END(Props)


            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                float3 viewDir : TEXCOORD1;
            };


            float2 RotateUV(float2 uv, float angleRadians)
            {
                float s = sin(angleRadians);
                float c = cos(angleRadians);
             
                uv -= 0.5;
                
                float2 rotatedUV;
                rotatedUV.x = uv.x * c - uv.y * s;
                rotatedUV.y = uv.x * s + uv.y * c;
            
                return rotatedUV + 0.5;
            }

            float fresnel(float amount, float3 normal, float3 view)
            {
                return pow((1.0 - saturate(dot(normalize(normal), normalize(view)))), amount);
            }

            float3 pulse(float2 uv, float4 screenParams, float4 pulseColor, float4 time, float _PulseRadialSpeed)
            {
                // normalizar as coordenadas para variar entre -1 a 1 em x e y
                float2 fragCoord = uv * screenParams.xy;
                float2 normalizedCoords = (2.0 * fragCoord - screenParams.xy) / screenParams.y;

                // calcular distância radial do pixel ao centro do objeto
                float radialDistance = length(normalizedCoords ) * 0.9;
                float squaredRadialDistance = pow(radialDistance, 2.0);

                // combinar 2 funções seno com a distância ao quadrado
                float sin1 = sin(radialDistance * 0.8 - 1.6);
                float sin2 = sin(radialDistance - 0.010);
                float combinedSin = sin(squaredRadialDistance - time.y * _PulseRadialSpeed + sin1) * sin2;

                // aplicar a cor de pulsaçõ baseada no valor combinado
                pulseColor.rgb *= abs(1.0 / (combinedSin * 10.8)) - 0.01;
                return pulseColor.rgb;
            }


            float laser(float2 uv, float speed, float width, float4 time)
            {
                // posição vertical entre 0 (baixo) e 1 (topo)
                float lazerPosition = abs(frac(time.y * speed * 0.5) * 2.0 - 1.0);
                   
                float lazerCenter = lazerPosition;
                float distance = abs(uv.y - lazerCenter);
                float blur = smoothstep(0, 2, distance);

                float alpha = smoothstep(width * 0.5, -width * 0.5, distance);
                alpha *= (1.0 - blur);
                alpha *= 5;

                return alpha;
            }


            v2f vert(appdata v)
            {
                v2f o;


                /*******************************************************
                *                   2 - EFEITO FRESNEL                 *
                *******************************************************/

                // aplicar efeito fresnel
                if (_HasFresnel == 1)
                {
                    o.vertex += fresnel(_FresnelPower, o.normal, o.viewDir);
                }


                /*******************************************************
                *                   6 - DEFORMAR VÉRTICES              *
                *******************************************************/

                // aplicar deformação de vértices
                if (_HasVertexDistortion == 1)
                {
                    float4 noiseSample = tex2Dlod(_NoiseVertex, float4(v.uv + (_Time.y * _SpeedVertex), 0, 0));
                    float noiseVal = (noiseSample.r * 2.0) - 1.0;  // entre -1 e 1
                    float3 displacement = v.normal * noiseVal * _DistortionVertex;
                    v.vertex.xyz += displacement;
                }


                o.uv = v.uv;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.viewDir = normalize(ObjSpaceViewDir(v.vertex));
                o.vertex = UnityObjectToClipPos(v.vertex);

                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                // para serem usadas em mais do que um efeito
                float4 finalColor = tex2D(_MainTexture, i.uv) * _Color;
                float2 finalUV = i.uv;


                /*******************************************************
                *                   1 - ROTAÇÃO                        *
                *******************************************************/

                // aplicar rotação
                if (_HasRotation == 1)
                {
                    if (_RotationIsFixed) {
                        finalUV = RotateUV(i.uv, radians(_AngleDegrees));
                    } else {
                        finalUV = RotateUV(i.uv, _Time.y * _RotationSpeed);
                    }

                    float4 rotatedTexture = tex2D(_MainTexture, finalUV) * _Color;
                    finalColor.rgb = rotatedTexture.rgb;
                }


                /*******************************************************
                *                   2 - EFEITO FRESNEL                 *
                *******************************************************/

                // aplicar efeito fresnel
                if (_HasFresnel == 1)
                {
                    float3 fresnelTint = (_FresnelColor.rgb * fresnel(_FresnelPower, i.normal, i.viewDir));

                    // 0.5: fornece um equilíbrio igual entre as duas texturas
                    finalColor.rgb = lerp(finalColor.rgb, fresnelTint.rgb, 0.5);
                }
                

                /*******************************************************
                *                   3 - RUÍDO                          *
                *******************************************************/

                // aplicar ruído
                if (_HasNoiseDistortion == 1)
                {
                    // velocidade do movimento
                    float2 noiseOffset = _NoiseDirection.xy * _Time.y * _NoiseSpeed;

                    // direção do movimento
                    float2 uvNoiseX = finalUV + noiseOffset;
                    float2 uvNoiseY = finalUV + noiseOffset;

                    float noiseValueX = (tex2D(_NoiseTextureX, uvNoiseX).r * 2.0) - 1.0;  // entre -1 e 1
                    float noiseValueY = (tex2D(_NoiseTextureY, uvNoiseY).r * 2.0) - 1.0;  // entre -1 e 1
                    float2 noiseDistort = float2(noiseValueX, noiseValueY) * _NoiseDirection;

                    float3 noiseTexture2 = tex2D(_MainTexture, finalUV + noiseDistort) * _Color;

                    finalColor.rgb = lerp(finalColor.rgb, noiseTexture2, 0.5);
                }
                

                /*******************************************************
                *                   4 - PULSAÇÃO                       *
                *******************************************************/

                // aplicar pulsação
                if (_HasPulse == 1)
                {
                    float3 pulseColor = pulse(i.uv, _ScreenParams, _PulseColor, _Time, _PulseSpeed);
                    finalColor.rgb = lerp(finalColor.rgb, pulseColor.rgb, 0.5);
                }


                /*******************************************************
                *                   5 - LAZER                          *
                *******************************************************/

                // aplicar lazer
                if (_HasLazer == 1)
                {
                    float laserAlpha = laser(i.uv, _LazerSpeed, _LazerWidth, _Time);
                    finalColor.rgb = lerp(finalColor.rgb, _LazerColor.rgb, laserAlpha);
                }


                /*******************************************************
                *                   COR FINAL                          *
                *******************************************************/

                return float4(finalColor.rgb, finalColor.a);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}