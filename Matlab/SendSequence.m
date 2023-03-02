function SendSequence(PrefillTime, StimulusSequence, StimulusLength, SequenceDelay, ITI)

ModeByte = uint8(24);

%Create Uint16 array of parameters for odor machine
Parameters = uint16([PrefillTime, StimulusSequence, StimulusLength, SequenceDelay, ITI]);

Port = ArCOMObject('COM4', 115200); %Serial port for Odor machine Arduino

Port.write(ModeByte, 'uint8'); %Tell OM to prepare for stim parameters
Port.write(Parameters, 'uint16'); %Write parameters array to Arduino
Response = Port.read(5, 'uint16');

clear Port; %Clear the serial port Object (releases the port)