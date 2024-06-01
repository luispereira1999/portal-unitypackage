Shader "Custom/Portal4"
{
    Properties
    {
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
        Tags { "RenderType"="Opaque" }
        LOD 100

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
                fixed3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float rim : TEXCOORD1;
                float4 position : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float4 _Color;
            float4 _StripeColor;
            float _StripeWidth;
            float _Speed;

            float _RotationSpeed;

            half _FresnelPower;
            half2 _ScrollDirection;

            float _LineThickness;
            float _BlurAmount;

            v2f vert(appdata v)
            {
                v2f o;

                o.position = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                fixed3 viewDir = normalize(ObjSpaceViewDir(v.vertex));
                o.rim = 1.0 - saturate(dot(viewDir, v.normal));

                o.uv += _ScrollDirection * _Time.y;
               
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 pixel = tex2D(_MainTex, i.uv) * _Color * pow(_FresnelPower, i.rim);
                pixel = lerp(0, pixel, i.rim);
                
                return clamp(pixel, 0, _Color);
            }
            ENDCG
        }
    }
}
