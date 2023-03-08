%DACWord = dec2bin(4000,16);

MassFlowValues = uint16([2045, 4095]);

str = sprintf('%d',MassFlowValues(1), MassFlowValues(2));
num = uint32(str2num(str));

Port = ArCOMObject('COM4', 115200); %Serial port for Odor machine Arduino
Port.write(MassFlowValues, 'uint32'); %Write parameters array to Arduino
Response = Port.read(1,'uint32'); %Read serial response from Arduino

clear Port; %Clear the serial port Object (releases the port)