%This function triggers stimulus presentation after the valve sequence is
%sent to the teensy by the "SendSequence" function.

function ActivateOM

ModeByte = uint8(66);
Port = ArCOMObject('COM4', 115200); %Serial port for Teensy
Port.write(ModeByte, 'uint8'); %Write trigger byte to teensy

clear Port;
end