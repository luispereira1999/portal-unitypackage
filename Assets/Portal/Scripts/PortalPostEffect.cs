using System;
using UnityEngine;
using UnityEngine.Rendering.PostProcessing;

[Serializable]
[PostProcess(typeof(PortalPostRenderer), PostProcessEvent.AfterStack, "Custom/PortalEffect")]
public sealed class PortalPostEffect : PostProcessEffectSettings
{
    [Tooltip("Intensity of the grayscale effect.")]
    public FloatParameter intensity = new FloatParameter { value = 1f };
}

public sealed class PortalPostRenderer : PostProcessEffectRenderer<PortalPostEffect>
{
    public override void Render(PostProcessRenderContext context)
    {
        var sheet = context.propertySheets.Get(Shader.Find("Custom/PortalEffect"));
        sheet.properties.SetFloat("_Intensity", settings.intensity);
        context.command.BlitFullscreenTriangle(context.source, context.destination, sheet, 0);
    }
}
