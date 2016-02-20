function [ list ] = WobbleBatch( file )
    load(file)
    clear file
    list = whos;
    % a = imageInfo(eval(a(1).name))
    for i = 1:length(list)
       list(i).name = midlineRestructure(eval(list(i).name));
       disp(['MidRes ', num2str(i), ' out of ', num2str(length(list))]);
       list(i).name = VidInfo(eval(list(i).name));
       disp(['VidInfo ', num2str(i), ' out of ', num2str(length(list))]);
       list(i).name = wobbleMax(eval(list(i).name));
       disp(['WobMax ', num2str(i), ' out of ', num2str(length(list))]);
    end

end

