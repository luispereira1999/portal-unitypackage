using UnityEngine;

public class BlurController : MonoBehaviour
{
    public Material blurMaterial;
    public float blurAmountInside = 0.05f;
    public float blurAmountOutside = 0.0f;
    public float transitionSpeed = 2.0f;
    private float currentBlurAmount = 0.0f;
    private bool insideSphere = false;

    void Start()
    {
        if (blurMaterial != null)
        {
            blurMaterial.SetFloat("_BlurSize", blurAmountOutside);
            currentBlurAmount = blurAmountOutside;
        }
    }

    void Update()
    {
        if (blurMaterial != null)
        {
            float targetBlur = insideSphere ? blurAmountInside : blurAmountOutside;
            currentBlurAmount = Mathf.Lerp(currentBlurAmount, targetBlur, Time.deltaTime * transitionSpeed);
            blurMaterial.SetFloat("_BlurSize", currentBlurAmount);
        }
    }

    void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag("Player"))
        {
            insideSphere = true;
        }
    }

    void OnTriggerExit(Collider other)
    {
        if (other.CompareTag("Player"))
        {
            insideSphere = false;
        }
    }
}