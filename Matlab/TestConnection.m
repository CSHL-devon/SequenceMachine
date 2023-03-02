function TestConnection

ModeByte = uint8(42);
Port = ArCOMObject('COM4', 115200); %Serial port for Odor machine Arduino
Port.write(ModeByte, 'uint8'); %Write parameters array to Arduino
Response = Port.read(1,'uint8'); %Read serial response from Arduino

if Response == ModeByte
    disp(['Odor machine is available on COM4'])
else
    disp(['Odor machine response incorrect. Check serial configuration.'])
end

clear Port; %Clear the serial port Object (releases the port)