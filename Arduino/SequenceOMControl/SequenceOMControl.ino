/*
---------------------------------------------------------------------------------------
This file is part of the SequenceMachine repository
Devon Cowan, CSHL 2023
---------------------------------------------------------------------------------------
This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, version 3.

This program is distributed  WITHOUT ANY WARRANTY and without even the
implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>
---------------------------------------------------------------------------------------
This sketch is for running a teensy(4.0)-based olfactometer that presents a sequence
of two odorants in rapid succession from two different banks of odorants. It takes 
serial input from Matlab via ArCOM (https://github.com/sanworks).
---------------------------------------------------------------------------------------
*/

#include "Arcom.h" //Import ArCOM library
#include <SPI.h>

ArCOM OMSerial(Serial); //Create ArCOM wrapper for SerialUSB

const unsigned int ChipSelect = 10; //Pin to select 12-bit DAC for SPI communication
byte ModeByte = 0;
byte MFCValues[3] = {0}; //Mass flow controller byte array
byte MFCInitialization[3] = {0}; //Constant zero MFC value array for use in initialization steps
unsigned short Parameters[6] = {0}; //Valve parameter array

unsigned int ValvePins[] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 14, 15, 16, 17, 18, 19};
unsigned int NumValvePins = 16;
unsigned int CleaningValvePins[] = {18, 19};
unsigned int ShuttleValvePins[] = {16, 17};

void setup() {  
  //Set SPI pin mode
  pinMode(ChipSelect, OUTPUT);
  //Set valve control pins as outputs
  for (unsigned int i = 0; i < NumValvePins; i++){
    pinMode(ValvePins[i], OUTPUT);
  }

  //Intialize SPI
  SPI.begin();
  //Initialize the USB serial port
  Serial.begin(115200);
  
  //Close all valves, zero MFCs, open cleaning valves
  Initialize();
}

void loop() {
  if (OMSerial.available()) {
    ModeByte = OMSerial.readUint8(); //Read mode byte from PC
    switch (ModeByte) {
      case 42:
        OMSerial.writeByte(ModeByte); //Respond with same byte for confirmation
        Initialize();
        break;
      case 24:
        OMSerial.readUint8Array(MFCValues, 3); //Read mass flow controller values
        OMSerial.readUint16Array(Parameters, 6); //Read valve sequence from PC
        OMSerial.writeUint16Array(Parameters, 6); //Respond with same sequence for confirmation
        //Close all valves, zero MFCs, open cleaning valves
        Initialize();
        break;
      case 66: 
        //Execute odor 66
        ControlValves(Parameters, MFCValues);
        break;
    }
  }
}

void Initialize(){
  //Close all valves
  for (unsigned int i = 0; i < NumValvePins; i++){
    digitalWriteFast(ValvePins[i], LOW);
  }
  //Zero MFCs
  ControlMFCs(MFCInitialization);
  //Open Cleaning Valves
  digitalWriteFast(CleaningValvePins[0], HIGH);
  digitalWriteFast(CleaningValvePins[1], HIGH);
}

void ControlValves(unsigned short Parameters[], byte MFCValues[]){
  if(Parameters[0] == 0){ //No second odor
    digitalWriteFast(CleaningValvePins[0], LOW); //Close cleaning valve
    digitalWriteFast(Parameters[1], HIGH); //Open odor vial
    ControlMFCs(MFCValues); //Turn on MFCs
    delay(Parameters[3]); //Prefill tube with odor

    //Stimulus
    digitalWriteFast(ShuttleValvePins[0], HIGH); //Open shuttle (final) valve
    delay(Parameters[4]); //Length of stimulus presentation
    digitalWriteFast(ShuttleValvePins[0], LOW); //Close first shuttle valve

    //Cleanup
    delay(50); //Cleaning valves open faster than shuttle valve closes
    ControlMFCs(MFCInitialization); //Zero MFCs
    digitalWriteFast(Parameters[1], LOW); //Close odor vial
    digitalWriteFast(CleaningValvePins[0], HIGH); //Open cleaning valve
    
  }else{ //Sequence of two odors
    digitalWriteFast(CleaningValvePins[0], LOW); //Close cleaning valves
    digitalWriteFast(CleaningValvePins[1], LOW);
    digitalWriteFast(Parameters[1], HIGH); //Open odor vials
    digitalWriteFast(Parameters[2], HIGH);
    ControlMFCs(MFCValues);
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
    ControlMFCs(MFCInitialization);
    digitalWriteFast(Parameters[1], LOW); //Close odor vials
    digitalWriteFast(Parameters[2], LOW);
    digitalWriteFast(CleaningValvePins[0], HIGH); //Open cleaning valves
    digitalWriteFast(CleaningValvePins[1], HIGH);
  }
}

void ControlMFCs(byte MFCValues[]){
  //Prepare DAC to receive MFC values
  digitalWrite(ChipSelect,LOW);
  //Send MFC values to DAC
  for(unsigned int i = 0; i < 3; i++){
    SPI.transfer(MFCValues[i]);
    delayMicroseconds(20);
  }
  //De-select the DAC
  digitalWrite(ChipSelect,HIGH);   
}
