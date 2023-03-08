/* 
---------------------------------------------------------------------------------------
This sketch is for running a teensy(4.0)-based olfactometer that presents a sequence
of two odorants in rapid succession from two different banks of odorants. If odor 2 is
defined at the input as "99," it will behave as if only odor 1 exists (as a normal 
olfactometer). It takes serial input from Matlab via ArCOM (https://github.com/sanworks).

Devon Cowan, CSHL 2023 
---------------------------------------------------------------------------------------
*/

#include "Arcom.h" //Import ArCOM library

ArCOM OMSerial(Serial); //Create ArCOM wrapper for SerialUSB
unsigned int ModeByte = 0;
unsigned short Parameters[6] = {0}; //Create parameter array

int ValvePins[] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 14, 15, 16, 17, 18, 19};
int CleaningValvePins[] = {18, 19};
int ShuttleValvePins[] = {16, 17};

void setup() {

  //Set valve control pins as outputs
  for (i = 0; i < ARRAY_SIZE(ValvePins); i++){
    pinMode(ValvePins[i], OUTPUT);
  }
  //Open cleaning valves
  digitalWriteFast(CleaningValvePins[0], HIGH);
  digitalWriteFast(CleaningValvePins[1], HIGH);
  //Initialize the USB serial port
  Serial.begin(115200);

}

void loop() {
  
  if (OMSerial.available()) {
    ModeByte = OMSerial.readUint8(); //Read mode byte from PC
    switch (ModeByte) {
      case 42: {
        OMSerial.writeUint8(ModeByte); //Respond with same byte for confirmation
      }
      case 24: {
        OMSerial.readUint16Array(Parameters, 6); //Read stim sequence from PC
        OMSerial.writeUint16Array(Parameters, 6); //Respond with same sequence for confirmation
        //Open Cleaning valves
        digitalWriteFast(CleaningValvePins[0], HIGH);
        digitalWriteFast(CleaningValvePins[1], HIGH);
      }
      case 66: {
        //Execute odor 66
        ControlValveStates(Parameters, 6);
      }
    }
  }
}

void ControlValveStates(unsigned short Parameters[]){
  if(Parameters[0] == 0){ //No second odor
    digitalWriteFast(CleaningValvePins[0], LOW); //Close cleaning valve
    digitalWriteFast(ValvePins[Parameters[0]], HIGH); //Open odor vial
    delay(Parameters[3]); //Prefill tube with odor

    //Stimulus
    digitalWriteFast(ShuttleValvePins[0], HIGH); //Open shuttle (final) valve
    delay(Parameters[4]); //Length of stimulus presentation
    digitalWriteFast(ShuttleValvePins[0], LOW); //Close first shuttle valve

    //Cleanup
    delay(50); //Cleaning valves open faster than shuttle valve closes
    digitalWriteFast(ValvePins[Parameters[1]], LOW); //Close odor vial
    digitalWriteFast(CleaningValvePins[0], HIGH); //Open cleaning valve
    
  }else{ //Sequence of two odors
    digitalWriteFast(CleaningValvePins[0], LOW); //Close cleaning valves
    digitalWriteFast(CleaningValvePins[1], LOW);
    digitalWriteFast(ValvePins[Parameters[1]], HIGH); //Open odor vials
    digitalWriteFast(ValvePins[Parameters[2]], HIGH);
    delay(Parameters[3]); //Prefill tubes with odor

    //First Stimulus
    digitalWriteFast(ShuttleValvePins[0], HIGH); //Open first shuttle (final) valve
    delay(Parameters[4]); //Length of first stimulus presentation
    digitalWriteFast(ShuttleValvePins[0], LOW); //Close first shuttle valve

    //Inter-stimulus time
    delay(Parameters[5]);

    //Second Stimulus
    digitalWriteFast(ShuttleValvePins[1], HIGH); //Open second shuttle valve
    delay(Parameters[4]); //Length of second stimulus presentation
    digitalWriteFast(ShuttleValvePins[1], LOW); //Close second shuttle valve

    //Cleanup
    delay(50); //Cleaning valves open faster than shuttle valve closes
    digitalWriteFast(ValvePins[Parameters[1]], LOW); //Close odor vials
    digitalWriteFast(ValvePins[Parameters[2]], LOW);
    digitalWriteFast(CleaningValvePins[0], HIGH); //Open cleaning valves
    digitalWriteFast(CleaningValvePins[1], HIGH);
  }
}
