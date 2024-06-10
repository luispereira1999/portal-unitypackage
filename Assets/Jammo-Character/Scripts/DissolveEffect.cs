using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DissolveEffect : MonoBehaviour
{
    public float dissolveSpeed = 1f; 
    private void OnCollisionEnter(Collision collision)
    {
        if (collision.gameObject.CompareTag("Shield"))
        {
            Renderer shieldRenderer = collision.gameObject.GetComponent<Renderer>();
      
            StartCoroutine(DissolveObject(shieldRenderer.material));
        }
    }

    IEnumerator DissolveObject(Material shieldMaterial)
    {
        float dissolveAmount = 1; 

        while (dissolveAmount > 0)
        {
            dissolveAmount -= 0.05f * dissolveSpeed; 
       
            shieldMaterial.SetFloat("_DissolveAmount", dissolveAmount); 
            yield return null;
        }

        Destroy(gameObject);
    }
}