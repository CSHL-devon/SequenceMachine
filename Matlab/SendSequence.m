%-------------------------------------------------------------------------------------------------------
% This function sends a stimulation sequence of two odorants to a teensy-controlled 
% valve driver/odor machine. Relies on ArCOM libraries written by Josh Sanders 
% (https://github.com/sanworks)
% 
% Input arguments are as follows:
%     - Paradigm: 0 = Single odor presentation, 1 = sequence presentation.
%     - MFC1/2: Mass flow controller values (0-1) for trial by trial concentration changes 
%         of air dilution machines. 
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

function SendSequence(Paradigm, MFC1, MFC2, FirstStimulus, SecondStimulus, PreFillTime, StimulusLength, SequenceDelay)

global Port

%Convert MFC values from percentage to 12-bit range (0-4095)
MFC1 = MFC1*4095;
MFC2 = MFC2*4095;

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

%Prepare Teensy to receive stim sequence
ModeByte = uint8(24);

%Prepare mass flow controller values
MFWord = [(dec2bin(MFC1, 12)) (dec2bin(MFC2, 12))];
MFByteArray = uint8([bin2dec(MFWord(:,1:8)), bin2dec(MFWord(:,9:16)), bin2dec(MFWord(:,17:24))]);

%Create Uint16 array of parameters for valve states
Parameters = uint16([Paradigm, FirstStimPin, SecondStimPin, PreFillTime, StimulusLength, SequenceDelay]);

%Send stimulation information to Teensy
Port.write(ModeByte, 'uint8');
Port.write(MFByteArray, 'uint8');
Port.write(Parameters, 'uint16');
Response = Port.read(6, 'uint16'); %Read back parameters array to confirm receipt

end