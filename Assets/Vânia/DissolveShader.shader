Shader "Custom/DissolveShader"

{ 
Properties
    {
        _main_tex ("Main Texture", 2D) = "white" {}
        _dissolve_tex ("Dissolve Texture", 2D) = "white" {}
        _dissolve_amount ("Dissolve Amount", Range(0,1)) = 0.0
        _line_size("Line Width", Range(0.0, 0.1)) = 0.1
        _line_color("Line Color", Color) = (1.0, 1.0, 1.0, 1.0)
	}
    SubShader
    {
        Tags { "Queue"="Transparent" "RenderType"="Transparent" }
        LOD 200

        //para misturar o objeto corretamente com o fundo
        Blend SrcAlpha OneMinusSrcAlpha
        // para evitar problemas de profundidade
        ZWrite Off

        CGPROGRAM
        #pragma surface surf Standard alpha:fade

        sampler2D _main_tex;
        sampler2D _dissolve_tex;
        float _dissolve_amount;
        float _line_size;
       
        struct Input
        {
            float2 uv_main_tex;
            float2 uv_dissolve_tex;
        };

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            half4 mainTex = tex2D(_main_tex, IN.uv_main_tex);
            half4 dissolveTex = tex2D(_dissolve_tex, IN.uv_dissolve_tex);

            float dissolveValue = dissolveTex.r;

            // Set alpha based on dissolve
            float alpha = mainTex.a;

            if (dissolveValue + _dissolve_amount < 1.0)
            {
                alpha = 0.0;
            }

            o.Albedo = mainTex.rgb;
            o.Alpha = alpha;
        }
        ENDCG
    }
    FallBack "Diffuse"
}