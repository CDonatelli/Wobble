function [] = COMTableGenerator(csvName)
    list = dir('*.mat');

    % SingleValues
    Names = [];
    fishLength = [];
    swimmingSpeed = [];
    relSwimmingSpee = [];
    Frequency = [];
    Period = [];
    wavelength = [];
    StrideLength = [];
    waveSpeed = [];
    Amplitude = [];
    Names = [];
    for i = 1:length(list)
        NameStr = list(i).name;
        Struct = load(NameStr);
        Struct = Struct.Struct;
        
        swimmingSpeed = [swimmingSpeed; Struct.swimmingSpeed];
        Frequency = [Frequency; Struct.bendingFrequency];
        Period = [Period; Struct.bendingPeriod];
        StrideLength = [StrideLength; Struct.bendingStrideLength];
        wavelength = [wavelength; Struct.wavelength];
        Amplitude = [Amplitude; Struct.bendingAmp];
        Names = [Names; NameStr(1:end-4)];
    end
    Names = cellstr(Names);
    T = table(Names, ...
                swimmingSpeed, ...
                Frequency, ...
                Period, ...
                StrideLength, ...
                wavelength, ...
                Amplitude);
%    A = table2array(T);
   writetable(T,csvName);
   
   % Angles and Time
   for i = 1:length(list)
       NameStr = list(i).name;
       Struct = load(NameStr);
       Struct = Struct.Struct;
       
       time = Struct.time;
       angle = Struct.TailAngleCorr';
       T2 = table(time,angle);
       writetable(T2, [NameStr(1:end-4),'Angles.csv']);
   end
   
end