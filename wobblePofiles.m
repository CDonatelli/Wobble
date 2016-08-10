function [medianH,medianW,Names,T] = wobblePofiles(order)
    list = dir('*.mat');
    Names = [];
    height = [];
    width = [];
    for i = 1:length(list)
        NameStr = list(i).name;
        Struct = load(NameStr);
        Struct = Struct.Struct;
        BL = Struct.fishLength;
        Scale = Struct.ImScale;
        height = [height; (Struct.imD(:,2)*Scale/BL)'];
        width = [width; (Struct.imD(:,1)*Scale/BL)'];
        Names = [Names; NameStr(1:6)];
    end
     Names = cellstr(Names);
    T = table(Names, ...
        height,...
        width);
%     writetable(T,csvName);
    [m,n] = size(order);
    medianH = [];
    medianW = [];
    for i = 1:m
        medianH = [medianH; median(height(order(i,1):order(i,2),:))];
        medianW = [medianW; median(width(order(i,1):order(i,2),:))];
    end
end