Shader "Custom/Portal3"
{
    Properties
    {
        // _Color ("Main Color", Color) = (1,1,1,0.5)
        [HDR] _Color ("Color", Color) = (1, 1, 1, 1)

        _StripeColor ("Stripe Color", Color) = (0,0,0,1)
        _MainTex ("Base (RGB)", 2D) = "white" {}
        _StripeWidth ("Stripe Width", Range(0,1)) = 0.1
        _Speed ("Speed", Range(0, 10)) = 1.0

        _RotationSpeed ("Rotation Speed", Range(0.0, 10.0)) = 1.0

        _FresnelPower("Fresnel Power", Range(0, 10)) = 3
        _ScrollDirection ("Scroll Direction", float) = (0, 0, 0, 0)

        _LineThickness ("Line Thickness", Range(0.001, 1)) = 0.02
        _BlurAmount ("Blur Amount", Range(0.0, 1.0)) = 0.1
    }
    SubShader
    {
        Tags { "Queue" = "Transparent" "RenderType"="Transparent" }
        LOD 100

        // Cull off

        Pass
        {
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha
            ColorMask RGB

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata_t
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                // fixed3 normal : NORMAL;
            };

            struct v2f
            {
                // float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                // float rim : TEXCOORD1;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _Color;
            float4 _StripeColor;
            float _StripeWidth;
            float _Speed;

            float _RotationSpeed;

            half _FresnelPower;
            half2 _ScrollDirection;
            float4 _MainTex_ST;

           float _LineThickness;
            float _BlurAmount;

            v2f vert (appdata_t v)
            {
                // v2f o;
                // o.pos = UnityObjectToClipPos(v.vertex);
                // o.uv = v.uv;
                // o.uv.x = 2 * v.uv.x;
                // return o;


                // v2f o;

                // o.pos = UnityObjectToClipPos(v.vertex);
                // o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                // fixed3 viewDir = normalize(ObjSpaceViewDir(v.vertex));
                // o.rim = 1.0 - saturate(dot(viewDir, v.normal));

                // // o.uv += _ScrollDirection * _Time.y;
                // // o.uv.x = 1.85 * v.uv.x;
                // o.uv += _ScrollDirection * _Time.y;
                // o.uv.x = 1.85 * v.uv.x;
               
                // return o;

                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float2 RotateUV(float2 uv, float angle)
            {
                float s = sin(angle);
                float c = cos(angle);
                float2x2 rotationMatrix = float2x2(c, -s, s, c);
                uv -= 0.5;
                uv = mul(rotationMatrix, uv);
                uv += 0.5;
                return uv;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // fixed4 baseColor = tex2D(_MainTex, i.uv) * _Color;

                // // Calcular o deslocamento baseado no tempo
                // float offset = _Time.y * _Speed;

                // // Calcular as riscas
                // float stripePattern = step(0.5 - _StripeWidth / 2, frac((i.uv.y + offset) / _StripeWidth)) * step(frac((i.uv.y + offset) / _StripeWidth), 0.5 + _StripeWidth / 2);
                // fixed4 stripeColor = _StripeColor * stripePattern;

                // // Misturar a cor base com as riscas
                // fixed4 finalColor = lerp(baseColor, stripeColor, stripePattern);
                // finalColor.a = 0.7 * _Color.a; // Manter a transparência configurada

                // return finalColor;




                // fixed4 baseColor = tex2D(_MainTex, i.uv) * _Color;

                // // Calcular o deslocamento baseado no tempo
                // float offset = _Time.y * _Speed;

                // // Calcular as riscas
                // float stripePattern = step(0.5 - _StripeWidth / 2, frac((i.uv.y + offset) / _StripeWidth)) * step(frac((i.uv.y + offset) / _StripeWidth), 0.5 + _StripeWidth / 2);
                // fixed4 stripeColor = _StripeColor * stripePattern;

                // // Misturar a cor base com as riscas
                // fixed4 finalColor = lerp(baseColor, stripeColor, stripePattern);
                // finalColor.a = baseColor.a; // Manter a transparência configurada

                // return finalColor;




                // float rotationAngle = _Time * _RotationSpeed;
                // float2 rotatedUV = RotateUV(i.uv, rotationAngle);
                // fixed4 col = tex2D(_MainTex, rotatedUV);
                // col.rgb = float3(0, 0, 1);
                // return col;




                // fixed4 baseColor = tex2D(_MainTex, i.uv) * _Color;

                // // Calcular o deslocamento baseado no tempo
                // float offset = _Time.y * _Speed;

                // // Calcular as riscas
                // float stripePattern = step(0.5 - _StripeWidth / 2, frac((i.uv.y + offset) / _StripeWidth)) * step(frac((i.uv.y + offset) / _StripeWidth), 0.5 + _StripeWidth / 2);

                // // Calcular a amplitude pulsante baseada no tempo usando uma função senoidal
                // float pulseAmplitude = abs(sin(_Time.y * 2 * 3.14159)); // Frequência de pulso de uma vez por segundo (2 * pi)
                // float pulseFactor = 1.0 + pulseAmplitude * 0.5; // Fator de pulsar para amplificar a amplitude

                // // Aplicar o fator de pulsar à intensidade das riscas
                // stripePattern *= pulseFactor;

                // // Calcular a cor das riscas
                // fixed4 stripeColor = _StripeColor * stripePattern;

                // // Misturar a cor base com as riscas
                // fixed4 finalColor = lerp(baseColor, stripeColor, stripePattern);
                // finalColor.a = 0.7 * _Color.a; // Manter a transparência configurada

                // return finalColor;


                // float rotationAngle = _Time * _RotationSpeed;
                // float2 rotatedUV = RotateUV(i.uv, rotationAngle);
                // // fixed4 col = tex2D(_MainTex, rotatedUV);
                // // col.rgb = float3(0, 0, 1);

                // float4 pixel = tex2D(_MainTex, rotatedUV) * _Color * pow(_FresnelPower, i.rim);
                // pixel = lerp(0.5, pixel, i.rim);
                
                // return clamp(pixel, 0, _Color);



                // fixed4 baseColor = tex2D(_MainTex, i.uv) * _Color;

                // // Calcular o deslocamento baseado no tempo
                // float offset = _Time.y * _Speed;

                // // Número de riscas desejadas
                // int numStripes = 2;

                // // Altura das riscas (entre 0 e 1)
                // float stripeHeight = 0.3; // Defina a altura desejada aqui (por exemplo, 0.3 para 30%)

                // // Calcular as riscas com base no número desejado e na altura especificada
                // float stripePattern = 0.0;
                // for (int s = 0; s < numStripes; s++)
                // {
                //     // Calcular a posição da risca
                //     float stripeWidth = 1.0 / numStripes;
                //     float stripePos = stripeWidth * s;

                //     // Adicionar cada risca
                //     stripePattern += step(stripePos - stripeWidth / 2.0, frac((i.uv.y + offset) / stripeWidth)) * step(frac((i.uv.y + offset) / stripeWidth), stripePos + stripeWidth / 2.0) * step(stripeHeight, i.uv.y);
                // }

                // // Calcular a cor das riscas
                // fixed4 stripeColor = _StripeColor * stripePattern;

                // // Misturar a cor base com as riscas
                // fixed4 finalColor = lerp(baseColor, stripeColor, stripePattern);
                // finalColor.a = 0.7 * _Color.a; // Manter a transparência configurada

                // return finalColor;



                fixed4 baseColor = tex2D(_MainTex, i.uv) * _Color;
                float offset = _Time.y * _Speed;
                int numStripes = 1;
                float stripeHeight = 0.1;

                float stripePattern = 0.0;
                for (int s = 0; s < numStripes; s++)
                {
                    float stripeWidth = 1.0 / numStripes;
                    float stripePos = stripeWidth * s;
                    stripePattern += step(stripePos - stripeWidth / 2.0, frac((i.uv.y + offset) / stripeWidth)) * step(frac((i.uv.y + offset) / stripeWidth), stripePos + stripeWidth / 2.0) * step(stripeHeight, i.uv.y);
                }

                fixed4 stripeColor = _StripeColor * stripePattern;
                fixed4 finalColor = lerp(baseColor, stripeColor, stripePattern);
                // finalColor.a = 0.7 * _Color.a;
                finalColor.a = 3 * _Color.a;
                // return finalColor;




                float position = abs(frac(_Time.y * _Speed * 0.5) * 2.0 - 1.0); // Vertical position between 0 and 1
                float lineCenter = position;
                float distance = abs(i.uv.y - lineCenter);
                float blur = smoothstep(0.0, _BlurAmount, distance);

                float alpha = smoothstep(0.0, _LineThickness * 0.5, _LineThickness * 0.5 - distance);
                alpha *= (1.0 - blur);

                return fixed4(finalColor.rgb, finalColor.a * alpha);
            }
            ENDCG
        }
    }
}