#include <Wire.h>
#include <Adafruit_Sensor.h>
#include <Adafruit_BNO055.h>
#include <utility/imumaths.h>

#define BUFSIZE 64

const int buttonPin = 12;
const int ledPin = 13;

String startString = "start";
String stopString = "stop";
String testString;

// Amount of time between prints (ms)
const unsigned long PRINT_SPEED = 10;

// Set Inital Button State
int buttonState = 1;

// Time
unsigned long TIME = 0;


Adafruit_BNO055 bno = Adafruit_BNO055(55);

void setup() {
  Serial.begin(57600);

  if (!bno.begin()) {
    Serial.print("Error with IMU");
    while (1);
  }

  delay(100);

  bno.setExtCrystalUse(true);

}

void loop() {
  digitalWrite(ledPin, LOW);

  buttonState = digitalRead(buttonPin);

  if (buttonState == 0) {
    delay(150);
    Serial.print("start");
    delay(150);
  }
  
  char c, inputs[BUFSIZE + 1];

  if (Serial.available()) {
    c = Serial.readBytes(inputs, BUFSIZE);
    inputs[c] = 0;
    testString = String(inputs);
  }

  if (testString == startString) {
    digitalWrite(ledPin, HIGH);
    delay(50);
    unsigned long n = 0;
    unsigned long startTime = millis();
    while (true) {
      TIME = loopTime(startTime);
      if (TIME >= (n * PRINT_SPEED)) {
        imu::Vector<3> Gyro = bno.getVector(Adafruit_BNO055::VECTOR_GYROSCOPE);
        imu::Vector<3> Accel = bno.getVector(Adafruit_BNO055::VECTOR_ACCELEROMETER);
        imu::Vector<3> Euler = bno.getVector(Adafruit_BNO055::VECTOR_EULER);
        Serial.print(TIME);
        Serial.print(", ");
        Serial.print(Gyro.x());
        Serial.print(", ");
        Serial.print(Gyro.y());
        Serial.print(", ");
        Serial.print(Gyro.z());
        Serial.print(", ");
        Serial.print(Accel.x());
        Serial.print(", ");
        Serial.print(Accel.y());
        Serial.print(", ");
        Serial.print(Accel.z());
        Serial.print(", ");
        Serial.print(Euler.x());
        Serial.print(", ");
        Serial.print(Euler.y());
        Serial.print(", ");
        Serial.print(Euler.z());
        Serial.println();
        n++;
      }
      buttonState = digitalRead(buttonPin);
      if (buttonState == 0) {
        Serial.println(stopString);
        delay(100);
      }
      if (Serial.available()) {
        c = Serial.readBytes(inputs, BUFSIZE);
        inputs[c] = 0;
        testString = String(inputs);
        if (testString == stopString) {
          break;
        }
      }
    }
  }

}


unsigned long loopTime(unsigned long startTime) {
  unsigned long t = millis() - startTime;
  return t;
}
