function [Struct] = wobblePhase(Struct)

    tailWob = Struct.tLWob;
    twistWob = Struct.tWob;
    X = Struct.X;
    Y = Struct.Y;
    tailX = Struct.tailPtCordsX;
    tailY = Struct.tailPtCordsY;
    twistX = Struct.twistPtCordsX;
    twistY = Struct.twistPtCordsY;
    time = Struct.t;
    length = Struct.fishLength;
    scale = Struct.VidScale;
    twistPts = size(Struct.twistPts,2);
    scaledLength = length/scale;
    
    % initilize smoothed variables
    tailYs = [];
    twistYs = [];
    tailWobs = [];
    twistWobs = [];
    tailPeaks = [];
    twistPeaks = [];
    tailWobPeaks = [];
    twistWobPeaks = [];
    % note, you can use smooth(X,Y,0.1,'rloess'). it works great!
    % note, rloess for tail position, rlowess for wobble
       
    % create second time array if you didn't find wobble at every frame
    if size(tailWob,1) < size(time,2)
        time2 = linspace(0,time(end),size(tailWob,2));
        
        for i = 1:5
           tailYs(i,:) = smooth(time,tailY(i,:),0.1,'rloess');
           tailWobS(i,:) = smooth(time2,tailWob(i+1,:),0.1,'rlowess');
           
           [p1,k1] = findpeaks(tailYs(i,:),time);
           [p2,k2] = findpeaks(-tailYs(i,:),time);
           p = [p1';p2']; k = [k1';abs(k2')];
           peaks = [k,p]; peaks = sortrows(peaks);
           tailPeaks = [tailPeaks,peaks];
           
           [p,k] = findpeaks(tailWobS(i,:));
           tailWobPeaks = [tailWobPeaks,k,p];
        end
        for i = 1:twistPts
           twistYs(i,:) = smooth(time,twistY(i,:),0.1,'rloess');
           twistWobS(i,:) = smooth(time2,twistWob(i+1,:),0.1,'rlowess');
           
           [p1,k1] = findpeaks(twistYs(i,:),time);
           [p2,k2] = findpeaks(-twistYs(i,:),time);
           p = [p1';p2']; k = [k1';abs(k2')];
           peaks = [k,p]; peaks = sortrows(peaks);
           twistPeaks = [twistPeaks,peaks];
           
           [p,k] = findpeaks(twistWobS(i,:));
           twistWobPeaks = [twistWobPeaks,k',p];
        end
        
        
        
    else
        time2 = time;
    end
    
    Struct.tailYs = tailYs;
    Struct.twistYs = twistYs;
    Struct.tailWobs = tailWobs;
    Struct.twistWobs = twistWobs;
    
    %getting rid of weird values
    % index = find(positionY <=0)
    % timeI = time
    % timeI(index) = [];
    % positionY(index) = [];
    % newPositionY = interp1(timeI, positionY, time)
    % note, you can use smooth(X,Y,0.1,'rloess'). it works great!
    % note, rloess for tail position, rlowess for wobble
    

end