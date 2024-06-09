using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MagicBall : MonoBehaviour
{
    public GameObject parent;
    public GameObject trail;
    private Rigidbody rb;
    // Start is called before the first frame update
    void Start()
    {
        rb = GetComponent<Rigidbody>();
    }

    public void ReleaseMe()
    {
        transform.SetParent(null);

        rb.useGravity = true;
        transform.rotation = parent.transform.rotation;
        
        trail.SetActive(true);
        rb.AddForce(transform.forward * 20000);
    }

    /// <summary>
    /// OnCollisionExit is called when this collider/rigidbody has
    /// stopped touching another rigidbody/collider.
    /// </summary>
    /// <param name="other">The Collision data associated with this collision.</param>
    private void OnCollisionExit(Collision other)
    {
        trail.SetActive(false);
    }
}
