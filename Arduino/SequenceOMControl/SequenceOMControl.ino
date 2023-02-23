#include "Arcom.h" //Import ArCOM library

ArCOM OMSerial(Serial); //Create ArCOM wrapper for SerialUSB
unsigned short test[2] = {0}; //Create test array

void setup() {

  Serial.begin(115200); // Initialize the USB serial port
  pinMode(LED_BUILTIN, HIGH);

}

void loop() {
  
  if (OMSerial.available()) {
    OMSerial.readUint16Array(test, 2);
    OMSerial.writeUint16Array(test, 2);
  }

}
