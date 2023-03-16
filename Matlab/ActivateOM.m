%This function triggers stimulus presentation after the valve sequence is
%sent to the teensy by the "SendSequence" function.

function ActivateOM

global Port

ModeByte = uint8(66);
Port.write(ModeByte, 'uint8'); %Write trigger byte to teensy

end