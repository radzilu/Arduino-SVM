#include <avr/pgmspace.h>

 // In this section you should implement the handling of your sensor data, which you would like to classify.
 // and an example would be:
int sensors[5] = {0}; 

// int sensor1, sensor2, sensor3, sensor4, sensor5;

 void setup(){
  Serial.begin(115200);
}

void loop(){

  //sensor1 = analogRead(0);
  //sensor2 = analogRead(1);
  //sensor3 = analogRead(2);
  //sensor4 = analogRead(3);
  //sensor5 = analogRead(4);
  //delay(600);
  // sensors= {sensor1, sensor2, sensor3, sensor4, sensor5};

  svm_predict(sensors);
}
