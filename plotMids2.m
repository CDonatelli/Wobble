function [] = plotMids2(struct)
    num = length(struct.midLines);
    col = colormap(copper(num));
    for i = 1:num
        plot((struct.midLines(i).MidLine(:,1)),...
             (struct.midLines(i).MidLine(:,2)),...
             'color',col(i,:),'linewidth',2);
        hold on
    end
end