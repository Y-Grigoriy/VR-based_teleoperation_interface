using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Drone_flight : MonoBehaviour {

    public float rot_speed;
    public float speed;
    // Use this for initialization
    void Start()
    {

    }

    // Update is called once per frame
    void Update()
    {
        if (Input.GetKey(KeyCode.A))
        {
            Vector3 position = this.transform.position;
            position.x = position.x - speed * Time.deltaTime;
            this.transform.position = position;
            GameObject.Find("Propeller0").transform.Rotate(Vector3.forward * rot_speed * Time.deltaTime, Space.Self);
            GameObject.Find("Propeller1").transform.Rotate(Vector3.forward * rot_speed * Time.deltaTime * (-1), Space.Self);
            GameObject.Find("Propeller2").transform.Rotate(Vector3.forward * rot_speed * Time.deltaTime * (-1), Space.Self);
            GameObject.Find("Propeller3").transform.Rotate(Vector3.forward * rot_speed * Time.deltaTime, Space.Self);
        }
        if (Input.GetKey(KeyCode.D))
        {
            Vector3 position = this.transform.position;
            position.x = position.x + speed * Time.deltaTime;
           this.transform.position = position;
            GameObject.Find("Propeller0").transform.Rotate(Vector3.forward * rot_speed * Time.deltaTime, Space.Self);
            GameObject.Find("Propeller1").transform.Rotate(Vector3.forward * rot_speed * Time.deltaTime * (-1), Space.Self);
            GameObject.Find("Propeller2").transform.Rotate(Vector3.forward * rot_speed * Time.deltaTime * (-1), Space.Self);
            GameObject.Find("Propeller3").transform.Rotate(Vector3.forward * rot_speed * Time.deltaTime, Space.Self);
        }
        if (Input.GetKey(KeyCode.W))
        {
            Vector3 position = this.transform.position;
            position.y = position.y + speed * Time.deltaTime;
            this.transform.position = position;
            GameObject.Find("Propeller0").transform.Rotate(Vector3.forward * rot_speed * Time.deltaTime, Space.Self);
            GameObject.Find("Propeller1").transform.Rotate(Vector3.forward * rot_speed * Time.deltaTime * (-1), Space.Self);
            GameObject.Find("Propeller2").transform.Rotate(Vector3.forward * rot_speed * Time.deltaTime * (-1), Space.Self);
            GameObject.Find("Propeller3").transform.Rotate(Vector3.forward * rot_speed * Time.deltaTime, Space.Self);
        }
        if (Input.GetKey(KeyCode.S))
        {
            Vector3 position = this.transform.position;
            position.y = position.y - speed * Time.deltaTime;
            this.transform.position = position;
            GameObject.Find("Propeller0").transform.Rotate(Vector3.forward * rot_speed * Time.deltaTime, Space.Self);
            GameObject.Find("Propeller1").transform.Rotate(Vector3.forward * rot_speed * Time.deltaTime * (-1), Space.Self);
            GameObject.Find("Propeller2").transform.Rotate(Vector3.forward * rot_speed * Time.deltaTime * (-1), Space.Self);
            GameObject.Find("Propeller3").transform.Rotate(Vector3.forward * rot_speed * Time.deltaTime, Space.Self);
        }
        if (Input.GetKey(KeyCode.Space))
        {
            GameObject.Find("Propeller0").transform.Rotate(Vector3.forward * rot_speed * Time.deltaTime, Space.Self);
           // GameObject.Find("Propeller0").transform.localRotation = Quaternion.Euler(0f, 0f, rot_speed * Time.deltaTime);
            GameObject.Find("Propeller1").transform.Rotate(Vector3.forward * rot_speed * Time.deltaTime * (-1), Space.Self);
            GameObject.Find("Propeller2").transform.Rotate(Vector3.forward * rot_speed * Time.deltaTime * (-1), Space.Self);
            GameObject.Find("Propeller3").transform.Rotate(Vector3.forward  * rot_speed * Time.deltaTime, Space.Self);
        }
    }
}
