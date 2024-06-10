using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DissolveEffect : MonoBehaviour
{
    public float dissolveSpeed = 0.1f; 
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
        float dissolveAmount = 0;

        while (dissolveAmount <= 1) 
        {
            dissolveAmount += Time.deltaTime * dissolveSpeed;
            shieldMaterial.SetFloat("_DissolveAmount", 1 - dissolveAmount); 
            yield return null;
        }

        Destroy(gameObject);
    }
}