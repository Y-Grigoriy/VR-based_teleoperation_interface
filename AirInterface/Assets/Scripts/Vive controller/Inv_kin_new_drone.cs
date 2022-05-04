using UnityEngine;
using UnityEngine.UI;
using System;
using HTC.UnityPlugin.Vive;
using HTC.UnityPlugin.Utility;

public class Inv_kin_new_drone : MonoBehaviour
{
    public GameObject drone;
    public GameObject start_area;
   // public GameObject hint1;
   // public GameObject hint0;
    //public GameObject hint2;
    public float x, z; //end effector position
    public float shoulder_angle; //angle from flex on the tracker on the shoulder
    public float elbow_angle; //angle from flex on the elbow
    public float wrist_angle;
    public float wrist_angle_paral;
    public float grip_angle;
    float l1 = 0.277f; //length of the first link
    float l2 = 0.2592f; //length of the second link
    public float x_track, z_track; //initial position got from calibration
    public float x_start = 0, z_start = 0;
    public float rot_velocity = 5f;
    float x_axis, y_axis;//TouchPad
    public Vector3 anglesD; //angles of Point_d
    public Vector3 anglesGrip; //angles of Gripper_rot
    public float grip_rotation = 0; //angle of rotation of the gripper
    public float delta = 0; // angle for rotation the wrist from the controller
    float z_angle;
    float val_trigger;
    bool ready = false;
    //public bool sendData=true;
    float currentTime;
    string mes;
    bool isSphere = false;
    //public Text roll1;
    //public Text pitch1;
    public GameObject user;
    float handLength;
    float grip_rotation_delta;
    int counter = 0;
    public bool stopTeleop = false;
    Transform[] Manip_joints = new Transform[4];
    Transform[] Grip_points = new Transform[6];

    private void Awake()
    {
        Manip_joints[0] = GameObject.Find("Point_A").transform;//shoulder joint
        Manip_joints[1] = GameObject.Find("Point_C").transform;//elbow joint
        Manip_joints[2] = GameObject.Find("Point_D").transform;//wrist joint - pitch angle
        Manip_joints[3] = GameObject.Find("Gripper_rot").transform;//roll angle

        //transform the angles of the gripper
        Grip_points[0] = GameObject.Find("Part1R").transform;
        Grip_points[1] = GameObject.Find("Part2R").transform;
        Grip_points[2] = GameObject.Find("Part3R").transform;
        Grip_points[3] = GameObject.Find("Part1L").transform;
        Grip_points[4] = GameObject.Find("Part2L").transform;
        Grip_points[5] = GameObject.Find("Part3L").transform;
    }
    // Start is called before the first frame update
    void Start()
    {
        x = 0.3f;
        z = 0.4f;
        //Gripper rotation angles
        anglesD = GameObject.Find("Point_D").transform.localEulerAngles;
        anglesGrip = GameObject.Find("Gripper_rot").transform.localEulerAngles;
    }

    void FixedUpdate()
    //void Update()
    {

        //Calculation angles of the manipulator

        //RigidPose pose1 = VivePose.GetPoseEx(HandRole.LeftHand); //getting the position (coordinates) of the controller
        //if (user.transform.position.x<=1.7&& user.transform.position.x>=0.5&& user.transform.position.z>=0.1&& user.transform.position.z <= 1.3)
        //{
        RigidPose pose1 = VivePose.GetPoseEx(HandRole.RightHand);
        //hint0.SetActive(false);
        //Invoke("InvokeHint1", 4f);
        x_track = pose1.pos.z;
        //x_track = pose1.pos.x;  //зависит от ориентации оператора
        z_track = pose1.pos.y;

        //calibration for the initial (zero) position
        if (Input.GetKey("s") || ViveInput.GetPressDownEx(HandRole.RightHand, ControllerButton.Menu))
        {
            x_start = pose1.pos.z;
            //x_start = pose1.pos.x;
            handLength = pose1.pos.y;

            // z_start = -handLength;
            z_start = pose1.pos.y;
           // drone.GetComponent<Data_Sending_Vive>().enabled = true;
            // start_area.SetActive(true);
            // hint1.SetActive(false);
            //Invoke("InvokeHint2", 4f);
            ready = true;
        }

        if (ready) //start after calibration passed
        {
            x = x_track - x_start;
            z = z_track - z_start;

            Inverse_k(-x, z, l1, l2);//angles calculation


            //wrist_angle = -elbow_angle - shoulder_angle-30;


            if (ViveInput.GetPressDownEx(HandRole.RightHand, ControllerButton.Grip))
            {
                // sendData = !sendData;
                //sendData = true;
                if (isSphere == false)
                {
                    start_area.SetActive(true);
                    //Invoke("InvokeHint2", 0.5f);
                    isSphere = true;
                    counter++;
                }

            }


            if (ViveInput.GetPressDownEx(HandRole.RightHand, ControllerButton.PadTouch))
            //if (ViveInput.GetPressDownEx(HandRole.LeftHand, ControllerButton.Pad))//gripper rotation
            {

                x_axis = ViveInput.GetAxisEx(HandRole.RightHand, ControllerAxis.PadX);
                y_axis = ViveInput.GetAxisEx(HandRole.RightHand, ControllerAxis.PadY);


                if ((x_axis >= 0.65 || x_axis <= -0.65) && y_axis <= 0.85 && y_axis >= -0.85)
                {
                    // GameObject.Find("Gripper_rot").transform.localRotation = Quaternion.Euler(anglesGrip.x + x_axis * 2, anglesGrip.y, anglesGrip.z);
                    grip_rotation += x_axis * 10;

                }

                if ((y_axis >= 0.65 || y_axis <= -0.65) && x_axis <= 0.85 && x_axis >= -0.85)
                {

                    delta += y_axis * 10;
                    // GameObject.Find("Point_D").transform.localRotation = Quaternion.Euler(anglesD.x, wrist_angle - delta, anglesD.z);
                }
                ////////////////////////
                /*Взято с проекта на HRI
                  x_axis = ViveInput.GetAxisEx(HandRole.LeftHand, ControllerAxis.PadX);
                  y_axis = ViveInput.GetAxisEx(HandRole.LeftHand, ControllerAxis.PadY);
                if ((x_axis >= 0.6 || x_axis <= -0.6) && y_axis <= 0.85 && y_axis >= -0.85)
                {
                 grip_rotation += x_axis * 1f;
                }
                if ((y_axis >= 0.65 || y_axis <= -0.65) && x_axis <= 0.85 && x_axis >= -0.85)
                {
                    
                    delta += y_axis * 10;
                }
                  */
                ////////////////////////

            }

            if (ViveInput.GetPressDownEx(HandRole.RightHand, ControllerButton.Pad))
            {
                //if ((x_axis >= -0.3 || x_axis <= 0.3) && y_axis <= 0.3 && y_axis >= -0.3)
                //{
                delta = 0;
                grip_rotation = 0;
                //}


            }


            //Gripper closing/opening
            val_trigger = ViveInput.GetAxisEx(HandRole.RightHand, ControllerAxis.Trigger);
            if (val_trigger > 0)
            {
                ViveInput.TriggerHapticPulse(HandRole.RightHand, 2000); //add vibrotactile feedback
            }

            grip_angle = scale(1f, 0.2f, 5f, -35f, val_trigger);

            ///////////Прекращения отправки данных с Юнити на манипудятор////////////////////////////////
            if (val_trigger > 0.8)
            {
                if (ViveInput.GetPressDownEx(HandRole.LeftHand, ControllerButton.Grip))
                {
                    stopTeleop = true;
                }
            }
            /////////////////////////////////////////////////////////////////////////////////////////////////


            wrist_angle = wrist_angle_paral - delta;
            SetAnglesLimits();//limitation of joint angles


            //Visualisation of manipulator movement
            MovementVisualisation();


            //roll1.text = "Roll: " + grip_rotation.ToString();
            //pitch1.text = "Pitch: " + wrist_angle.ToString();
        }


    }


    //Inverse kinematic function
    public void Inverse_k(float x, float z, float l1, float l2)
    {

        float c2 = (x * x + z * z - l1 * l1 - l2 * l2) / (2 * l1 * l2);
        float s2;
        if (c2 > 1)
        {
            c2 = 1;
        }
        else if (c2 < -1)
        {
            c2 = -1;
        }
        // if (z >= 0f)
        //{
        s2 = -Mathf.Sqrt(1 - c2 * c2);
        /* }
         else
         {
            s2 = Mathf.Sqrt(1 - c2 * c2);
         }*/


        float k1 = l1 + l2 * c2;
        float k2 = -l2 * s2;

        shoulder_angle = Mathf.Rad2Deg * (-Mathf.Atan2(z, x) + Mathf.Atan2(k2, k1));
        elbow_angle = 180f + Mathf.Rad2Deg * Mathf.Atan2(s2, c2) + 6.4473f;
        wrist_angle_paral = 180 - shoulder_angle - elbow_angle;

    }

    void SetAnglesLimits()
    {
        if (180 - shoulder_angle < 0)
        {
            shoulder_angle = 0;
        }
        if (180 - shoulder_angle >180)
        {
            shoulder_angle = 180;
        }
        if (elbow_angle >= 179)
        {
            elbow_angle = 179;
        }
        if (elbow_angle < 5)
        {
            elbow_angle = 5;
        }

        if (wrist_angle > 88)
        {
            wrist_angle = 88;
        }
        if (wrist_angle < -88)
        {
            wrist_angle = -88;
        }
        if (grip_angle < -35)  //transforming the trigger input into the angle of gripper components in 3d model
        {
            grip_angle = -35;
        }
        if (grip_angle > 5)
        {
            grip_angle = 5;

        }
        if (grip_rotation > 90)  //transforming the trigger input into the angle of gripper components in 3d model
        {
            grip_rotation = 90;
        }
        if (grip_rotation < -90)
        {
            grip_rotation = -90;

        }

    }


    public float scale(float OldMin, float OldMax, float NewMin, float NewMax, float OldValue)
    {

        float OldRange = (OldMax - OldMin);
        float NewRange = (NewMax - NewMin);
        float NewValue = (((OldValue - OldMin) * NewRange) / OldRange) + NewMin;

        return (NewValue);
    }

    void MovementVisualisation()
    {
        Manip_joints[0].localRotation = Quaternion.Euler(0f, 0f, 180-shoulder_angle);//shoulder joint
        Manip_joints[1].localRotation = Quaternion.Euler(0f, 0f, -elbow_angle);//elbow joint
        Manip_joints[2].localRotation = Quaternion.Euler(-wrist_angle, 0f, 0f);//wrist joint - pitch angle
        Manip_joints[3].localRotation = Quaternion.Euler(-grip_rotation, 0, 0);//roll angle

        //transform the angles of the gripper
        Grip_points[0].localRotation = Quaternion.Euler(0f, grip_angle, 0f);
        Grip_points[1].localRotation = Quaternion.Euler(0f, grip_angle, 0f);
        Grip_points[2].localRotation = Quaternion.Euler(0f, -grip_angle, 0f);
        Grip_points[3].localRotation = Quaternion.Euler(0f, -grip_angle, 0f);
        Grip_points[4].localRotation = Quaternion.Euler(0f, -grip_angle, 0f);
        Grip_points[5].localRotation = Quaternion.Euler(0f, grip_angle, 0f);
    }



   /* void InvokeHint1()
    {
        hint1.SetActive(true);
    }*/
   /* void InvokeHint2()
    {
        hint2.SetActive(true);
    }*/
}
