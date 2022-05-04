using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Propeller_rotation : MonoBehaviour
{
    public float rot_speed;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        GameObject.Find("P1").transform.Rotate(Vector3.forward * rot_speed * Time.deltaTime, Space.Self);
        GameObject.Find("P2").transform.Rotate(Vector3.forward * rot_speed * Time.deltaTime , Space.Self);
        GameObject.Find("P3").transform.Rotate(Vector3.forward * rot_speed * Time.deltaTime, Space.Self);
        GameObject.Find("P4").transform.Rotate(Vector3.forward * rot_speed * Time.deltaTime, Space.Self);
    }
}
