Shader "Unlit/Lighting"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _FadeSpeed ("Fade Speed", Range(0, 10)) = 1.0
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
            // make fog work
            #pragma multi_compile_fog

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
            float4 _MainTex_ST;
            float _FadeSpeed;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);

                float _Threshold = 0.3;

                if (col.r < _Threshold || col.g < _Threshold || col.b < _Threshold) {
                    col.a = 0.0;
                    return col;
                }

                float alpha = sin(_Time.y * _FadeSpeed + i.uv.y );

                fixed4 finalColor = col ;// * _Color;
                //float curTime = (_Time.y ) % 1;
                finalColor.a *= alpha;
                //finalColor.a = curTime > 0.5 ? 1.0 : 0.0;                

                return finalColor;
            }
            ENDCG
        }
    }
}
