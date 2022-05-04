using System.Collections;
using System.Collections.Generic;
using System;
using UnityEngine;
using System.IO;
using UnityEngine.UI;
using System.Collections.Generic;
using RosSharp.RosBridgeClient;

public class ROS_adata_sender_IMUControl : MonoBehaviour
{
    public ROSArmPublisher rosIn;
    public ROSArmSubscriber rosOut;
    public GameObject startArea;
    //private SerialPort sp;
    [SerializeField]
    string mes = "";
    [SerializeField]
    string mes0 = "";
    [SerializeField]
    string manipData = ""; //data obtained from manipulator
    float[] angle = new float[4]; //angles for sending to the manilulator: shoulder angle, elbow angle, wrist pitch, wrist roll
    public float angle_gr;//angle of gripper (closing/opening)
    [SerializeField]
    bool ready = false;
    [SerializeField]
    string manipulator_pose = "";
    string data;
    float currentTime = 0;
    float startTime;
    public float distance = 50f;
    //public Text DistanceText;
    [SerializeField]
    bool sendReady = false;
    string filename;
    string filename1;
    string time;
    long realTime;
    //public GameObject hint2;
    Text[] manipAngles = new Text[4];
    Text[] manipReading = new Text[4];
    public float[] dataRead = new float[4];
    GameObject Angles;
    float[] motorLoads = new float[2];

    bool startedRecording, endedRecording;

    List<float> shoulderLoad, elbowLoad, times;
    private void Awake()
    {

        ////manipReading[2] = GameObject.Find("FSR1").GetComponent<Text>();
        ////manipReading[3] = GameObject.Find("FSR2").GetComponent<Text>();
        Angles = GameObject.Find("_Manipulator");
        //manipAngles[0] = GameObject.Find("Shoulder_text").GetComponent<Text>();
        //manipAngles[1] = GameObject.Find("Elbow_text").GetComponent<Text>();
        //manipAngles[2] = GameObject.Find("Pitch_text").GetComponent<Text>();
        //manipAngles[3] = GameObject.Find("Roll_text").GetComponent<Text>();
    }
    // Start is called before the first frame update
    void Start()
    {
        shoulderLoad = new List<float>();
        elbowLoad = new List<float>();
        times = new List<float>();
        rosIn = GameObject.Find("ROSConnector").GetComponent<ROSArmPublisher>();
        rosOut = GameObject.Find("ROSConnector").GetComponent<ROSArmSubscriber>();
        InvokeRepeating("DataSend", 5f, 0.25f);//sending data to manipulator  было Time.fixedDeltaTime*10
                                               //InvokeRepeating("DataRead", 5f, 0.2f);//reading data from manipulator Time.fixedDeltaTime*4
        filename = "/Records/Vive" + System.DateTime.UtcNow.ToLocalTime().ToString("yyyy-MM-dd HH.mm") + ".txt";
        filename1 = "/Records/Teleop " + System.DateTime.UtcNow.ToLocalTime().ToString("yyyy-MM-dd HH.mm") + ".txt";
        //InvokeRepeating("WriteTorques", 5f, 0.25f);


    }


    //void Update()
    void FixedUpdate()
    {

        try
        {

            GetAngles();  //Getting angles from Inverse_kinem script

            if (Input.GetKey("a") || startArea.GetComponent<DataSendInit>().start)// || scrA.sendData) start communication between unity and manipulator
            {
                // hint2.SetActive(false);
                ready = true;
                startTime = Time.realtimeSinceStartup;
                rosIn.send("0 /n");
                //scrA.sendData = false;
                startArea.GetComponent<DataSendInit>().start = false;
                return;
            }

            if (ready)
            {
                sendReady = true;
                //usual case
                mes = "m " + angle[0] + " " + angle[1] + " " + angle[2] + " " + angle[3] + " " + angle_gr;// message for sending to the manipulator
                                                                                                          //manipReading[0].text = times.Count + " " + mes;//angle_gr.ToString();
                                                                                                          //testing only gripper closing
                                                                                                          //mes = "g " + angle_gr;
                                                                                                          //testing only gripper rotation+closing
                                                                                                          //mes = "t " + angle[2] + " " + angle[3] + " " + angle_gr;

                //currentTime += Time.deltaTime;
                currentTime += Time.fixedDeltaTime; // Time.deltaTime in case Update

            }

            //if (Angles.GetComponent<Angles_imu_setup>().stopTeleop)
            //{
            //    sendReady = false;
            //}


        }
        catch (System.Exception)
        {
            // throw;
        }
    }

    void GetAngles()
    {
        Angles_imu_setup_new scrA = Angles.GetComponent<Angles_imu_setup_new>();
        //Getting angles from Inverse_kinem script
        angle[0] = -Mathf.Round(180 - scrA.shoulder_angle);//NEW DRONE
        angle[1] = -Mathf.Round(scrA.elbow_angle) + 5;//NEW DRONE
        angle[2] = Mathf.Round(scrA.wrist_angle - 90);
        angle[3] = -90;
        angle_gr = Mathf.Round(scale(5f, -35f, 150f, 30f, scrA.grip_angle));//NEW DRONE


    }

    void DataRead()
    {

        if (sendReady)
        {
            manipulator_pose = rosOut.receive();
            //read data from manipulator
            if (manipulator_pose != "__Connected__" && manipulator_pose != null && manipulator_pose.Length > 20)
            {
                string[] real_value = manipulator_pose.Split(' ');
                //if(float.Parse(real_value[0])!=0 && float.Parse(real_value[1]) != 0 && float.Parse(real_value[2]) != 0 && float.Parse(real_value[3]) != 0) {

                // manipAngles[0].text = "Shoulder joint: " + float.Parse(real_value[0]).ToString();
                //manipAngles[1].text = "Elbow joint: " + float.Parse(real_value[1]).ToString();
                //manipAngles[2].text = "Pitch: " + float.Parse(real_value[2]).ToString();
                //manipAngles[3].text = "Roll: " + float.Parse(real_value[3]).ToString();
                // }



                // distance = float.Parse(real_value[9]);//data from ultrasonic sensor
                /*if (float.Parse(real_value[5]) < 1000 && float.Parse(real_value[6]) < 1000)
                {
                    manipData = "Angles: " + float.Parse(real_value[0]) + " " + float.Parse(real_value[1]) + " " + float.Parse(real_value[2]) + " " + float.Parse(real_value[4]) + " " + "M1: " + float.Parse(real_value[5]) + " " + "M2: " + float.Parse(real_value[6]) + " " + "FSRl: " + float.Parse(real_value[7]) + " " + "FSRr: " + float.Parse(real_value[8]);

                }

                if (distance < 100)
                {
                    // DistanceText.text = " " + (distance - 3);
                }
            */

                //manipReading[2].text = "FSR left: " + Mathf.Round(float.Parse(real_value[7]));//printing data from left FSR
                //manipReading[3].text = "FSR right: " + Mathf.Round(float.Parse(real_value[8]));//printing data from right FSR

            }

        }
    }

    void DataSend()
    {
        if (sendReady)
        {

            realTime = System.DateTime.Now.Millisecond + ((System.DateTime.Now.Hour * 60 + System.DateTime.Now.Minute) * 60 + System.DateTime.Now.Second) * 1000;
            //time = System.DateTime.Now.Hour.ToString() + "." + System.DateTime.Now.Minute.ToString() + "."+System.DateTime.Now.Second.ToString() +"."+ System.DateTime.Now.Millisecond.ToString(); 
            //WriteText();

            if (mes != mes0)
            {
                rosIn.send(mes); //sending angles to the manipulator
                                                          //DataRead();
                mes0 = mes;
            }

        }

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

        //File.AppendAllText(path, currentTime * 1000 + " " + mes + " real: " + manipulator_pose + "\n");
        File.AppendAllText(path, realTime + " " + mes + " real: " + manipulator_pose + "\n");

    }

    void WriteAngles() //writes new positions from unity
    {
        //Path of the file
        string path = Application.dataPath + "/angles.txt";
        //Create file if it doesn't exist
        if (!File.Exists(path))
        {
            File.WriteAllText(path, "Unity data \n");

        }
        //Write to file
        File.AppendAllText(path, currentTime * 1000 + " " + mes + " real: " + manipulator_pose + "\n");
    }





    public float scale(float OldMin, float OldMax, float NewMin, float NewMax, float OldValue)
    {
        float OldRange = (OldMax - OldMin);
        float NewRange = (NewMax - NewMin);
        float NewValue = (((OldValue - OldMin) * NewRange) / OldRange) + NewMin;
        return (NewValue);
    }
}
