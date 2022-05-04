using System.Collections;
using System.Collections.Generic;
using UnityEngine;

using HTC.UnityPlugin.Vive;
using HTC.UnityPlugin.Utility;

public class Drone_Controller : MonoBehaviour
{
    float x, y, z; //координаты дрона
    float x_axis, y_axis; //значения с тачпада джойстика
    public float x_track, y_track, z_track; //initial position got from calibration
    public float x_start = 0, y_start=0, z_start = 0, delta_y=0;
    public bool moveReady=false;
    float yaw;
    float velocity = 0.1f;
    void Start()
    {

    }

    // Update is called once per frame
    void Update()
    {
        //RigidPose pose1 = VivePose.GetPoseEx(HandRole.LeftHand); //getting the position (coordinates) of the controller
        RigidPose pose1 = VivePose.GetPoseEx(HandRole.RightHand);
        y_track = pose1.pos.y;
        //if (Input.GetKey("s") || ViveInput.GetPressDownEx(HandRole.LeftHand, ControllerButton.Menu))
         if (Input.GetKey("s") || ViveInput.GetPressDownEx(HandRole.RightHand, ControllerButton.Menu))
        {
            y_start = pose1.pos.y;
            moveReady = true;
        }

        x = transform.position.x;
        y = transform.position.y;
        z = transform.position.z;
        if (moveReady) {

            delta_y = y_track - y_start;
            if (delta_y > 0.05)
            {
                transform.position += transform.up * velocity * Time.deltaTime;
            }
            if (delta_y < -0.05)
            {
                transform.position -= transform.up * velocity * Time.deltaTime;
            }
            y = y + delta_y/12;
            // get trigger down
            if (ViveInput.GetPressDownEx(HandRole.RightHand, ControllerButton.Pad))
            //if (ViveInput.GetPressDownEx(HandRole.LeftHand, ControllerButton.PadTouch))
            {
                x_axis = ViveInput.GetAxisEx(HandRole.LeftHand, ControllerAxis.PadX);
               // y_axis = ViveInput.GetAxisEx(HandRole.LeftHand, ControllerAxis.PadY);
                y_axis = ViveInput.GetAxisEx(HandRole.RightHand, ControllerAxis.PadY);
                if (x_axis >= -0.3 && x_axis <= 0.3 && y_axis <= 0.3 && y_axis >= -0.3)
                {
                    transform.position = new Vector3(x, y + 0.1f, z);
                }

                if ((x_axis > 0.85 || x_axis < -0.85) && y_axis <= 0.85 && y_axis >= -0.85)
                {
                    transform.position = new Vector3(x, y, z - x_axis / 20);
                }

                if ((y_axis > 0.85 || y_axis < -0.85) && x_axis <= 0.85 && x_axis >= -0.85)
                {
                    transform.Rotate(Vector3.up * velocity * Time.deltaTime, Space.Self);
                }
            }
            if (ViveInput.GetPressDownEx(HandRole.LeftHand, ControllerButton.Grip))
            {
                if (y >= 0.8f)
                {
                    transform.position = new Vector3(x, y - 0.01f, z);
                }

            }

            if (ViveInput.GetAxisEx(HandRole.LeftHand, ControllerAxis.Trigger) > 0.8f)
            {
                //if (y <= 2.8f)
               // {
                    //transform.position = new Vector3(x, y + 0.005f, z);
                transform.position += transform.right * velocity * Time.deltaTime;
                // }
            }
            if (ViveInput.GetAxisEx(HandRole.LeftHand, ControllerAxis.Trigger) < 0.4f)
            {
                transform.position -= transform.right * velocity * Time.deltaTime;
            }

            // transform.position = new Vector3(x, y, z);
           // transform.localRotation = Quaternion.Euler(270, 0, yaw);
        }
        
    }
}
