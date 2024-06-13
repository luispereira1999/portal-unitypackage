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
            StartCoroutine(DissolveObject(collision.gameObject));
        }
    }

        IEnumerator DissolveObject(GameObject shield)
    {
        float dissolveAmount = 1; 
        Renderer shieldRenderer = shield.GetComponent<Renderer>();

        while (dissolveAmount > 0)
        {
            dissolveAmount -= 0.05f * dissolveSpeed; 
       
            shieldRenderer.material.SetFloat("_DissolveAmount", dissolveAmount); 
            yield return null;
        }

        Destroy(gameObject);
        Destroy(shield);
    }
}