%Searches for the port that the teensy controlling the odor machine is 
%connected to and sets a "Port" global that is referenced by the odor 
%machine controlling functions

function [ConnectMsg] = InitializeOM

global Port

Port = []; %Clear previous assignments

ModeByte = uint8(42);
Response = uint8(0);
FoundPort = 0;

disp('Searching for odor machine...')
SerialPortInfo = instrhwinfo('serial');
PortList = SerialPortInfo.AvailableSerialPorts;
if isempty(PortList)
    ConnectMsg = 'No serial ports available';
    return
end
for ii = 1:length(PortList)
    disp(['Trying port ' PortList{ii}])
    TestSerial = ArCOMObject(PortList{ii}, 115200); %Open port
    TestSerial.write(ModeByte, 'uint8'); %Write test byte
    try
        Response = TestSerial.read(1,'uint8'); %Read serial response
    catch
        %Ignore
    end
    if Response == ModeByte
        ConnectMsg = ['Odor machine is available on ' PortList{ii}];
        disp(ConnectMsg)
        FoundPort = PortList{ii};
    else
        ConnectMsg = 'No odor machine found';
        disp(ConnectMsg)
    end
end

TestSerial = []; %Clear test object
Port = ArCOMObject(FoundPort, 115200); %Assign port info to global

end