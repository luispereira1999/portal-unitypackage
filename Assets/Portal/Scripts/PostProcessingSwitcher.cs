using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PostProcessingSwitcher : MonoBehaviour
{
    public Material normalEffect;

    public Material portalEffect;

    public PostProcess postProcess;
    // Start is called before the first frame update
    private void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag("Player"))
        {
            postProcess.m = portalEffect;
            Debug.Log("Entered the invisible box. Post-processing profile changed to grayscale.");
        }
    }

    private void OnTriggerExit(Collider other)
    {
        if (other.CompareTag("Player"))
        {
            postProcess.m = normalEffect;
            Debug.Log("Exited the invisible box. Post-processing profile changed to normal.");
        }
    }


}
