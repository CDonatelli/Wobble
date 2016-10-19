function [] = wobblePofiles(colors)
    list = dir('*.mat');
    Names = [];
    height = [];
    width = [];
    for i = 2:length(list)
        NameStr = list(i).name;
        Struct = load(NameStr);
        Struct = Struct.Struct;
        BL = Struct.fishLength;
        Scale = Struct.ImScale;
        height = [height; (Struct.imD(:,2)*Scale/BL)'];
        width = [width; (Struct.imD(:,1)*Scale/BL)'];
        Names = [Names; NameStr(1:6)];
    end
%      Names = cellstr(Names);
    T = table(Names, ...
        height,...
        width);
%      writetable(T,csvName);
    medianH = [];
    medianW = [];
    order = [31, 50; 118,142; 1,30; 74,98; 52,73; 99,117];
    for i = 1:6
        medianH = [medianH; median(height(order(i,1):order(i,2),:))];
        medianW = [medianW; median(width(order(i,1):order(i,2),:))];
    end
    
    figure
    hold on
    pos = linspace(0,1,20);
    for i = 1:6
        plot(pos(2:20),smooth(medianH(i,2:end)), 'Color', colors(i,:), ...
            'LineWidth', 3);
        xlabel('Position (BL)')
        ylabel('Height (BL)')
        hold on
    end
        
    figure
    hold on
    for i = 1:6
        plot(pos(2:20),smooth(medianW(i,2:end)), 'Color', colors(i,:),...
            'LineWidth', 3);
        xlabel('Position (BL)')
        ylabel('Width (BL)')
        hold on
    end
        
end