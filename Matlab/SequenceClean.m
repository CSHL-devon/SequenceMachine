%Iterates through the number of vials on each bank as defined by "NumOdors."
%"CleaningCycles" determines how many complete passes through the machine are performed.

function SequenceClean(CleaningCycles, NumOdors)

global Port

MFC1 = 4095; %Max-out MFCs
MFC2 = 4095;

%Prepare mass flow controller values
MFWord = [(dec2bin(MFC1, 12)) (dec2bin(MFC2, 12))];
MFByteArray = uint8([bin2dec(MFWord(:,1:8)), bin2dec(MFWord(:,9:16)), bin2dec(MFWord(:,17:24))]);


   for ii = 1:CleaningCycles
       for jj = 1:NumOdors
           FirstStimulus = jj;
           SecondStimulus = jj;
       
           FirstStimPin = FirstStimulus - 1;
            if SecondStimulus <= 4
               SecondStimPin = SecondStimulus + 5;
            else
               SecondStimPin = SecondStimulus + 9;
            end
       
            %Prioritize cleaning outputs
            Parameters = uint16([1, FirstStimPin, SecondStimPin, 100, 5000, 100]);
            
            ModeByte = 24;
       
            %Send stimulation information to Teensy
            Port.write(ModeByte, 'uint8');
            Port.write(MFByteArray, 'uint8');
            Port.write(Parameters, 'uint16');
       
            pause(1);
            
            ModeByte = uint8(66);
            
            Port.write(ModeByte, 'uint8');
       
            pause(6);
       end
   end

end