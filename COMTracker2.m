function [Struct] = COMTracker2(video)
    Struct = struct;
    SV = VideoReader(video);
    Struct.vid = video;
    disp('First let''s set the scale.');
    disp('Select two points that are a known distance apart');
    imStart = read(SV,1);
    imshow(imStart);
    setScale = ginput;
    knownDist = input('What is the distance (in mm)? : ');
    pxlDist = pdist(setScale, 'euclidean');
    scale = knownDist/pxlDist; %mm/pxl
    Struct.scale = scale;
    fishLength = input('How long is the fish? (in mm) : ');
    Struct.fishLength = fishLength;
    disp('Please click nose, COM, then tail');
    
    Dur = SV.Duration;
    FrNum = SV.NumberOfFrames;
    for i = 1:FrNum
        im = read(SV, i);
        im = im2double(im);
        imshow(im);
        hold on
        
        nose = ginput(1);
        plot(nose(1), nose(2), 'b+');
        
        COM = ginput(1);
        plot(COM(1), COM(2), 'g+');
       
        tail = ginput(1);
        plot(tail(1), tail(2), 'r+');
        
        Points(i,:) = [nose COM tail];
        
        hold off
    end
        Struct.Points = Points;

    save([video(1:end-4),'.mat'],'Struct')                                    
end