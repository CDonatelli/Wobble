function [ list, time] = WobbleBatch( file )
    load(file)
    clear file
    list = whos;
    time = [];
    % a = imageInfo(eval(a(1).name))
    for i = 1:length(list)
       t = [];
       tic
       list(i).name = midlineRestructure(eval(list(i).name));
       disp(['MidRes ', num2str(i), ' out of ', num2str(length(list))]);
       t = toc;
       tic
       list(i).name = VidInfo(list(i).name);
       disp(['VidInfo ', num2str(i), ' out of ', num2str(length(list))]);
       t = [t;toc];
       tic
       list(i).name = wobbleMax(list(i).name);
       disp(['WobMax ', num2str(i), ' out of ', num2str(length(list))]);
       t = [t;toc];
       close all
       time = [time, t];
    end

end

