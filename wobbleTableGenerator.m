function [T, A] = wobbleTableGenerator(csvName)
    list = dir;

    SwimmingSpeed = [];
    F = [];
    T = [];
    SL = [];
    lambda = [];
    amplitude = [];
    wobF = [];
    wobT = [];
    wobSL = [];
    wobLambda = [];
    wobAmp = [];
    RowNames = [];
    for i = 3:length(list)
        NameStr = list(i).name;
        Struct = load(NameStr);
        Struct = Struct.Struct;
        
        SwimmingSpeed = [SwimmingSpeed; Struct.swimmingSpeed];
        F = [F; Struct.bendingFrequency];
        T = [T; Struct.bendingPeriod];
        SL = [SL; Struct.bendingStrideLength];
        lambda = [lambda; Struct.wavelength];
        amplitude = [amplitude; Struct.bendingAmp];
        wobF = [wobF; Struct.wobbleFrequency];
        wobT = [wobT; Struct.wobblePeriod];
        wobSL = [wobSL; Struct.wobbleStrideLength];
        wobLambda = [wobLambda; Struct.wobbleWavelength];
        wobAmp = [wobAmp; Struct.wobbleAmp];
        
        RowNames = [RowNames; NameStr(1:8)];
    end
    RowNames = cellstr(RowNames);
    T = table(SwimmingSpeed, ...
                F, ...
                T, ...
                SL, ...
                lambda, ...
                amplitude, ...
                wobF, ...
                wobT, ...
                wobSL, ...
                wobLambda, ...
                wobAmp, ...
                'RowNames',RowNames);
   A = table2array(T);
   writetable(T,csvName);
end