function [] = plotMids2(struct,color,BL)
    for Index = 1:size(struct,2)
        plot((struct(Index).MidLine(:,1)/BL),...
             (struct(Index).MidLine(:,2)/BL),...
             ['-',color]);
        hold on
    end
end