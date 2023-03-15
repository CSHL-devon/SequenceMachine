%This function tests the connection between Matlab and a teensy-controlled
%valve driver/odor machine.

function [ConnectMsg] = TestConnection

Response = uint8(0);

ModeByte = uint8(42);
Port = ArCOMObject('COM4', 115200); %Serial port for Teensy
Port.write(ModeByte, 'uint8'); %Write test byte to Teensy
Response = Port.read(1,'uint8'); %Read serial response from Teensy

if Response == ModeByte
    ConnectMsg = "Odor machine is available on COM4";
    %disp([ConnectMsg])
else
    ConnectMsg = "No odor machine found";
    %disp([ConnectMsg])
end

clear Port; %Clear the serial port Object (releases the port)
end