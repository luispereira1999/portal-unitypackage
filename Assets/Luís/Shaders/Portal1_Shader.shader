Shader "Custom/Portal1"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        [HDR] _Color ("Color", Color) = (1,1,1,1)

        _FresnelPower("Fresnel Power", Range(0, 10)) = 3
        _ScrollDirection ("Scroll Direction", float) = (0, 0, 0, 0)

        _EdgeColor ("Edge Color", Color) = (1,1,1,1)
        _EdgeThickness ("Edge Thickness", Range(0,1)) = 0.1
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "IgnoreProjector"="True" "Queue"="Transparent" }
        Blend SrcAlpha OneMinusSrcAlpha
        LOD 100
        Cull Back
        Lighting Off
        ZWrite On

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
                float2 uv : TEXCOORD0;
                fixed3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float rim : TEXCOORD1;
                float4 pos : SV_POSITION;

                // float3 worldNormal : TEXCOORD0;
                // float3 worldPos : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            fixed4 _Color;
            half _FresnelPower;
            half2 _ScrollDirection;

            float4 _EdgeColor;
            float _EdgeThickness;

            UNITY_INSTANCING_BUFFER_START(Props)
            UNITY_INSTANCING_BUFFER_END(Props)

            v2f vert (appdata v)
            {
                v2f o;

                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                fixed3 viewDir = normalize(ObjSpaceViewDir(v.vertex));
                o.rim = 1 - saturate(dot(viewDir, v.normal));

                o.uv += _ScrollDirection * _Time.y;


                // o.pos = UnityObjectToClipPos(v.vertex);
                // o.worldNormal = normalize(mul((float3x3)unity_ObjectToWorld, v.normal));
                // o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 pixel = tex2D(_MainTex, i.uv) * _Color * pow(_FresnelPower, i.rim);
                pixel = lerp(0, pixel, i.rim);
                return clamp(pixel, 0, _Color);


                // fixed4 pixel = tex2D(_MainTex, i.uv) * _Color * pow(_FresnelPower, i.rim);
                // fixed4 blackColor = fixed4(0, 0, 0, 1);
                // pixel = lerp(pixel, blackColor, i.rim);
                // blackColor.a=1;
                // return i.rim * blackColor;


                // float3 viewDir = normalize(i.worldPos - _WorldSpaceCameraPos);
                // float edgeFactor = dot(viewDir, i.worldNormal);
                // edgeFactor = 1.0 - abs(edgeFactor); // Valores altos nas bordas

                // float4 color = lerp(float4(0, 0, 0, 1), _EdgeColor, smoothstep(1.0 - _EdgeThickness, 1.0, edgeFactor));
                // return color;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}