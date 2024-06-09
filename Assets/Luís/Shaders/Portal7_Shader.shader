Shader "Custom/Portal7"
{
    Properties
    {
        _DistortionView ("Distortion View", Range(0.0, 0.3)) = 0.03
        _SpeedView ("Speed View", Range(0.0, 1.0)) = 0.5
        _NoiseViewX ("Noise View X", 2D) = "white" {}
        _NoiseViewY ("Noise View Y", 2D) = "white" {}
        _ScreenTexture ("Screen Texture", 2D) = "white" {}
        _TintColor ("Tint Color", Color) = (1,1,1,1)
        _FresnelAmount ("Fresnel Amount", Range(0.0, 5.0)) = 0.1
        _DistortionVertex ("Distortion Vertex", Range(0.0, 0.3)) = 0.03
        _SpeedVertex ("Speed Vertex", Range(0.0, 1.0)) = 0.1
        _NoiseVertex ("Noise Vertex", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
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
            float _FresnelAmount;
            float _DistortionView;
            float _SpeedView;

            // vertex uniforms
            sampler2D _NoiseVertex;
            float _DistortionVertex;
            float _SpeedVertex;

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

            float fresnel(float amount, float3 normal, float3 view)
            {
                return pow((1.0 - saturate(dot(normalize(normal), normalize(view)))), amount);
            }

            v2f vert(appdata v)
            {
                v2f o;

                o.uv = v.uv;
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

            fixed4 frag(v2f i) : SV_Target
            {
                float noiseValueX = (tex2D(_NoiseViewX, i.uv + (_Time.y * _SpeedView)).r * 2.0) - 1.0; // Range: -1.0 to 1.0
                float noiseValueY = (tex2D(_NoiseViewY, i.uv + (_Time.y * _SpeedView)).r * 2.0) - 1.0; // Range: -1.0 to 1.0
                float2 noiseDistort = float2(noiseValueX, noiseValueY) * _DistortionView;

                float3 distortedScreenTexture = tex2D(_ScreenTexture, i.uv + noiseDistort).rgb;
                float3 fresnelTint = (_TintColor.rgb * fresnel(_FresnelAmount, i.normal, i.viewDir));

                return float4(distortedScreenTexture + fresnelTint, 1.0);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}