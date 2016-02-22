function [ list, time, errors] = WobbleBatch( file )
    load(file)
    clear file
    list = whos;
    time = [];
    % a = imageInfo(eval(a(1).name))
    for i = 1:length(list)
           t = [];  tic
       try
           list(i).name = midlineRestructure(eval(list(i).name));
           disp(['Ran MidRes ', num2str(i), ' out of ', num2str(length(list))]);
       catch
           warning(['midlineRestructure did not run for file #' num2str(i)])
           errors.(eval(list(i).name)) = getReport(MEexception.last);
       end
           t = toc;  tic
       try
           list(i).name = VidInfo(list(i).name);
           disp(['Ran VidInfo ', num2str(i), ' out of ', num2str(length(list))]);
       catch
           warning(['VidInfo did not run for file #' num2str(i)])
           errors.(eval(list(i).name)) = getReport(MEexception.last);
       end
           t = [t;toc];  tic
       try
           list(i).name = wobbleMax(list(i).name);
           disp(['Ran WobMax ', num2str(i), ' out of ', num2str(length(list))]);
       catch
           warning(['wobbleMax did not run for file #' num2str(i)])
           errors.(eval(list(i).name)) = getReport(MEexception.last);
       end
           t = [t;toc];
       close all
           time = [time, t];
    end

end

