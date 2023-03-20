%{
-------------------------------------------------------------------------------------------------------
This file is part of the SequenceMachine repository
Devon Cowan, CSHL 2023
-------------------------------------------------------------------------------------------------------

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, version 3.

This program is distributed  WITHOUT ANY WARRANTY and without even the
implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>
%}

%{
-------------------------------------------------------------------------------------------------------
Searches for the port that the teensy controlling the odor machine is 
connected to and sets a "Port" global that is referenced by the odor 
machine controlling functions
-------------------------------------------------------------------------------------------------------
%}

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