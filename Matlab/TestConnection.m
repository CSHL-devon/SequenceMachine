%This function tests the connection between Matlab and a teensy-controlled
%valve driver/odor machine.

function TestConnection

ModeByte = uint8(42);
Port = ArCOMObject('COM4', 115200); %Serial port for Teensy
Port.write(ModeByte, 'uint8'); %Write test byte to Teensy
Response = Port.read(1,'uint8'); %Read serial response from Teensy

if Response == ModeByte
    disp(['Odor machine is available on COM4'])
else
    disp(['Odor machine response incorrect. Check serial configuration.'])
end

clear Port; %Clear the serial port Object (releases the port)