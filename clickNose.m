function [Points] = clickNose(video)
    disp('Please click the nose first, then the tail');
    SV = VideoReader(video);
    FrNum = SV.NumberOfFrames;
    for i = 1:FrNum
        im = read(SV, i);
        im = im2double(im);
        imshow(im);
        hold on
        nose = ginput(1);
        plot(nose(1), nose(2), 'b+');
        tail = ginput(1);
        plot(tail(1), tail(2), 'r+');
        Points(i,:) = [nose(1) nose(2) tail(1) tail(2)];
    end
    hold off
end