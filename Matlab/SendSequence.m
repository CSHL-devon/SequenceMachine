%-------------------------------------------------------------------------------------------------------
% This function sends a stimulation sequence of two odorants to a teensy-controlled 
% valve driver/odor machine.Relies on ArCOM libraries written by Josh Sanders 
% (https://github.com/sanworks)
% 
% Input arguments are as follows:
%     - Paradigm: 0 = Single odor presentation (normal olfactometer), 1 = sequence presentation.
%     - FirstStimulus: The odor valve that will be opened first in the sequence (bank 1)
%         - For the standard, 12-odor teensy 4.0 machine, the options are: 1 - 6.
%     - SecondStimulus: The odor valve that will be opened second in the sequence (bank 2)
%         - For the standard, 12-odor teensy 4.0 machine, the options are: 7 - 12.
%     - PrefillTime: Time the odor is allowed to flood the tubes leading to the final valve 
%         prior to presentation to the animal.
%     - StimulusLength: Time final valve is open and odorant is being presented to the animal.
%     - SequenceDelay: Time between the end of the first odor presentation and the start of the second.
%
% Devon Cowan, CSHL 2023
%-------------------------------------------------------------------------------------------------------

function SendSequence(Paradigm, FirstStimulus, SecondStimulus, PrefillTime, StimulusLength, SequenceDelay)

%Check stimulus range and correct odor numbers to teensy pin assignments
if FirstStimulus < 1 || FirstStimulus > 6
    disp('FirstStimulus is out of range. Check odor number.');
    return
elseif SecondStimulus < 1 || SecondStimulus > 6
    disp('SecondStimulus is out of range. Check odor number.');
    return
else
    FirstStimPin = FirstStimulus - 1;
    if SecondStimulus <= 4
        SecondStimPin = SecondStimulus + 5;
    else
        SecondStimPin = SecondStimulus + 9;
    end
end

%Prepare OM to receive stim sequence
ModeByte = uint8(24);

%Create Uint16 array of parameters for odor machine
Parameters = uint16([Paradigm, FirstStimPin, SecondStimPin, PrefillTime, StimulusLength, SequenceDelay]);

Port = ArCOMObject('COM4', 115200); %Serial port for Odor machine Arduino

Port.write(ModeByte, 'uint8'); %Tell OM to prepare for stim parameters
Port.write(Parameters, 'uint16'); %Write parameters array to Arduino
Response = Port.read(6, 'uint16'); %Read back same array to confirm receipt

clear Port; %Clear the serial port Object (releases the port)