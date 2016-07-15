function [ list, time, errors ] = wobbleSmoothBatch( file )
    load(file)
    clear file
    list = whos;
    time = [];
    errors = struct;
    erorrs.start = 'empty';
    % a = imageInfo(eval(a(1).name))
    for i = 1:length(list)
           t = [];  tic
       try
           NameStr = list(i).name;
           Struct = wobbleSmooth(eval(list(i).name));
           disp(['Ran wobbleSmooth ', num2str(i), ' out of ', num2str(length(list))]);
           save(NameStr, 'Struct');
           t = toc;  tic
       catch err
           errors.(NameStr) = getReport(err);
       end
       close all
           time = [time, t];
    end
end