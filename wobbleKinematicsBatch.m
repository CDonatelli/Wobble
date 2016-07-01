function [ list, time, errors ] = wobbleKinematicsBatch( )
%     load(file)
%     clear file
%     list = whos;
     time = [];
     errors = struct;
     erorrs.start = 'empty';
    % a = imageInfo(eval(a(1).name))
    list = dir;
    for i = 3:length(list)
           t = [];  tic
       try
           NameStr = list(i).name;
           Struct = load(NameStr);
           Struct = Struct.Struct;
           if isfield(Struct,'indpeakTail') == 1
           else
               Struct.indpeakTail = [];
               Struct.indpeakTwist = [];
               Struct.indpeakTail = analyzeKinematics(Struct.stail, Struct.t, ... 
                               Struct.tailXs,Struct.tailYs, 'dssmoothcurve',5);
               Struct.indpeakTwist = analyzeKinematics(Struct.stwist', Struct.t, ... 
                             Struct.twistXs,Struct.twistYs, 'dssmoothcurve',5);
               disp(['Ran analyzeKinematics ', num2str(i), ' out of ', ...
                                                       num2str(length(list))]);
               save(NameStr, 'Struct');
           end
           t = toc;  tic
       catch err
           errors.(NameStr(1:8)) = getReport(err);
       end
       close all
           time = [time, t];
    end
end