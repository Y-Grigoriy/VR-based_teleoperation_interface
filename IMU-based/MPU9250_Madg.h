#ifndef MPU9250_MADG_H
#define MPU9250_MADG_H

#include "Arduino.h"
#include "Wire.h"

#define MPU6050_ADDR         0x68
#define MPU6050_SMPLRT_DIV   0x19
#define MPU6050_CONFIG       0x1a
#define MPU6050_GYRO_CONFIG  0x1b
#define MPU6050_ACCEL_CONFIG 0x1c
#define MPU6050_WHO_AM_I     0x75
#define MPU6050_PWR_MGMT_1   0x6b
#define MPU6050_TEMP_H       0x41
#define MPU6050_TEMP_L       0x42

//Variables of Madgwick filter
#include <math.h>

#define SAMPLE_FREQ	1000.0f		// sample frequency in Hz
#define BETA_DEF	0.5f		// 2 * proportional gain

#define RAD_TO_DEG 57.295779513082320876798154814105

class MPU6050{
  public:

  MPU6050(TwoWire &w);
  MPU6050(TwoWire &w, float aC, float gC);

  void begin();

  void setGyroOffsets(float x, float y, float z);

  void writeMPU6050(byte reg, byte data);
  byte readMPU6050(byte reg);

  int16_t getRawAccX(){ return rawAccX; };
  int16_t getRawAccY(){ return rawAccY; };
  int16_t getRawAccZ(){ return rawAccZ; };

  int16_t getRawTemp(){ return rawTemp; };

  int16_t getRawGyroX(){ return rawGyroX; };
  int16_t getRawGyroY(){ return rawGyroY; };
  int16_t getRawGyroZ(){ return rawGyroZ; };

  float getTemp(){ return temp; };

  float getAccX(){ return accX; };
  float getAccY(){ return accY; };
  float getAccZ(){ return accZ; };

  float getGyroX(){ return gyroX; };
  float getGyroY(){ return gyroY; };
  float getGyroZ(){ return gyroZ; };

	void calcGyroOffsets(bool console = false, uint16_t delayBefore = 1000, uint16_t delayAfter = 3000);

  float getGyroXoffset(){ return gyroXoffset; };
  float getGyroYoffset(){ return gyroYoffset; };
  float getGyroZoffset(){ return gyroZoffset; };

  void update();
  void update(float& gx, float& gy, float& gz, float& ax, float& ay, float& az);

  float getAccAngleX(){ return angleAccX; };
  float getAccAngleY(){ return angleAccY; };

  float getGyroAngleX(){ return angleGyroX; };
  float getGyroAngleY(){ return angleGyroY; };
  float getGyroAngleZ(){ return angleGyroZ; };

  float getAngleX(){ return angleX; };
  float getAngleY(){ return angleY; };
  float getAngleZ(){ return angleZ; };

  private:

  TwoWire *wire;

  int16_t rawAccX, rawAccY, rawAccZ, rawTemp,
  rawGyroX, rawGyroY, rawGyroZ;

  float gyroXoffset, gyroYoffset, gyroZoffset;

  float temp, accX, accY, accZ, gyroX, gyroY, gyroZ;

  float angleGyroX, angleGyroY, angleGyroZ,
  angleAccX, angleAccY, angleAccZ;

  float angleX, angleY, angleZ;

  float interval;
  long preInterval;

  float accCoef, gyroCoef;
};

/*class Madgwick {

public:
	Madgwick();
	void readQuaternions(float *q0, float *q1, float *q2, float *q3);
	void reset();
	void setKoeff(float sampleFreq, float beta);
	void update(float gx, float gy, float gz, float ax, float ay, float az, float mx, float my, float mz);
	void update(float gx, float gy, float gz, float ax, float ay, float az);
	float getPitchRad();
	float getRollRad();
	float getYawRad();
	float getPitchDeg();
	float getRollDeg();
	float getYawDeg();

private:
	float invSqrt(float x);
	volatile float _beta = BETA_DEF;				// algorithm gain
	volatile float _sampleFreq = SAMPLE_FREQ;
	volatile float _q0 = 1.0f;
	volatile float _q1 = 0.0f;
	volatile float _q2 = 0.0f;
	volatile float _q3 = 0.0f;
};*/

#endif
