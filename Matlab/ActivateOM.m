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
------------------------------------------------------------------------------------------------------
This function triggers stimulus presentation after the valve sequence is
sent to the teensy by the "SendSequence" function.
------------------------------------------------------------------------------------------------------
%}

function ActivateOM

global Port

ModeByte = uint8(66);
Port.write(ModeByte, 'uint8'); %Write trigger byte to teensy

end