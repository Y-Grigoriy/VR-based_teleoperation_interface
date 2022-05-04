using UnityEngine;
using UnityEngine.UI;
using System;
using HTC.UnityPlugin.Vive;
using HTC.UnityPlugin.Utility;

public class Inv_kin_new: MonoBehaviour
{
    // public GameObject hint1;
    // public GameObject hint0;
    //public GameObject hint2;
    [Header("Manipulator parameters")]
    float l1 = 0.277f; //length of the first link
    float l2 = 0.2592f; //length of the second link
    Vector2 endEffPos;//end effector position
    public float shoulder_angle; //angle from flex on the tracker on the shoulder
    public float elbow_angle; //angle from flex on the elbow
    public float wrist_pitch;
    float wrist_pitch_paral;
    public float wrist_roll = 0; //angle of rotation of the gripper
    float delta = 0; // angle for rotation the wrist from the controller
    public float grip_angle; //angle of the gripper (opened/closed)
    Transform[] Manip_joints = new Transform[4];//joints for manipulator controll
    Transform[] Grip_points = new Transform[6];//joints for gripper controll
    [Header("Vive controller")]
    [SerializeField]
    Vector2 trackedPos;
    [SerializeField]
    Vector2 initPos;//initial position got from calibration
    [SerializeField]
    Vector2 touchPadVal;//TouchPad value
    [SerializeField] Transform leftPos;
    [SerializeField]
    float val_trigger;
    public float x_start = 0, z_start = 0;
    public float rot_velocity = 5f;
    public Vector3 anglesD; //angles of Point_d
    public Vector3 anglesGrip; //angles of Gripper_rot
    [Header("Flags")]
   
    public bool ready = false;
    int counter = 0;
    public bool stopTeleop = true;
    

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
        //Gripper rotation angles
        anglesD = GameObject.Find("Point_D").transform.localEulerAngles;
        anglesGrip = GameObject.Find("Gripper_rot").transform.localEulerAngles;
    }

    
    void Update()
    {
        RigidPose pose1 = VivePose.GetPoseEx(HandRole.LeftHand); //getting the position (coordinates) of the controller
        //hint0.SetActive(false);
        //Invoke("InvokeHint1", 4f);
        leftPos.localPosition = pose1.pos;
        //trackedPos = new Vector2(leftPos.localPosition.x, leftPos.localPosition.y);
        trackedPos = new Vector2(pose1.pos.x, pose1.pos.y);//зависит от ориентации оператора
       
        //trackedPos = new Vector2(pose1.pos.x, pose1.pos.y);//зависит от ориентации оператора

        //calibration for the initial (zero) position
        if (Input.GetKey("s") || ViveInput.GetPressDownEx(HandRole.LeftHand, ControllerButton.Menu))
        {
            leftPos.localPosition = pose1.pos;
            initPos = new Vector2(leftPos.localPosition.x, leftPos.localPosition.y);
            initPos = new Vector2(pose1.pos.x, pose1.pos.y);
            // hint1.SetActive(false);
            //Invoke("InvokeHint2", 4f);
            ready = true;
        }

        if (ready) //start after calibration passed
        {
            endEffPos = new Vector2(trackedPos.x - initPos.x, trackedPos.y - initPos.y);

            Inverse_k(endEffPos.x, endEffPos.y, l1, l2);//angles calculation

            //if (ViveInput.GetPressDownEx(HandRole.RightHand, ControllerButton.Pad))
            if (ViveInput.GetPressDownEx(HandRole.LeftHand, ControllerButton.PadTouch))//gripper rotation
            {
                touchPadVal.x = ViveInput.GetAxisEx(HandRole.LeftHand, ControllerAxis.PadX);
                touchPadVal.y = ViveInput.GetAxisEx(HandRole.LeftHand, ControllerAxis.PadY);
                if ((touchPadVal.x >= 0.65 || touchPadVal.x <= -0.65) && touchPadVal.y <= 0.6 && touchPadVal.y >= -0.6)
                {
                    wrist_roll += touchPadVal.x * 10;
                }

                if ((touchPadVal.y >= 0.65 || touchPadVal.y <= -0.65) && touchPadVal.x <= 0.6 && touchPadVal.x >= -0.6)
                {
                    delta += touchPadVal.y * 10;
                }
            }

            if (ViveInput.GetPressDownEx(HandRole.LeftHand, ControllerButton.Pad))
            {
                delta = 0;
                wrist_roll = 0;
            }

            wrist_pitch = wrist_pitch_paral - delta;
            SetAnglesLimits();//set limitation on joint angles


            //Gripper closing/opening
            val_trigger = ViveInput.GetAxisEx(HandRole.LeftHand, ControllerAxis.Trigger);
            if (val_trigger > 0.5f)
            {
                ViveInput.TriggerHapticPulse(HandRole.LeftHand, 2000); //add vibrotactile feedback
            }

            grip_angle = scale(1f, 0f, 5f, -45f, val_trigger);

            if (ViveInput.GetPressDownEx(HandRole.LeftHand, ControllerButton.Grip))
            {
                stopTeleop = !stopTeleop;
            }

            ///////////Прекращения отправки данных с Юнити на манипулятор////////////////////////////////
            if (val_trigger > 0.8)
            {
                if (ViveInput.GetPressDownEx(HandRole.LeftHand, ControllerButton.Grip))
                {
                    stopTeleop = true;
                }
            }
            /////////////////////////////////////////////////////////////////////////////////////////////////

            //Visualisation of manipulator movement
           // if (!stopTeleop)
            //{
                MovementVisualisation();
            //}
           

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
        wrist_pitch_paral = 180 - shoulder_angle - elbow_angle;

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

        if (wrist_pitch > 88)
        {
            wrist_pitch = 88;
        }
        if (wrist_pitch < -88)
        {
            wrist_pitch = -88;
        }
        if (grip_angle < -35)  //transforming the trigger input into the angle of gripper components in 3d model
        {
            grip_angle = -35;
        }
        if (grip_angle > 5)
        {
            grip_angle = 5;

        }
        if (wrist_roll > 90)  //transforming the trigger input into the angle of gripper components in 3d model
        {
            wrist_roll = 90;
        }
        if (wrist_roll < -90)
        {
            wrist_roll = -90;
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
        Manip_joints[2].localRotation = Quaternion.Euler(-wrist_pitch, 0f, 0f);//wrist joint - pitch angle
        Manip_joints[3].localRotation = Quaternion.Euler(-wrist_roll, 0, 0);//roll angle

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
