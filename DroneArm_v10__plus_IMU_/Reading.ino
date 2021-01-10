// Функция считывания показаний датчиков силы
void fsrdat (int FSR_PIN, float force)
{
  int fsrADC = analogRead(FSR_PIN);
  // If the FSR has no pressure, the resistance will be
  // near infinite. So the voltage should be near 0.
  if (fsrADC != 0) // If the analog reading is non-zero
  {
    // Use ADC reading to calculate voltage:
    float fsrV = fsrADC * VCC / 1023.0;
    // Use voltage and static resistor value to
    // calculate FSR resistance:
    float fsrR = R_DIV * (VCC / fsrV - 1.0);
    // Serial2.println("Resistance: " + String(fsrR) + " ohms");
    // Guesstimate force based on slopes in figure 3 of
    // FSR datasheet:
    float fsrG = 1.0 / fsrR; // Calculate conductance
    // Break parabolic curve down into two linear slopes:
    if (fsrR <= 600)
      force = (fsrG - 0.00075) / 0.00000032639;
    else
      force =  fsrG / 0.000000642857;
    //Serial2.println(String(FSR_PIN) + ": " + String(force) + " g");
    Serial2.print(String(force) + " ");
    delay(10);
  }
  else
  {
    // No pressure detected
  }
}

// Функция вывода данных в серийный порт (при перемещении манипулятора)
void datprint(int j)
{
  const char *log;
  //fsrdat (FSR_PIN, force);
  //fsrdat (FSRb_PIN, forceb);
  Serial2.print((theta0 + (Delta[0]) * (j + 1) / Nas));
  Serial2.print(" ");
  Serial2.print((beta0 + (Delta[1]) * (j + 1) / Nas));
  Serial2.print(" ");
  Serial2.print((alpha0 + (Delta[2]) * (j + 1) / Nas));
  Serial2.print(" ");
  Serial2.print((phi0 + (Delta[3]) * (j + 1) / Nas));
  Serial2.print(" ");
  Serial2.print(ksi);
  Serial2.print(" ");

  // Оценка крутящих моментов (необходимо убрать считывание с сервомоторов АХ-12)
  for (int cnt = 0; cnt < 4; cnt++)
  {
    dyno_ready = true;
    result = dxl_wb.itemRead(dxl_id[cnt], "Present_Load", &get_data0[cnt], &log);
    //Serial2.print((float)get_data0[cnt]);
    //Serial2.print(" ");
    result = dxl_wb.itemRead(dxl_id[cnt], "Present_Voltage", &get_dataVolt[cnt], &log);
    //Serial2.print((float)get_dataV[cnt]);
    //Serial2.print(" ");
    est_torq[cnt] = (((float)get_data0[cnt] * max_torq[cnt] * ((float)get_dataVolt[cnt] / (121 * 1023))));
    Serial2.print(est_torq[cnt]);
    Serial2.print(" ");
  }
  
  // Выставив высокий уровень сигнала, ждем около 10 микросекунд. В этот момент датчик будет посылать сигналы с частотой 40 КГц. (Для ультразвукового датчика)
  //delayMicroseconds(5); //10
  digitalWrite(PIN_TRIG, LOW);
  //  Время задержки акустического сигнала на эхолокаторе.
  duration = pulseIn(PIN_ECHO, HIGH);
  digitalWrite(PIN_TRIG, LOW);
  delayMicroseconds(5);
  digitalWrite(PIN_TRIG, HIGH);
  // Преобразование времени в расстояние
  cm = (duration / 2) / 29.1;
  if (!cm) cm=cmp;
  else cmp=cm;
  Serial2.print(cm);
  Serial2.print(" ");
  Serial2.print(" "+String(compass.a.x)+" "+String(compass.a.y)+" "+String(compass.a.z));
  Serial2.print(" "+String(compass.m.x)+" "+String(compass.m.y)+" "+String(compass.m.z)+" ");
  
  Serial2.println((millis() - InitTime));
}

// Функция вывода данных в серийный порт (при отсутствии перемещения манипулятора)
void curdatprint()
{
    
  const char *log;
  fsrdat (FSR_PIN, force);
  fsrdat (FSRb_PIN, forceb);
  for (int cnt = 0; cnt < 4; cnt++)
  {
    result = dxl_wb.itemRead(dxl_id[cnt], "Present_Position", &get_data[cnt], &log);
  }
  theta0 = 90 - (get_data[0] * 360 / resol_MX);
  beta0 = 90 - (get_data[1] * 360 / resol_MX);
  alpha0 = 70 - ((int16_t)get_data[2] * 300 / resol_AX);
  phi0 = 60 - ((int16_t)get_data[3] * 300 / resol_AX);
  Serial2.print(theta0);
  Serial2.print(" ");
  Serial2.print(beta0);
  Serial2.print(" ");
  Serial2.print(alpha0);
  Serial2.print(" ");
  Serial2.print(phi0);
  Serial2.print(" ");
  Serial2.print(ksi);
  Serial2.print(" ");
  for (int cnt = 0; cnt < 4; cnt++)
  {
    result = dxl_wb.itemRead(dxl_id[cnt], "Present_Load", &get_data0[cnt], &log);
    result = dxl_wb.itemRead(dxl_id[cnt], "Present_Voltage", &get_dataVolt[cnt], &log);
    est_torq[cnt] = (((float)get_data0[cnt] * max_torq[cnt] * ((float)get_dataVolt[cnt] / (121 * 1023))));
    Serial2.print(est_torq[cnt]);
    Serial2.print(" ");
  }
  
  // Выставив высокий уровень сигнала, ждем около 10 микросекунд. В этот момент датчик будет посылать сигналы с частотой 40 КГц.
  //delayMicroseconds(5); //10
  digitalWrite(PIN_TRIG, LOW);
  //  Время задержки акустического сигнала на эхолокаторе.
  duration = pulseIn(PIN_ECHO, HIGH);
  // Теперь осталось преобразовать время в расстояние
  cm = (duration / 2) / 29.1;
  if (!cm) cm=cmp;
  else cmp=cm;
  
  Serial2.print(cm);
  Serial2.print(" ");
  Serial2.print(" "+String(compass.a.x)+" "+String(compass.a.y)+" "+String(compass.a.z));
  Serial2.print(" "+String(compass.m.x)+" "+String(compass.m.y)+" "+String(compass.m.z)+" ");
  
  Serial2.println((millis() - InitTime));
}
