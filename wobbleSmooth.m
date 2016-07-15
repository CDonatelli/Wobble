function [ Struct ] = wobbleSmooth( Struct )
        
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
        twistPts = size(Struct.twistPts,1);
        scaledLength = length/scale;
        
        % initilize smoothed variables
        tailYs = [];
        tailXs = [];
        twistYs = [];
        twistXs = [];
        tailWobs = [];
        twistWobs = [];
        tailPeaks = [];
        twistPeaks = [];
        tailWobPeaks = [];
        twistWobPeaks = [];
        % note, you can use smooth(X,Y,0.1,'rloess'). it works great!
        % note, rloess for tail position, rlowess for wobble
        
        % create second time array if you didn't find wobble at every frame
        time2 = linspace(0,time(end),size(tailWob,2));
        
        for i = 1:5
            tailYs(i,:) = smooth(time,tailY(i,:),0.1,'rloess');
            tailXs(i,:) = smooth(time,tailX(i,:),0.1,'rloess');
            tailWobs(i,:) = smooth(time2,tailWob(i+1,:),0.1,'rlowess');
        end
        for i = 1:twistPts
            twistYs(i,:) = smooth(time,twistY(i,:),0.1,'rloess');
            twistXs(i,:) = smooth(time,twistX(i,:),0.1,'rloess');
            twistWobs(i,:) = smooth(time2,twistWob(i+1,:),0.1,'rlowess');
        end
        
        stail = linspace(length/2,length,6);
        stail = stail(1:5);
        
        Struct.tailYs = tailYs;
        Struct.twistYs = twistYs;
        Struct.tailXs = tailXs;
        Struct.twistXs = twistXs;
        Struct.tailWobs = tailWobs;
        Struct.twistWobs = twistWobs;
        Struct.stail = stail';
        Struct.stwist = (Struct.twistPts)';
        Struct.time2 = time2;
        
        % note, you can use smooth(X,Y,0.1,'rloess'). it works great!
        % note, rloess for tail position, rlowess for wobble
        

end

