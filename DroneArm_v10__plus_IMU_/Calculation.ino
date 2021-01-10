// Angles cheking and transformation
void dynoang (float theta, float beta, float alpha, float phi, float ksi)
{
  if (theta > 0 || theta < -180) theta = theta0;
  if (beta > 0 || beta < -180) beta = beta0;
  if (alpha > 0 || alpha < -180) alpha = alpha0;
  if (phi > 0 || phi < -180) phi = phi0;
  if (ksi < 28 || ksi > 155) ksi = ksi0;
  //if (alpha >= 95 || alpha <= -95) alpha = alpha0;
  //if (phi >= 95 || phi <= -95) phi = phi0;
  betamin = -(180 - (-theta - atan(ld / l1) * 180 / pi) - (acos(1 - sq(sin(-theta * pi / 180 - atan(ld / l1)) * sqrt(sq(l1) + sq(ld)) / l2))) * 180 / pi);
  if (beta > betamin) beta = betamin;
  /*Serial.print(theta);
    Serial.print(" ");
    Serial.print(beta);
    Serial.print(" ");
    Serial.print(alpha);
    Serial.print(" ");
    Serial.println(phi);
    delay(12);*/

  // Определение максимального интервала между текущим и предыдущим углом
  maxDelta = 0;
  Nas = 1;
  Delta[0] = theta - theta0; // определение интервала между текущим и предыдущим углом
  if (abs(Delta[0]) > maxDelta) maxDelta = abs(Delta[0]);
  Delta[1] = beta - beta0; // определение интервала между текущим и предыдущим углом
  if (abs(Delta[1]) > maxDelta) maxDelta = abs(Delta[1]);
  Delta[2] = alpha - alpha0; // определение интервала между текущим и предыдущим углом
  if (abs(Delta[2]) > maxDelta) maxDelta = abs(Delta[2]);
  Delta[3] = phi - phi0; // определение интервала между текущим и предыдущим углом
  if (abs(Delta[3]) > maxDelta) maxDelta = abs(Delta[3]);
  //Serial.println(maxDelta);

  Nas = round(maxDelta / angstep); // определение количества шагов для перехода в новое положение
  //delay(4);

  for (int j = 0; j < Nas; j++)
  {
    dxl_wb.goalPosition(dxl_id[0], (int32_t)((90 - (theta0 + (Delta[0]) * (j + 1) / Nas)) * resol_MX / 360));
    //delay(6);
    dxl_wb.goalPosition(dxl_id[1], (int32_t)((90 - (beta0 + (Delta[1]) * (j + 1) / Nas)) * resol_MX / 360));
    dxl_wb.goalPosition(dxl_id[2], (int16_t)(abs(70 - (alpha0 + (Delta[2]) * (j + 1) / Nas)) * resol_AX / 300));
    dxl_wb.goalPosition(dxl_id[3], (int16_t)(abs(60 - (phi0 + (Delta[3]) * (j + 1) / Nas)) * resol_AX / 300));
    delay(3);
    datprint(j);
    if (Serial2.available() > 0) {
      val = Serial2.read();
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
      Serial2.print(String((parameters[3])!=NULL)+" ");
      Serial2.print(((parameters[0])!=NULL) && ((parameters[1])!=NULL) && ((parameters[2])!=NULL) && ((parameters[3])!=NULL));*/
      Serial2.println();
      //Serial.flush(); // May be, should be deleted
      //delay(6); // 10
      break;
    }
    }
  }
  //delay(8);
  myservo.write(ksi); // sets the servo position according to the scaled value

  // assigning of current angles
  theta0 = theta;
  beta0 = beta;
  alpha0 = alpha;
  phi0 = phi;
  ksi0 = ksi;
}
