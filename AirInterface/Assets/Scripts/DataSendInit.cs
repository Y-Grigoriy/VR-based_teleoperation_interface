using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DataSendInit : MonoBehaviour
{
    public bool start=false;
    public GameObject start_schere;
    // Start is called before the first frame update
    void Start()
    {
        
    }
    private void OnCollisionEnter(Collision collision)
    {
        if (collision.gameObject.CompareTag("gripper"))
        {
            start = true;

            start_schere.SetActive(false);
        }

    }
    private void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.CompareTag("gripper"))
        {
            start = true;
            start_schere.SetActive(false);
        }
    }
    // Update is called once per frame
    void Update()
    {
        

    }
}
