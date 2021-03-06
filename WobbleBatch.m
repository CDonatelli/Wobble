function [ list, time, errors] = WobbleBatch( file )
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
           Struct = midlineRestructure(eval(list(i).name));
           disp(['Ran MidRes ', num2str(i), ' out of ', num2str(length(list))]);
           save([NameStr,'Proc.mat'], 'Struct');
%        catch
%            warning(['midlineRestructure did not run for file #' num2str(i)])
%            errors.(eval(list(i).name)) = getReport(MEexception.last);
%        end
           t = toc;  tic
%        try
           Struct = VidInfo(Struct);
           disp(['Ran VidInfo ', num2str(i), ' out of ', num2str(length(list))]);
           save([NameStr,'Proc.mat'], 'Struct','-append');
%        catch
%            warning(['VidInfo did not run for file #' num2str(i)])
%            errors.(eval(list(i).name)) = getReport(MEexception.last);
%        end
           t = [t;toc];  tic
%        try
           Struct = wobbleMax(Struct);
           disp(['Ran WobMax ', num2str(i), ' out of ', num2str(length(list))]);
           t = [t;toc];
           Struct.RunTime = t;
           save([NameStr,'Proc.mat'], 'Struct','-append');
%        catch
%            warning(['wobbleMax did not run for file #' num2str(i)])
%            errors.(eval(list(i).name)) = getReport(MEexception.last);
%        end
           
       catch err
           errors.(NameStr) = getReport(err);
       end
       close all
           time = [time, t];
    end

end

