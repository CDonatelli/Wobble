function [nosePoints] = clickNose(video)

    SV = VideoReader(video);
    FrNum = SV.NumberOfFrames;

    for i = 1:FrNum
        im = read(SV, i);
        imshow(im);
        [x y] = ginput(1);
        nosePoints(i,:) = [x y];
    end

end