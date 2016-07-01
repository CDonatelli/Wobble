function [time, errors] = wobblePeaksBatch()
    time = [];
    errors = struct;
    erorrs.start = 'empty';
    list = dir('*.mat');
    for i = 1:length(list)
           t = [];  tic
       try
           NameStr = list(i).name;
           Struct = load(NameStr);
           Struct = Struct.Struct;
           if isfield(Struct,'wobTailT') == 1
           else
                Struct = wobblePeaks(Struct, NameStr);
                save(NameStr, 'Struct');
                t = toc;
           end
  
       catch err
           errors.(NameStr(1:8)) = getReport(err);
       end
       close all
           time = [time; t];
    end

end
