Shader "Custom/BlurShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BlurSize ("Blur Size", Range(0.0, 1.0)) = 0.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
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
            };

            sampler2D _MainTex;
            float _BlurSize;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 uv = i.uv;
                float2 offset = _BlurSize / _ScreenParams.xy;

                fixed4 color = tex2D(_MainTex, uv) * 0.227027;
                color += tex2D(_MainTex, uv + float2(offset.x, 0)) * 0.1945946;
                color += tex2D(_MainTex, uv - float2(offset.x, 0)) * 0.1945946;
                color += tex2D(_MainTex, uv + float2(0, offset.y)) * 0.1945946;
                color += tex2D(_MainTex, uv - float2(0, offset.y)) * 0.1945946;
                color += tex2D(_MainTex, uv + offset) * 0.1216216;
                color += tex2D(_MainTex, uv - offset) * 0.1216216;

                return color;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}