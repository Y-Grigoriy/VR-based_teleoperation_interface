/*****************************************************************************************
  Control code for wearable interface based on 3 IMU-sensors and 1 flex sensor
*****************************************************************************************/

#include <Wire.h>
#include "MadgwickAHRS_Troyka/MadgwickAHRS_Troyka.h"
#include "MPU9250_Madg/MPU9250_Madg.h" // Данная библиотека является модификацией библиотеки: https://github.com/bolderflight/MPU9250

#define BETA 0.2f
#define TO_DEG 57.29577951308232087679815481410517033f

Madgwick_Troyka filter[3];
Madgwick_Troyka filter_90[3];

// переменная для хранения частоты выборок фильтра
float fps = 100; //100
unsigned long start_millis, delta_millis;
unsigned long cur_millis, prev_time;

// an MPU9250 object with the MPU-9250 sensor on I2C bus 0 with address 0x68
MPU6050 mpu6050(Wire, 0.04, 0.96); // обычно 0.02 и 0.98
int status;
float ax[3], ay[3], az[3], gx[3], gy[3], gz[3], c[3];
float yaw[3] = {0.0, 0.0, 0.0}, pitch[3] = {0.0, 0.0, 0.0}, roll[3] = {0.0, 0.0, 0.0};
float yaw_90[3] = {0.0, 0.0, 0.0}, pitch_90[3] = {0.0, 0.0, 0.0}, roll_90[3] = {0.0, 0.0, 0.0};
int porti[3] = {2, 4, 7};

const int FLEX_PIN = A2; // аналоговый пин гибкого датчика

// Определение пинов вибромоторов
int motorPin[5] = {2, 3, 4, 5, 6};
int vibr_value = 200;
boolean vibro = false;
int val = 0;

// Определение мультипексора
void tcaselect(uint8_t i) {
  if (i > 7) return;
  Wire.beginTransmission(0x70);
  Wire.write(1 << i);
  Wire.endTransmission();
}

void setup() {
  Serial.begin(115200);
  while (!Serial) {}
  Wire.begin();
  mpu6050.setGyroOffsets(0.78, 0.40, -0.23);
  prev_time = millis();
  pinMode(FLEX_PIN, INPUT);
}

void loop() {
  start_millis = millis();
  for (int i = 0; i < 3; i++) // Readings from IMUs
  {
    tcaselect(porti[i]);

    mpu6050.begin();
    mpu6050.update(gx[i], gy[i], gz[i], ax[i], ay[i], az[i]);

    filter[i].setKoeff(fps, BETA);
    filter_90[i].setKoeff(fps, BETA);

    filter[i].update(gx[i], gy[i], gz[i], ax[i], ay[i], az[i]);
    filter_90[i].update(gx[i], -gz[i], gy[i], ax[i], -az[i], ay[i]);

    filter[i].getAnglesDeg(yaw[i], pitch[i], roll[i]);
    filter_90[i].getAnglesDeg(yaw_90[i], pitch_90[i], roll_90[i]);

    float x = constrain(pitch[i], -45.0, 45.0) / 45.0;
    c[i] = 1.0 / (1 + exp(-20 * (x - 0.5)));

    // выводим полученные углы в serial-порт
    /*Serial.print(yaw[i]);
      Serial.print(" ");
      Serial.print((90 + pitch_90[i]) * c + pitch[i] * (1 - c));
      Serial.print(" ");
      Serial.print(roll_90[i] * c + roll[i] * (1 - c));
      Serial.print(" ");*/
  }
  int flexADC = analogRead(FLEX_PIN);
  //Serial.println();
  cur_millis = millis();
  if ((cur_millis - prev_time) >= 20) {
    prev_time = cur_millis;
    Serial.println(String(int(roll_90[2] * c[2] + roll[2] * (1 - c[2]))) + "," + String(int(roll_90[1] * c[1] + roll[1] * (1 - c[1]))) + "," + String(int((90 + pitch_90[0]) * c[0] + pitch[0] * (1 - c[0]))) + "," + String(flexADC) + "," + String(int((90 + roll_90[0]) * c[0] + roll[0] * (1 - c[0]))) + "," + String(cur_millis));
  }
  // вычисляем затраченное время на обработку данных
  delta_millis = millis() - start_millis;

  // вычисляем частоту обработки фильтра
  fps = 1000 / delta_millis;

  if (Serial.available() > 0) {
    val = Serial.read();
    if (val == 'v') vibro = true;
    if (val == 's') vibro = false;
  }
  if (vibro == true) {
    for (int i = 0; i < 5; i++) analogWrite(motorPin[i], vibr_value);
    //delay(10);
    //vibro = false;
  }
  else for (int i = 0; i < 5; i++) analogWrite(motorPin[i], 0);

  //delay(10);
  Serial.flush();
}
