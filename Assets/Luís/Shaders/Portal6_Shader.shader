Shader "Custom/Portal6"
{
    Properties
    {
        _MainTex ("Base (RGB)", 2D) = "white" {}
        _BlurSize ("Blur Size", Float) = 1.0
    }
    SubShader
    {
        Tags{ "RenderType"="Transparent" "Queue"="Transparent"}

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
            float4 _MainTex_TexelSize;
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
                float4 color = fixed4(0,0,0,0);

                // Gaussian blur kernel
                float kernel[9];
                kernel[0] = 0.05;
                kernel[1] = 0.09;
                kernel[2] = 0.12;
                kernel[3] = 0.15;
                kernel[4] = 0.18;
                kernel[5] = 0.15;
                kernel[6] = 0.12;
                kernel[7] = 0.09;
                kernel[8] = 0.05;

                // Offsets for sampling
                float2 offset[9];
                offset[0] = float2(-1, -1) * _BlurSize * _MainTex_TexelSize.xy;
                offset[1] = float2( 0, -1) * _BlurSize * _MainTex_TexelSize.xy;
                offset[2] = float2( 1, -1) * _BlurSize * _MainTex_TexelSize.xy;
                offset[3] = float2(-1,  0) * _BlurSize * _MainTex_TexelSize.xy;
                offset[4] = float2( 0,  0) * _BlurSize * _MainTex_TexelSize.xy;
                offset[5] = float2( 1,  0) * _BlurSize * _MainTex_TexelSize.xy;
                offset[6] = float2(-1,  1) * _BlurSize * _MainTex_TexelSize.xy;
                offset[7] = float2( 0,  1) * _BlurSize * _MainTex_TexelSize.xy;
                offset[8] = float2( 1,  1) * _BlurSize * _MainTex_TexelSize.xy;

                for (int j = 0; j < 9; j++)
                {
                    color += tex2D(_MainTex, uv + offset[j]) * kernel[j];
                }

                return color;
            }
            ENDCG
        }
    }
}