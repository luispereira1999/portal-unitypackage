using UnityEngine;

public class ObjectThrower : MonoBehaviour
{
    public GameObject objectToThrow; // Assign the already instantiated object in the Inspector
    public Transform throwPoint; // The point from where the object will be thrown
    public float throwForce = 10f; // Adjust the force of the throw
    public Rigidbody rb;

    void Start()
    {
        // Get the Rigidbody component attached to the same GameObject
        rb = GetComponent<Rigidbody>();
    }

    // This method will be called by the animation event to throw the object
    public void ThrowObject()
    {
        MagicBall magicBall = objectToThrow.GetComponent<MagicBall>();

        magicBall.ReleaseMe();
    }

}
