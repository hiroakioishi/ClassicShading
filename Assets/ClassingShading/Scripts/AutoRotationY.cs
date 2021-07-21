using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AutoRotationY : MonoBehaviour
{

    public bool Enable = true;

    public float RotateSpeed = 1.0f;

    public float DefaultRotateY = 180.0f;

    void Start()
    {
        
    }

    void Update()
    {
        if (Enable)
        {
            transform.Rotate(Vector3.up, RotateSpeed * Time.deltaTime);
        }
        else
        {
            transform.localRotation = Quaternion.Euler(0.0f, DefaultRotateY, 0.0f);
        }
    }
}
