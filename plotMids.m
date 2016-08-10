function [] = plotMids(struct,color)
    BL = struct.fishLength;
    for Index = 1:5:size(struct.midLines,2)
        plot(struct.midLines(Index).MidLine(:,1)/BL, ...
             struct.midLines(Index).MidLine(:,2)/BL,...
             color);
        hold on
    end
end