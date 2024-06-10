Shader "Unlit/ShieldShader"
{
 Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Main Texture", 2D) = "white" {}
        _SecondaryTex ("Secondary Texture", 2D) = "white" {}
        _MainTexSpeed ("Main Texture Speed", float) = 0.1
        _SecondaryTexSpeed ("Secondary Texture Speed", float) = 0.1
        _MainTexTransparency ("Main Texture Transparency", float) = 0.5
        _SecondaryTexTransparency ("Secondary Texture Transparency", float) = 0.5

        _GlowColor ("Edge Glow Color", Color) = (1,1,1,1)
        _GlowMinWidth ("Edge Glow Min Width", Range(0, 0.1)) = 0.01
        _GlowMaxWidth ("Edge Glow Max Width", Range(0, 0.5)) = 0.1

        _DistortionTex ("Distortion Texture", 2D) = "white" {}
        _DistortionStrength ("Distortion Strength", Range(0, 1)) = 0.1

        _DissolveTexture ("Dissolve Texture", 2D) = "white" {}
        _DissolveAmount ("Dissolve Amount", Range(0, 1)) = 0.0
        _ColorDissolveMask ("Edge Dissolve Color", Color) = (1, 0, 0, 1)
        _EdgeDissolveWidth("Edge Dissolve Width", Range(0, 0.1)) = 0.05


    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        LOD 200

        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha // para correta mistura de transparência
            ZWrite Off //por causa da profundidade
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata_t
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 worldNormal : TEXCOORD1;
                float3 worldPos : TEXCOORD2;
            };

            //variáveis relacionadas com textura
            sampler2D _MainTex;
            sampler2D _SecondaryTex;
            float _MainTexSpeed;
            float _SecondaryTexSpeed;
            float _MainTexTransparency;
            float _SecondaryTexTransparency;
            float4 _MainTex_ST;
            float4 _SecondaryTex_ST;
            float4 _Color;

            //variaveis relacionadas com distorção
            sampler2D _DistortionTex; 
            float _DistortionStrength;
          
            //variáveis relacionadas com brilho
            float4 _GlowColor;
            float _GlowMinWidth;
            float _GlowMaxWidth;

            //variáveis relacionadas com dissolução
            sampler2D _DissolveTexture;
            float _DissolveAmount;
            float4 _ColorDissolveMask;
            float _EdgeDissolveWidth;

            v2f vert (appdata_t v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                // calcula a distorção, que pode ser tanto na direção positiva como negativa
                float2 distortion = tex2D(_DistortionTex, i.uv).rg * 2.0 - 1.0;
                distortion *= _DistortionStrength;
                
                // calcula as coordenadas uv para o movimento horizontal da textura principal
                float2 mainTexUV = i.uv + distortion;
                mainTexUV.x += _Time.x * _MainTexSpeed;

                float4 mainTexColor = tex2D(_MainTex, mainTexUV);
                mainTexColor.a *= _MainTexTransparency;

                // calcula as coordenadas uv para o movimento vertical da textura secundária
                float2 secondaryTexUV = i.uv + distortion;
                secondaryTexUV.y += _Time.y * _SecondaryTexSpeed;

                float4 secondaryTexColor = tex2D(_SecondaryTex, secondaryTexUV);
                secondaryTexColor.a *= _SecondaryTexTransparency;

                //mistura as cores das texturas
                float4 blendedColor = mainTexColor + secondaryTexColor; 

                // aplica a cor e mantém a textura
                half4 color = _Color * blendedColor;
                color.a = blendedColor.a * _Color.a;

                // calcula o efeito de brilho
                float pulsatingWidth = lerp(_GlowMinWidth, _GlowMaxWidth, (sin(_Time.y * 2.0) * 0.5 + 0.5));
                float edgeDist = min(i.uv.x, min(1.0 - i.uv.x, min(i.uv.y, 1.0 - i.uv.y)));
                float glowFactor = smoothstep(0.0, pulsatingWidth, edgeDist);
                half4 edgeGlow = _GlowColor * glowFactor;
                color.rgb += edgeGlow.rgb * edgeGlow.a;

                // efeito de dissolver
                float dissolveValue = tex2D(_DissolveTexture, i.uv).g;
                float dissolveAlpha = step(dissolveValue, _DissolveAmount);
                
                // borda no efeito de dissolver
                float dissolveEdgeFactor = smoothstep(_DissolveAmount - _EdgeDissolveWidth, _DissolveAmount, dissolveValue);
                half4 dissolveEdgeColor = _ColorDissolveMask * dissolveEdgeFactor;
                color.rgb = lerp(color.rgb, dissolveEdgeColor.rgb, dissolveEdgeColor.a);
                
                color.a *= dissolveAlpha;
                return color;
            }
            ENDCG
        }
    }
    Fallback "Diffuse"
}