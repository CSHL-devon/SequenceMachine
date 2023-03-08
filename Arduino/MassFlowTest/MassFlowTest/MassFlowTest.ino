#include "Arcom.h"
#include <SPI.h>

ArCOM OMSerial(Serial); //Create ArCOM wrapper for SerialUSB

const int SlavePin = 2;
unsigned short MassFlowValues[2] = {0};
unsigned short Data2DAC = 0;

void setup() {
  pinMode(SlavePin, OUTPUT);
  SPI.begin();
}

void loop() {
  if (OMSerial.available()) {
    OMSerial.readUint16Array(MassFlowValues, 2);

    Data2DAC = (MassFlowValues[0]) | (MassFlowValues[1]);
    OMSerial.writeUint16(Data2DAC);
    //WriteToDAC(Data2DAC);
    //delay(5000);
  }
}

/*void WriteToDAC(MassFlowValues[]){

  digitalWriteFast(SlavePin, LOW);
  SPI.transfer
}
*/