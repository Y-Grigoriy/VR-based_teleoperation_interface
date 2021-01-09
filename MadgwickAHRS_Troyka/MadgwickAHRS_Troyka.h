#ifndef MADGWICK_TROYKA_AHRS_H_
#define MADGWICK_TROYKA_AHRS_H_

#include <math.h>

#define SAMPLE_FREQ  1000.0   // sample frequency in Hz
#define BETA_DEF  0.5    // 2 * proportional gain
#define PITCH_UPPER_BOUND   65.0    // degrees
#define PITCH_LOWER_BOUND   45.0    // degrees

#define RAD_TO_DEG 57.295779513082320876798154814105

class Madgwick_Troyka {

public:
    Madgwick_Troyka();
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

    void getAngles(float &yaw, float &pitch, float &roll);
    void getAnglesDeg(float &yaw, float &pitch, float &roll);

private:
    float invSqrt(float x);
    volatile float _beta = BETA_DEF;        // algorithm gain
    volatile float _sampleFreq = SAMPLE_FREQ;
    volatile float _q0 = 1.0;
    volatile float _q1 = 0.0;
    volatile float _q2 = 0.0;
    volatile float _q3 = 0.0;

    volatile float _yaw = 0.0;
    volatile float _pitch = 0.0;
    volatile float _roll = 0.0;

    static constexpr float _pitch_upper = PITCH_UPPER_BOUND / RAD_TO_DEG;
    static constexpr float _pitch_lower = PITCH_LOWER_BOUND / RAD_TO_DEG;

    bool magnetometer_used = false;
};
#endif
