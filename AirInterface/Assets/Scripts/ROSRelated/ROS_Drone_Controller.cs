using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.IO;
using HTC.UnityPlugin.Vive;
using HTC.UnityPlugin.Utility;
using RosSharp.RosBridgeClient;
using UnityEngine.UI;
using System.Linq;

/*  
 *           Unity  ROS  Vicon
 * Forward     Z     Y     X
 * Right       X     X    -Y
 * Up          Y     Z     Z
 *
 * 
*/

public class ROS_Drone_Controller : MonoBehaviour
{
    // Allowable robot flight area
    [SerializeField] private float xLimit = 1.0f;
    public float XLimit
    {
        get { return xLimit; }
        set
        {
            if (value > 0.1f && value < 2.0f)
                xLimit = value;
        }
    }
    [SerializeField] private float yLimit = 2.0f;
    public float YLimit
    {
        get { return yLimit; }
        set
        {
            if (value > 1.0f && value <= 3.0f)
                yLimit = value;
        }
    }
    [SerializeField] private float zLimit = 1.0f;
    public float ZLimit
    {
        get { return zLimit; }
        set
        {
            if (value > 0.1f && value < 2.0f)
                zLimit = value;
        }
    }
    //[SerializeField] private float velocity = 0.1f;
    List<string> columnNames = new List<string> { "Set_pos_x", "Set_pos_y", "Set_pos_z", "Drone_pos_x", "Drone_pos_y", "Drone_pos_z",
                                                "Com_shoulder", "Com_elbow", "Com_wrist_p", "Com_wrist_r", "Com_gripper",
                                                "Manip_shoulder", "Manip_elbow", "Manip_wrist_p", "Manip_wrist_r", "Manip_gripper"};

    [Header("Vive controller")]
    [SerializeField]
    Vector3 trackedPos;//Vive controller position
    [SerializeField]
    Vector3 startPos;//initial position got from calibration
    [SerializeField]
    Vector3 deltaPos;
    [SerializeField]
    Vector2 trackPadVal;//Trackpad value
    float val_trigger;
    public float trackerDeadzone = 5.0f;//in cm
    float z_max = 0.0f;//value for the hand outstretched to the right
    [SerializeField] GameObject trackerZone;
    [SerializeField] Material[] zoneMaterial=new Material[2];
    [Header("Operator")]
    [SerializeField] float armLength = 50.0f;//in cm
    [SerializeField] Text[] droneVelocity = new Text[3];
    [Header("Drone")]
   
    [SerializeField] float yawAngle;
    [SerializeField] Vector3 velocity;
    [SerializeField] float velCoef = 0.07f;
    //public Vector3 Velocity
    //{
    //    get { return velocity; }
    //    set
    //    {
    //        if (value.x > 0.1f && value.x < 2.5f)
    //            velocity.x = value.x;
    //        if (value.y > 0.1f && value.y < 2.5f)
    //            velocity.y = value.y;
    //        if (value.z > 0.1f && value.z < 2.5f)
    //            velocity.z = value.z;
    //    }
    //}
    float roll;
    float pitch;
    private Vector3 curPosition;
    public GameObject drone;
    public GameObject setPoint;
    bool isCalibration = false;
    [Header("Robot statuses")]
    public bool moveReady = false;
    [SerializeField] bool freezeMovement = false;
    [SerializeField] private string goalStatus = "Initialized";
    [SerializeField] private string robotStatus = "Initialized";
    [SerializeField] private string previousStatus = "Initialized";
    public ROSControlServiceProvider ROSStates;
    public RosConnector ros;
    private static Dictionary<string,sbyte> robotModes = new Dictionary<string, sbyte>()
        {
            { "LAND", 0 },
            { "TAKEOFF", 1 },
            { "HOVER", 2 },
            { "POSCTL", 3 }
        };

    // logging variables
    string filename;
    long realTime;
    public string mes = "";
    bool isWrite = false;

    private void droneSM() // State machine to change robot mode
    {
        if (previousStatus == "Initialized")
        {
            RigidPose pose1 = VivePose.GetPoseEx(HandRole.RightHand);
            startPos = pose1.pos;
            
            //armLength = Mathf.Abs(z_max - z_start);
        }
        if (goalStatus != "HOVER" && goalStatus != "POSCTL")
        {

            setPoint.transform.position = drone.transform.position;
            setPoint.transform.rotation = drone.transform.rotation;
        }
        if (goalStatus == "POSCTL") isWrite = true;

            if (goalStatus != "Initialized")
        {
            ROSStates.setMode(robotModes[goalStatus]);
            previousStatus = robotStatus;
            robotStatus = ROSStates.getModeName();
        }

        if (isCalibration)
        {
            RigidPose pose1 = VivePose.GetPoseEx(HandRole.RightHand);
            trackerZone.transform.localPosition = pose1.pos;
            trackerZone.GetComponent<MeshRenderer>().material = zoneMaterial[1];
            trackerZone.SetActive(true);
            isCalibration = false;
        }
    }

    void Start()
    {
        filename = "/Vive records/Vive_flight_controll " + System.DateTime.UtcNow.ToLocalTime().ToString("yyyy-MM-dd HH.mm") + ".csv";
        InvokeRepeating("droneSM", 2.0f, 0.1f);
       // InvokeRepeating("WriteText", 5.0f, 0.1f);
        InvokeRepeating("WriteDatasAsCSV", 5.0f, 0.1f);
        setPoint.transform.position = transform.position;
        setPoint.transform.rotation = transform.rotation;
    }

    void Update()
    {
        //ROSStates.get_state();

        //RigidPose pose1 = VivePose.GetPoseEx(HandRole.LeftHand); //receiving the position (coordinates) of the controller
        RigidPose pose1 = VivePose.GetPoseEx(HandRole.RightHand);
        trackedPos = pose1.pos;
        // Here is necessary to receive robot coordinates from ROS

        if (Input.GetKey("a") || ViveInput.GetPressDownEx(HandRole.RightHand, ControllerButton.Grip))
        {
            z_max = pose1.pos.z;
        }

        if (Input.GetKey("s") || ViveInput.GetPressDownEx(HandRole.RightHand, ControllerButton.Menu) && ros.rosStatus==true)
        {
            goalStatus = robotStatus == "Initialized" ? "TAKEOFF" : "LAND";
            isCalibration=!isCalibration;
            //Debug.Log(robotStatus);
        }

        //Debug.Log(robotStatus+ ", ROS status: "+ ros.rosStatus);
        if (ROSStates.State == 2 && ros.rosStatus == true)
        {
            freezeMovement = !ViveInput.GetPress(HandRole.RightHand, ControllerButton.Trigger);
            //Debug.Log(freezeMovement);
            // Here is necessary to send command to ROS?
            if (freezeMovement == false)
            {
                if (robotStatus != "POSCTL")
                {
                    goalStatus = "POSCTL";
                }
                curPosition = setPoint.transform.position;
                deltaPos = new Vector3((float)System.Math.Round(trackedPos.x - startPos.x, 2), (float)System.Math.Round(trackedPos.y - startPos.y, 2), (float)System.Math.Round(trackedPos.z - startPos.z, 2)) * 100.0f;
                
                if (Mathf.Abs(deltaPos.y) > trackerDeadzone)
                {
                    velocity.y = logScale(deltaPos.y);
                    
                   
                    //curPosition += Mathf.Sign(deltaPos.y) * setPoint.transform.up * velocity.y * Time.deltaTime;
                    //velocity.y = deltaPos.y;
                    curPosition += setPoint.transform.up * velCoef* velocity.y * Time.deltaTime;
                }
                else
                {
                    velocity.y = 0;
                }
                setPoint.transform.position = (curPosition.y < yLimit && curPosition.y > 0.1f) ? curPosition : drone.transform.position;

                if (Mathf.Abs(deltaPos.x) > trackerDeadzone)
                {
                    velocity.x = logScale(deltaPos.x);
                   
                    //curPosition += Mathf.Sign(deltaPos.x) * setPoint.transform.right * velocity.x * Time.deltaTime;
                    //velocity.x = deltaPos.x;
                    curPosition += setPoint.transform.forward * velCoef * velocity.x * Time.deltaTime;
                }
                else
                {
                    velocity.x = 0;
                }
                setPoint.transform.position = (curPosition.x < xLimit && curPosition.x > -xLimit) ? curPosition : drone.transform.position;

                if (Mathf.Abs(deltaPos.z) > trackerDeadzone)
                {
                    velocity.z = logScale(deltaPos.z);
                   
                    //curPosition += Mathf.Sign(deltaPos.z) * setPoint.transform.forward * velocity.z * Time.deltaTime;
                    //velocity.z = deltaPos.z;
                    curPosition -= setPoint.transform.right * velCoef * velocity.z * Time.deltaTime;
                }
                else
                {
                    velocity.z = 0;
                }

                setPoint.transform.position = (curPosition.z < zLimit && curPosition.z > -zLimit) ? curPosition : drone.transform.position;

                if (ViveInput.GetPressDownEx(HandRole.RightHand, ControllerButton.Pad))
                {
                    trackPadVal.x = ViveInput.GetAxisEx(HandRole.RightHand, ControllerAxis.PadX);
                    trackPadVal.y = ViveInput.GetAxisEx(HandRole.RightHand, ControllerAxis.PadY);

                    if ((trackPadVal.x >= 0.65f || trackPadVal.x <= -0.65f) && trackPadVal.y <= 0.85f && trackPadVal.y >= -0.85f)
                    {
                        yawAngle += trackPadVal.x * 1.5f;
                    }
                }
            }
            else
            {
                if (robotStatus != "HOVER")
                {
                    goalStatus = "HOVER";
                }
            }

            drone.transform.localRotation = Quaternion.Euler(pitch, yawAngle-90.0f, roll);
            //transform.rotation = Quaternion.Euler(pitch, yaw, roll);
            realTime = System.DateTime.Now.Millisecond + ((System.DateTime.Now.Hour * 60 + System.DateTime.Now.Minute) * 60 + System.DateTime.Now.Second) * 1000;
            //mes = setPoint.transform.position.x.ToString("f3") + "," + setPoint.transform.position.y.ToString("f3") + ","+setPoint.transform.position.z.ToString("f3") + ","+
            //      drone.transform.position.x.ToString("f3")+","+ drone.transform.position.y.ToString("f3") + drone.transform.position.z.ToString("f3")+"\n";
            droneVelocity[0].text = "Velocity x: " + (velocity.x).ToString();
            droneVelocity[1].text = "Velocity y: " + (velocity.y).ToString();
            droneVelocity[2].text = "Velocity z: " + (velocity.z).ToString();
            if (velocity.magnitude != 0)
            {
                trackerZone.GetComponent<MeshRenderer>().material = zoneMaterial[0];
            }
            else { trackerZone.GetComponent<MeshRenderer>().material = zoneMaterial[1]; }
            // WriteText();
        }
        //Debug.Log(Time.deltaTime);
    }

    public float scale(float OldMin, float OldMax, float NewMin, float NewMax, float OldValue)
    {

        float OldRange = (OldMax - OldMin);
        float NewRange = (NewMax - NewMin);
        float NewValue = (((OldValue - OldMin) * NewRange) / OldRange) + NewMin;

        return (NewValue);
    }

    public float logScale(float OldValue)
    {

        float NewValue;
        if (OldValue != 0.0f)
        {
            NewValue = Mathf.Sign(OldValue) * Mathf.Log10(Mathf.Abs(OldValue));
    }
        else
        {
            NewValue = 0.0f;
        }

        // Debug.Log(NewValue);            

        return (NewValue);
    }

    void WriteText() //writes all commands from unity
    {
        //Path of the file
        string path = Application.dataPath + filename;
        //Create file if it doesn't exist
        if (!File.Exists(path))
        {
            File.WriteAllText(path, "Unity data \n");

        }
        //Write to file

        File.AppendAllText(path, realTime + " " + mes + "\n");//composing the data string for the recording

    }
    void WriteDatasAsCSV()
    {
        //Path of the file
        string path = Application.dataPath + filename;
        //Create file if it doesn't exist
        if (!File.Exists(path))
        {
            string firstLine = string.Join(",", columnNames);
            File.WriteAllText(path, firstLine + "\n");
        }
        if (isWrite)
        {
            mes = setPoint.transform.position.x.ToString("f3") + " " + setPoint.transform.position.y.ToString("f3") + " " + setPoint.transform.position.z.ToString("f3") + " " +
                  drone.transform.position.x.ToString("f3") + " " + drone.transform.position.y.ToString("f3") + " " + drone.transform.position.z.ToString("f3") + " "
                  + drone.GetComponent<ROS_adata_sender_VIVEControl>().mesToRecord; //+ " " + drone.GetComponent<ROS_adata_sender_VIVEControl>().manipulator_pose;
            File.AppendAllText(path, realTime + " " + mes + "\n");
        }
        
        
    }

    static string findKeyByValue(Dictionary<string, sbyte> dict, sbyte val)
    {
        foreach(string key in dict.Keys)
        {
            if(dict[key] == val)
            {
                return key;
            }
        }
        return "LAND";
    }
}
