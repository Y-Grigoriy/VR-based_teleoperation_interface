using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Angles_imu_setup : MonoBehaviour
{
    public int imu1; //angle from imu on the shoulder
    public int imu2;
    public int imu3;
    public int shoulder_angle;
    public float elbow_angle;
    public float wrist_angle;
    public float grip_angle;
    public float angle_test;
    public float roll;
    public float prev_x = 0;
    public float x = 0; //промежуточная переменная
    public int start_x = 900;
    public int finish_x = 600;
    public float alfa = 0.2f;
    public SerialController serialController;
   public GameObject start_area;
   // public GameObject hint0;
   // public GameObject hint2;
    public GameObject drone;
    public bool vibro = false;
    Transform[] Grip_points = new Transform[6];

    // bool novibro=false;
    //public GameObject user;

    string mes;
    // Start is called before the first frame update

    private void Awake()
    {
        Grip_points[0] = GameObject.Find("Part1R").transform;
        Grip_points[1] = GameObject.Find("Part2R").transform;
        Grip_points[2] = GameObject.Find("Part3R").transform;
        Grip_points[3] = GameObject.Find("Part1L").transform;
        Grip_points[4] = GameObject.Find("Part2L").transform;
        Grip_points[5] = GameObject.Find("Part3L").transform;
    }
    void Start()
    {
        serialController = GameObject.Find("SerialController").GetComponent<SerialController>();

        mes = serialController.ReadSerialMessage();
        print(mes);
        if (mes == null)
            return;
        string[] flex_value = mes.Split(',');
        imu1 = int.Parse(flex_value[0]);
        imu2 = int.Parse(flex_value[1]);
        imu3 = int.Parse(flex_value[2]);
        start_x = int.Parse(flex_value[3]);
       // roll= int.Parse(flex_value[4]);
        // InvokeRepeating("DataRead", 3f, Time.fixedDeltaTime * 4);

    }

    // Update is called once per frame
    //void Update()
    void FixedUpdate()
    {
        //serialController.SendSerialMessage("s /n");
        mes = serialController.ReadSerialMessage();//считывание строчки с ардуино
            if (mes == null)
                return;
            string[] flex_value = mes.Split(',');//разделение строки на значения
            imu1 = int.Parse(flex_value[0]);
            imu2 = int.Parse(flex_value[1]);
            imu3 = int.Parse(flex_value[2]);
           // roll = int.Parse(flex_value[4]);
        if (Input.GetKey("s")) //straight state
            {

                start_x = int.Parse(flex_value[3]);
            }
            if (Input.GetKey("b")) //bent state
            {

                finish_x = int.Parse(flex_value[3]);
                // Invoke("InvokeHint2", 10f);
               // start_area.SetActive(true);
            }
            if (Input.GetKey("t")) //teleoperation mode
            {
               start_area.SetActive(true);
               // Invoke("InvokeHint2", 0.5f);

            }
            x = float.Parse(flex_value[3]) * alfa + prev_x * (1 - alfa);
            prev_x = x;


            shoulder_angle = -180 + imu1;//значение угла для плеча


            //elbow_angle = 180- Mathf.Abs(imu1) + Mathf.Abs(imu2)+6.4473f;
            elbow_angle = imu2 - imu1 + 180 + 6.4473f;

            wrist_angle = imu3 -imu2+10;
        //wrist_angle_paral = 180 - shoulder_angle - elbow_angle;
        //wrist_angle = -imu3 - imu2 - 180;
        grip_angle = scale(finish_x, start_x, -2f, 35f, x);//преобразование значения flex в угол для гриппера
            SetAnglesLimits();

            Visualisation();
           /* if ((drone.GetComponent<Sending_angles_imu>().distance - 3) <= 3 && (vibro == false))
            {
                serialController.SendSerialMessage("v /n");
                vibro = true;
                // novibro = false;
            }
            if ((drone.GetComponent<Sending_angles_imu>().distance - 3) > 3 && (vibro == true))
            {
                serialController.SendSerialMessage("s /n");
                vibro = false;
                //novibro = true;
            }*/
        
    }

    void SetAnglesLimits()
    {
        if (shoulder_angle >= -5)
        {
            shoulder_angle = -5;
        }
        if (shoulder_angle <= -180)
        {
            shoulder_angle = -180;
        }

        if (elbow_angle >= 175)
        {
            elbow_angle = 175;
        }
        if (elbow_angle < 5)
        {
            elbow_angle = 5;
        }
        /*if (wrist_angle < -120)
        {
            wrist_angle = -120;
        }
        if (wrist_angle > 30)
        {
            wrist_angle = 30;
        }*/
       /* if (roll > 90)  //transforming the trigger input into the angle of gripper components in 3d model
        {
            roll = 90;
        }
        if (roll < -90)
        {
            roll  = -90;

        }*/
        if (grip_angle > 35)
        {
            grip_angle = 35;
        }
        if (grip_angle < -2)
        {
            grip_angle = -2;
        }

    }
        

void Visualisation()
    {
        //shoulder joint rotation
        GameObject.Find("Point_A").transform.localRotation = Quaternion.Euler(0f, 0f, 180-shoulder_angle);
        //elbow joint rotation
        GameObject.Find("Point_C").transform.localRotation = Quaternion.Euler(0f, 0, elbow_angle);
        //gripper joint rotation
        GameObject.Find("Point_D").transform.localRotation = Quaternion.Euler( wrist_angle,0, 0f);
        // GameObject.Find("Gripper_rot").transform.localRotation = Quaternion.Euler(-roll, 0, 0);
        //visualisation of gripper moving
        //GameObject.Find("Point_right").transform.localRotation = Quaternion.Euler(0f, 0f, grip_angle);
        //GameObject.Find("Point_right_1").transform.localRotation = Quaternion.Euler(0f, 0f, grip_angle);
        //GameObject.Find("Point_right_2").transform.localRotation = Quaternion.Euler(0f, 0f, -grip_angle);
        //GameObject.Find("Point_left").transform.localRotation = Quaternion.Euler(0f, 0f, -grip_angle);
        //GameObject.Find("Point_left_1").transform.localRotation = Quaternion.Euler(0f, 0f, -grip_angle);
        //GameObject.Find("Point_left_2").transform.localRotation = Quaternion.Euler(0f, 0f, grip_angle);

        //transform the angles of the gripper
        Grip_points[0].localRotation = Quaternion.Euler(0f, grip_angle, 0f);
        Grip_points[1].localRotation = Quaternion.Euler(0f, grip_angle, 0f);
        Grip_points[2].localRotation = Quaternion.Euler(0f, -grip_angle, 0f);
        Grip_points[3].localRotation = Quaternion.Euler(0f, -grip_angle, 0f);
        Grip_points[4].localRotation = Quaternion.Euler(0f, -grip_angle, 0f);
        Grip_points[5].localRotation = Quaternion.Euler(0f, grip_angle, 0f);

    }




public float scale(float OldMin, float OldMax, float NewMin, float NewMax, float OldValue)
{

float OldRange = (OldMax - OldMin);
float NewRange = (NewMax - NewMin);
float NewValue = (((OldValue - OldMin) * NewRange) / OldRange) + NewMin;

return (NewValue);
}

void DataRead()
{
        //serialController.SendSerialMessage("s /n");
        mes = serialController.ReadSerialMessage();//считывание строчки с ардуино
        if (mes == null)
            return;
        string[] flex_value = mes.Split(',');//разделение строки на значения
        imu1 = int.Parse(flex_value[0]);
        imu2 = int.Parse(flex_value[1]);
        imu3 = int.Parse(flex_value[2]);
        if (Input.GetKey("s")) //straight state
        {

            start_x = int.Parse(flex_value[3]);
        }
        if (Input.GetKey("b")) //bent state
        {

            finish_x = int.Parse(flex_value[3]);
            // Invoke("InvokeHint2", 10f);
            // start_area.SetActive(true);
        }
       /* if (Input.GetKey("t")) //teleoperation mode
        {
            start_area.SetActive(true);
            Invoke("InvokeHint2", 0.5f);

        }*/
        x = float.Parse(flex_value[3]) * alfa + prev_x * (1 - alfa);
        prev_x = x;
        
        shoulder_angle = -180 + imu1;//значение угла для плеча
        elbow_angle = imu2 - imu1 + 180 + 6.4473f;
        wrist_angle = imu3 - imu2 + 90 ;
        grip_angle = scale(finish_x, start_x, 2f, 32f, x);
        SetAnglesLimits();

        Visualisation();

    }
    /*void InvokeHint2()
{
        hint2.SetActive(true);
}*/

}
