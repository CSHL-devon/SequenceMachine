

%test = uint16(zeros(1,2));
test = uint16([42 24]);
Port = ArCOMObject('COM4', 115200);
Port.write(test, 'uint16'); % Write Uint16

pause(1);

response = Port.read(2, 'uint16'); 
   clear Port; % clear the Object (releases the port)