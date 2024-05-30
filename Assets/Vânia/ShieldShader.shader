Shader "Unlit/ShieldShader"
{
   
     Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Main Texture", 2D) = "white" {}
        _SecondaryTex ("Secondary Texture", 2D) = "white" {}
        _BlendFactor ("Blend Factor", Range(0, 1)) = 0.5
        _MainTexSpeed ("Main Texture Speed", float) = 0.1
        _SecondaryTexSpeed ("Secondary Texture Speed", float) = 0.1
        _MainTexTransparency ("Main Texture Transparency", Range(0, 1)) = 0.5
        _SecondaryTexTransparency ("Secondary Texture Transparency", Range(0, 1)) = 0.5
        _EdgeGlowColor ("Edge Glow Color", Color) = (1,1,1,1)
        _EdgeGlowWidth ("Edge Glow Width", Range(0, 0.7)) = 0.1
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

            sampler2D _MainTex;
            sampler2D _SecondaryTex;
            float4 _MainTex_ST;
            float4 _SecondaryTex_ST;
            float4 _Color;
            float _BlendFactor;
            float _MainTexSpeed;
            float _SecondaryTexSpeed;
            float _MainTexTransparency;
            float _SecondaryTexTransparency;
            float4 _EdgeGlowColor;
            float _EdgeGlowWidth;

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
                
                // calcula as coodernadas uv para o movimento vertical da textura principal
                float2 mainTexUV = i.uv;
                mainTexUV.x += _Time.x * _MainTexSpeed;

                float4 mainTexColor = tex2D(_MainTex, mainTexUV);
                mainTexColor.a *= _MainTexTransparency;

                // calcula as coodernadas uv para o movimento vertical da segunda textura
                float2 secondaryTexUV = i.uv;
                secondaryTexUV.y += _Time.y * _SecondaryTexSpeed;

                float4 secondaryTexColor = tex2D(_SecondaryTex, secondaryTexUV);
                secondaryTexColor.a *= _SecondaryTexTransparency;

                // mistura as cores das texturas
                float4 blendedColor = lerp(mainTexColor, secondaryTexColor, _BlendFactor);

              //aplica a cor e mantém a textura
                half4 color = _Color * blendedColor;
                color.a = blendedColor.a * _Color.a;

                //calcula o efeito de glow nas extremidades
                float edgeDist = min(i.uv.x, min(1.0 - i.uv.x, min(i.uv.y, 1.0 - i.uv.y)));
                float glowFactor = smoothstep(0.0, _EdgeGlowWidth, edgeDist) * smoothstep(0.0, _EdgeGlowWidth, 1.0 - edgeDist);
                half4 edgeGlow = _EdgeGlowColor * glowFactor;

   
                color.rgb += edgeGlow.rgb * edgeGlow.a;

                return color;
            }
            ENDCG
        }
    }
    Fallback "Diffuse"
}