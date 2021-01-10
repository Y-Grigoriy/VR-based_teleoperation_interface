/*****************************************************************************************
  Control code for manipulator with 3 DoF + 1 DoF for gripper rotation + gripper control
*****************************************************************************************/

#include <DynamixelWorkbench.h>
#include <math.h>
#include <Servo.h>

#if defined(__OPENCM904__)
#define DEVICE_NAME "1" //Dynamixel on Serial3(USART3)  <-OpenCM 485EXP
#elif defined(__OPENCR__)
#define DEVICE_NAME ""
#endif

#define BAUDRATE  1000000
#define DXL_ID_1  1  // base    1024(958/84) - 3072 (0 - 180)
#define DXL_ID_2  5  // elbow   1024 - 3072 (0 - 180)
#define DXL_ID_3  11 // wrist   205(129/37) - 512(150) - 819 (913/267)(0 - 90 - 180)
#define DXL_ID_4  15 // gripper 205(129/37) - 512(150) - 819 (913/267)(0 - 90 - 180)

DynamixelWorkbench dxl_wb;

uint8_t dxl_id[4] = {DXL_ID_1, DXL_ID_2, DXL_ID_3, DXL_ID_4};
int32_t get_data[4] = {0, 0, 0, 0};
int32_t get_data0[4] = {0, 0, 0, 0};
int32_t get_dataVolt[4] = {0, 0, 0, 0};
int32_t get_dataVel[4] = {0, 0, 0, 0};
float est_torq[4] = {0, 0, 0, 0};
int32_t get_mov[4] = {0, 0, 0, 0};
uint16_t model_number = 0;
const float max_torq[4] = {81.6, 56.1, 16.5, 16.5};
const int resol_AX = 1023;
const int resol_MX = 4095;
const float mx_pos_const = 0.088;// 1 unit is 0.088 degrees (0-4095) 0xFFF

int val = 0;
float parameters[5] = {-180, 0, -90, -90, -25}; // данные углов для моторов
float interparam[5] = {-180, 0, -90, -90, -25}; // данные предыдущего положения
float prevparam[5] = {-180, 0, -90, -90, -25};  // данные предыдущего положения

bool result = false;        // считывание ответа Dynamixelей
boolean dyno_ready = false; // check of dynamixel connection
boolean reads = false;      // sensor reading
boolean tako = false;       // схватывание объекта
boolean dropp = false;      // отпускание объекта
boolean transf = false;     // получение данных
boolean landy = false;      // режим посадки
boolean posit = false;      // рука с объектом
boolean initi = false;      // чтение текущего положения
boolean rtg = false;        // sensor reading
boolean westim = false;     // оценка веса груза
boolean dynovel = false;    // Информация о скоростях моторов
boolean read2 = true;       // чтение данных с манипулятора

Servo myservo;              // create servo object to control a servo

// Forward kinematics
const float pi = 3.14159;
const float l1 = 0.27698;                    // link 1 length
const float ld = 0.0313;                     // distance between end of link 1 and elbow
const float l2 = 0.259037;                   // link 2 length
//const float lgr = 0.09385;                 // distance between wrist and point on the gripper
float theta, beta, alpha, phi, betamin, ksi; // angles in degrees -180<theta,beta<0 -95<alpha<95
//float xelb, zelb, xwr, zwr, xgr, zgr;      // position of elbow, wrist axes and point on the gripper
//float x0 = 0, z0 = 0;                      // initial position of drone
float theta0 = -180, beta0 = 0, alpha0 = -90, phi0 = -90, ksi0 = 25; // initial angles
float Delta[4] = {0, 0, 0, 0};               // разница между прошлым и текущим положением в градусах
float maxDelta = 0;                          // максимальная разница между прошлым и текущим положением в градусах
float angstep = 4;                           // величина минимального угла поворота
float Nas;                                   // количество шагов для перемещения
int dang[4] = {3072, 1024, 512, 512};

const int FSR_PIN = 0;  // Pin connected to FSR
const int FSRb_PIN = 4; // Pin connected to big FSR

// Measure the voltage at 5V and resistance of your 3.3k resistor, and enter
// their value's below:
const float VCC = 4.14;     // 4.98 Measured voltage of Ardunio 5V line
const float R_DIV = 9820.0; // 3230.0 Measured resistance of 3.3k resistor
float force, forceb;

unsigned long int InitTime, NextTime, CurTime;
int ReadTime=5; //34 20 5 мсек, время ожидания для чтения данных

// Ультразвук
#define PIN_TRIG 13
#define PIN_ECHO 12
long duration, cm, cmp=0;

// IMU
#include <Wire.h>
#include <LSM303.h>

LSM303 compass;

char report[80];

// =============================================================================
// ===                               Functions                               ===

void dynoang (float theta, float beta, float alpha, float phi, float ksi); // Angles cheking and transformation
void fsrdat (int FSR_PIN, float force);                                    // Функция считывания показаний датчиков силы
void datprint(int j);                                                      // Функция вывода данных в серийный порт (при перемещении манипулятора)
void curdatprint();                                                        // Функция вывода данных в серийный порт (при отсутствии перемещения манипулятора)

void setup()
{
  InitTime = millis();

  myservo.attach(11);  // attaches the servo on pin 9 to the servo object

  // Подключение датчиков силы
  pinMode(FSR_PIN, INPUT_ANALOG);
  pinMode(FSRb_PIN, INPUT_ANALOG);

  Serial2.begin(115200);
  // while(!Serial); // Wait for Opening Serial

  // Подключение Dynamixelей
  const char *log; // массив записи ответа с динамикселей

  result = dxl_wb.init(DEVICE_NAME, BAUDRATE, &log);
  if (result == false)
  {
    Serial2.println(log);
    Serial2.println("Failed to init");
  }
  else
  {
    Serial2.print("Succeeded to init : ");
    Serial2.println(BAUDRATE);
  }

  for (int cnt = 0; cnt < 4; cnt++)
  {
    result = dxl_wb.ping(dxl_id[cnt], &model_number, &log); // проверка подключения динамикселей
    if (result == false)
    {
      Serial2.println(log);
      Serial2.println("Failed to ping");
    }
    else
    {
      Serial2.println("Succeeded to ping");
      Serial2.print("id : ");
      Serial2.print(dxl_id[cnt]);
      Serial2.print(" model_number : ");
      Serial2.println(model_number);
    }

    result = dxl_wb.jointMode(dxl_id[cnt], 0, 0, &log); // переход в режим удержания позиции
    if (result == false)
    {
      Serial2.println(log);
      Serial2.println("Failed to change joint mode");
      dyno_ready = false;
    }
    else
    {
      dyno_ready = true;
      Serial2.println("Succeed to change joint mode");
      result = dxl_wb.itemRead(dxl_id[cnt], "Present_Position", &get_data[cnt], &log);
      result = dxl_wb.itemRead(dxl_id[cnt], "Present_Load", &get_data0[cnt], &log);
      Serial2.print("Succeed to get present position(value : ");
      Serial2.print(get_data[cnt]);
      Serial2.println(")");
    }
  }
  if (dyno_ready == true) // запись исходного положения
  {
    dxl_wb.goalPosition(dxl_id[0], (int32_t)get_data[0]);
    dxl_wb.goalPosition(dxl_id[1], (int32_t)get_data[1]);
    dxl_wb.goalPosition(dxl_id[2], (int16_t)get_data[2]);
    dxl_wb.goalPosition(dxl_id[3], (int16_t)get_data[3]);
    delay(30);
    theta0 = 90 - (get_data[0] * 360 / resol_MX);
    beta0 = 90 - (get_data[1] * 360 / resol_MX);
    alpha0 = 90 - ((int16_t)get_data[2] * 300 / resol_AX);
    phi0 = 90 - ((int16_t)get_data[3] * 300 / resol_AX);
    delay(400);
  }
  ksi = ksi0;
  myservo.write(ksi); // sets the servo position according to the scaled value

  // Ультразвук
  pinMode(PIN_TRIG, OUTPUT);
  pinMode(PIN_ECHO, INPUT);

  // IMU
  Wire.begin();
  compass.init();
  compass.enableDefault();
  
  NextTime=millis()-InitTime+ReadTime;
}

void loop()
{
  const char *log;

  //Serial2.println("start "+String(millis()-InitTime));

  // Обработка команды, пришедшей в COM-порт
  if (Serial2.available() > 0) {
    //delay(10);
    val = Serial2.read();
    //Serial2.print("I received: ");
    //Serial2.write(val);
    /*if (val == 'r') { // Перезагрузка
      digitalWrite(intPin, LOW);
      delay(200);
      }*/
    if (val == 'v') dynovel = true; // Информация о скоростях моторов
    if (val == 's') reads = true;   // Чтение данных с датчиков
    if (val == 'z') initi = true;   // Чтение данных о текущем положении манипулятора
    if (val == 'w') westim = true;  // Оценка веса груза
    if (val == '0') {
      InitTime = millis(); // Сброс таймера
      NextTime=millis()-InitTime+ReadTime;
    }
    if (val == 't') {
      tako = true; // Управление хватом
      delay(10);
      ksi = Serial2.parseFloat();
      //Serial2.print(ksi);
    }
    if (val == 'd') dropp = true; // разжатие хвата
    if (val == 'p') posit = true; // перемещение объекта под дрон
    if (val == 'b') { // прекращение считывания датчиков
      reads = false;
      initi == false;
      transf = false;
      landy = false;
      westim = false;
      read2 = false;
    }
    if (val == 'l') landy = true; // переход в режим посадки
    if (val == 'm') {
      //transf = true;  // перемещение по входящим данным
      delay(4);
      for (int i = 0; i < 5; i++) {
        prevparam[i] = parameters[i];
        interparam[i] = Serial2.parseFloat();
        //Serial2.print(parameters[i]);
        //Serial2.print(" ");
      }
      if (((interparam[0])!=NULL) && ((interparam[1])!=NULL) && ((interparam[2])!=NULL) && ((interparam[3])!=NULL)) {
        transf = true;  // перемещение по входящим данным
        for (int i = 0; i < 5; i++) parameters[i] = interparam[i];
      }
      /*Serial2.print(String((parameters[0])!=NULL)+" ");
      Serial2.print(String((parameters[1])!=NULL)+" ");
      Serial2.print(String((parameters[2])!=NULL)+" ");
      Serial2.print(String((parameters[3])!=NULL)+" ");*/
      Serial2.println();
      //Serial.flush(); // May be, should be deleted
      //delay(6); // 10
    }
    //delay(4); // 10
  }
  //Serial2.println("check serial "+String(millis()-InitTime));
  
  // Ультразвук
  // Сначала генерируем короткий импульс длительностью 2-5 микросекунд.
  digitalWrite(PIN_TRIG, LOW);
  delayMicroseconds(5);
  digitalWrite(PIN_TRIG, HIGH);

  if (westim == true) { // Оценка массы груза !!! не доделано !!!
    dynoang (-52, -90, -52, -0, 152); // alpha = -52 -68
    dynoang (-132.2141, -90, -132.2141, -0, 152); // alpha = -132.2141 -155
    Serial2.println();
    delay(100);
    westim = false;
  }

  if (reads == true) { // Чтение данных с датчиков силы
    fsrdat (FSR_PIN, force);
    fsrdat (FSRb_PIN, forceb);
    Serial2.println();
    delay(300);
  }

  if (dynovel == true) { // Чтение скорости моторов
    for (int cnt = 0; cnt < 4; cnt++)
    {
      result = dxl_wb.itemRead(dxl_id[cnt], "Moving_Speed", &get_dataVel[cnt], &log);
      Serial2.print(get_dataVel[cnt]);
      Serial2.print(" ");
    }
    Serial2.println();
    delay(10);
    dynovel = false;
  }

  if (initi == true) { // Чтение текущих углов, значений крутящих моментов моторов и текущего времени
    //fsrdat (FSR_PIN, force);
    //fsrdat (FSRb_PIN, forceb);
    curdatprint();
    //Serial.flush(); // May be, should be deleted
    //delay(20);
    initi = false;
  }

  if (tako == true) { // Запись положения звеньев хвата
    reads = false;
    if (ksi < 28 || ksi > 155) ksi = ksi0;
    //ksi = map(ksi, 0, 1023, 0, 90);
    myservo.write(ksi); // sets the servo position according to the scaled value
    delay(50);
    ksi0 = ksi;
    Serial2.print(ksi0);
    tako = false;
  }

  if (dropp == true) { // Разжатие хвата
    reads = false;
    myservo.write(0); // sets the servo position according to the scaled value
    delay(50);
    dropp = false;
  }

  if (transf == true) { // Перемещение манипулятора в заданное положение
    reads = false;
    read2 = false;
    rtg = false;
    dynoang (parameters[0], parameters[1], parameters[2], parameters[3], parameters[4]);
    delay(4); // 8
    //Serial.println(Nas);
    /*for (int i = 0; i < 3; i++) {
      Serial2.print(Delta[i]);
      Serial2.print(" ");
      }
      Serial2.println();*/
    transf = false;
    read2 = true;
  }
  
  if (posit == true) { // Перемещение объекта под дрон
    reads = false;
    dynoang (-180, 0, -0, -0, 150);
    delay(12);
    posit = false;
  }
  
  if (landy == true) { // Переход манипулятора в положение для посадки
    rtg = false;
    reads = false;
    dynoang (-180, 0, -90, -90, 25);
    delay(12);
    //Serial.println(Nas);
    /*for (int i = 0; i < 3; i++) {
      Serial2.println(Delta[i]);
      Serial2.print(" ");
      }
      Serial2.println();*/
    landy = false;
  }
  
  if (rtg == false) { // Проверка готовности к новому действию
    for (int cnt = 0; cnt < 4; cnt++)
    {
      result = dxl_wb.itemRead(dxl_id[cnt], "Moving", &get_mov[cnt], &log);
      //Serial2.println(get_mov[cnt]);
    }
    if (get_mov[0] == 0 && get_mov[1] == 0 && get_mov[2] == 0 && get_mov[3] == 0) {
      rtg = true;
      Serial2.println("r");
    }
    //delay(12);
  }

  //delay(20);

  // Выводим данные о состоянии, если прошло ReadTime мсек
  CurTime=millis()-InitTime;
  if ((read2 == true) && (CurTime>NextTime)) {
    //Serial2.println("get "+String(millis()-InitTime));
    NextTime=millis()-InitTime+ReadTime;
    curdatprint();
  }
  //else delay(10);//(abs(ReadTime-(NextTime-CurTime)-5)); IMU
  //Serial2.println("end "+String(millis()-InitTime));
  Serial2.flush(); // May be, should be deleted
}
