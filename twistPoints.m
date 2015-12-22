function [twistCords] = twistPoints(image, twistPts, length)

    Pic = imread(image);
    h = ones(5,5) / 25; 
    BlurredImage = imfilter(Pic,h);
    Level = graythresh(BlurredImage);           
    FrOut = ~im2bw(BlurredImage,Level);

    imshow(FrOut);
    axis on
    hold on
    pts = ginput(2);
    plot(pts(:,1), pts(:,2), 'g');
    pixles = pdist(pts);
    scale = length/pixles;
    twistPix = twistPts./scale;
    
%     slope = (pts(2,2)-pts(1,2))/(pts(2,1)-pts(1,1));
%     b = pts(1,2)/(slope*pts(1,1));
    xavg = (pts(1,2)+pts(2,2))/2;
    [m,n] = size(twistPix);
    tPix = [];
    for i = 1:m
        tPix(i,:) = [xavg,twistPix(i)+ pts(1,1)];
    end
    hold on
    plot(tPix(:,2), tPix(:,1), 'ro');
    
    twistCords = [tPix, tPix.*scale];
end