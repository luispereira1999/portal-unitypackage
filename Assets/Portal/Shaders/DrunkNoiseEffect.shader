Shader "Custom/DrunkNoiseEffect"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _NoiseStrength ("Noise Strength", Range(0, 1)) = 0.05
        _WaveStrength ("Wave Strength", Range(0, 1)) = 0.02
        _TimeScale ("Time Scale", Range(0, 10)) = 1.0
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
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _NoiseStrength;
            float _WaveStrength;
            float _TimeScale;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            // Function to generate random noise based on a seed value
            float random (float2 st) 
            {
                return frac(sin(dot(st.xy, float2(12.9898,78.233))) * 43758.5453123);
            }

            float3 noise (float2 uv, float time)
            {
                float strength = _NoiseStrength;
                float x = uv.x * 10.0 + time * 0.5;
                float y = uv.y * 10.0 + time * 0.5;
                float n = random(float2(x, y));
                return float3(n * strength, n * strength, n * strength);
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float time = _Time.y * _TimeScale;

                // Sample the original color from the texture
                float3 color = tex2D(_MainTex, i.uv).rgb;

                // Apply horizontal wave distortion
                float2 waveOffset = float2(sin(i.uv.y * 10.0 + time) * _WaveStrength, 0.0);
                float3 distortedColor = tex2D(_MainTex, i.uv + waveOffset).rgb;

                // Apply noise
                float3 noisyColor = distortedColor + noise(i.uv, time);

                // Final color output
                return float4(noisyColor, 1.0);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
