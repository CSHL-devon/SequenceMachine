#include "Arcom.h" //Import ArCOM library

ArCOM OMSerial(Serial); //Create ArCOM wrapper for SerialUSB
unsigned int ModeByte = 0;
unsigned short Parameters[5] = {0}; //Create parameter array

int ValvePins[] = {};


void setup() {

  Serial.begin(115200); //Initialize the USB serial port

}

void loop() {
  
  if (OMSerial.available()) {
    ModeByte = OMSerial.readUint8(); //Read mode byte from PC
    switch (ModeByte) {
      case 42: {
        OMSerial.writeUint8(ModeByte); //Respond with same byte for confirmation
      }
      case 24: {
        OMSerial.readUint16Array(Parameters, 5); //Read stim sequence from PC
        OMSerial.writeUint16Array(Parameters, 5); //Respond with same sequence for confirmation
      }
      case 66: {
        //Execute odor 66
      }
    }
  }
}
