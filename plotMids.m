function [] = plotMids(struct,color)
    for Index = 1:size(struct,2)
        plot(struct(Index).MidLine(:,1),struct(Index).MidLine(:,2),...
            ['-',color]);
        hold on
    end
end