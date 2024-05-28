using UnityEngine;

public class CameraFollow : MonoBehaviour
{
    public Transform player;
    public Vector3 offset;

    void Start()
    {
        if (offset == Vector3.zero)
        {
            offset = transform.position - player.position;
        }
    }

    void LateUpdate()
    {
        transform.position = player.position + offset;
    }
}