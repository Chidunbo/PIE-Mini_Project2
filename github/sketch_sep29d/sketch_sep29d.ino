#include <Servo.h>
// servo setup
Servo bottomServo;
Servo topServo;

int bottomPos = 0; // variable that record bottom servo position
int topPos = 0; // variable that record top servo position
int topOrigin = 90; // top servo position at orgin
int bottomOrigin = 90;  // bottom servo position at orgin
int bottomMin= 90;  // minimal bottom servo position
int bottomMax = 140; // maximal bottom servo position
int topMin= 50;  // minimal top servo position
int topMax = 100; // maximal top servo position
int step = 3; // step of increment


// camera setup
const int cameraPin = A0;

void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600); // set up serial port
  bottomServo.attach(10); // attatch bottom servo pin
  topServo.attach(11); // attatch bottom servo pin
  bottomServo.write(bottomOrigin); // set up bottom servo at origin
  topServo.write(topOrigin);  // set up top servo at origin
  int v0 = analogRead(cameraPin); // read sensor at origin
  Serial.println(v0); // print origin sensor reading 
  delay(3000);

}

void loop() {
  // sweep bottom servo loop
  for (bottomPos = bottomMin; bottomPos <= bottomMax; bottomPos += step) { // bottom moves in steps of 3 degree
    bottomServo.write(bottomPos); // fix bottom servo to be at bottom position
    delay(200); // wait for it to move
    for (topPos = topMin; topPos <= topMax; topPos += step) { // top moves in steps of 3 degree
      topServo.write(topPos);   // move top servo
      delay(200); // wait for it to move
      int v1 = analogRead(cameraPin); // take reading 1
      int v2 = analogRead(cameraPin); // take reading 2
      int v3 = analogRead(cameraPin); // take reading 3
      int v = min(min(v1,v2),v3); // find minimal of 3 readings to avoid spikes
      Serial.print(bottomPos-bottomOrigin); // print angle difference between origin and current
      Serial.print("/"); // separate readings with "/"
      Serial.print(topPos - topOrigin); // print angle difference between origin and current
      Serial.print("/");  // separate readings with "/"
      Serial.println(v);  // print final reading
    }  
    topServo.write(topMin);   // move top servo back to top
    delay(700); // wait for servo to move to inital position
  }
}