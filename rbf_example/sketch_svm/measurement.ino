#include <avr/pgmspace.h>

// here the data is measured which should be predicted by the SVM
int sensor1, sensor2, sensor3, sensor4, sensor5;
int sensor6, sensor7, sensor8, sensor9;

void setup(){
    Serial.begin(115200);
    
    pinMode(8,OUTPUT);
    pinMode(9,OUTPUT);

}

void loop(){
  

    digitalWrite(8,LOW);
    digitalWrite(9,HIGH);



    
    sensor1 = analogRead(0);
    sensor2 = analogRead(1);
    sensor3 = analogRead(2);
    sensor4 = analogRead(3);
    sensor5 = analogRead(4);
    
    delay(200);
    digitalWrite(8,HIGH);
    digitalWrite(9,LOW);

 
    delay(200);
    
    sensor6 = analogRead(0);
    sensor7 = analogRead(1);
    sensor8 = analogRead(2);
    sensor9 = analogRead(3);

    delay(200);
    

    digitalWrite(8,LOW);
    digitalWrite(9,HIGH);
    
    int sensors[9]= {sensor1, sensor2, sensor3, sensor4, sensor5, sensor6, sensor7, sensor8, sensor9};
    // prediction funktion is called with the mesurd data
    svm_predict(sensors);
}
