function [sOut] = imageInfo(struct)
    sOut = struct;
    %FrNum = Vid.NumberOfFrames;
    LV = struct.lateralIm;
    DV = struct.dorsalIm;
    len = struct.fishLength;
    twist = struct.twistPts./len;
    % Get a rectangle to limit search area to area the fish is swimming in
%     Drect = CropVideo(DV);
%     Lrect = CropVideo(LV);
    % Get the rough levels of the background and of the fish  
    % (assuming background is plain and uniform for now)
%     [DBLev, DFLev] = GetLevels(imcrop(DV,Drect));
%     [LBLev, LFLev] = GetLevels(imcrop(LV,Lrect)); 

%     dMid = FindMidline(DV, Drect, DFLev);
%     lMid = FindMidline(LV, Lrect, LFLev);
    imshow(DV);
    Dpoints = ginput(2);
    close
    imshow(LV);
    Lpoints = ginput(2);
    
    sOut.dMid = ImageMidlineCol(DV);
    sOut.dMid(1,:) = Dpoints(1,:); sOut.dMid(end,:) = Dpoints(2,:);
    close all
    sOut.lMid = ImageMidlineCol(LV);
    if any(diff(sOut.lMid(:,1)) <= 0)
        screwed = false; over = [];
        for i = 2:length(sOut.lMid)
            if sOut.lMid(i-1,1) > sOut.lMid(i,1)
                screwed = true;
                over = i-1;
                break
            else
                screwed = false;
            end
        end
        sOut.lMid(over:end,:) = [];
    end
    sOut.lMid(1,:) = Lpoints(1,:); sOut.lMid(end,:) = Lpoints(2,:);
    close all
%     struct.dMidRes = imageMidlineRestructure(struct);
%     struct.lMidRes = imageMidlineRestructure(struct);
    [sOut.dMidRes,Dd,Dfun] = interparc(20,sOut.dMid(:,1),sOut.dMid(:,2),'spline');
    [sOut.lMidRes,Ld,Lfun] = interparc(20,sOut.lMid(:,1),sOut.lMid(:,2),'spline');
    
    for j = 1:length(twist)
        Dcordinate = Dfun(twist(j));
        Lcordinate = Lfun(twist(j));
        DX(j) = Dcordinate(1);
        DY(j) = Dcordinate(2);
        LX(j) = Lcordinate(1);
        LY(j) = Lcordinate(2);
    end
    sOut.dImTwist = [sOut.dMidRes(1,:); 
                          DX',DY';
                     sOut.dMidRes(20,:)];
    sOut.lImTwist = [sOut.lMidRes(1,:);
                          LX',LY';
                     sOut.lMidRes(20,:)];

    DDV = imageDvals(sOut.dMidRes(:,1), sOut.dMidRes(:,2),DV);
    LDV = imageDvals(sOut.lMidRes(:,1), sOut.lMidRes(:,2),LV);
    dTV = imageDvals(sOut.dImTwist(:,1),sOut.dImTwist(:,2),DV);
    lTV = imageDvals(sOut.lImTwist(:,1),sOut.lImTwist(:,2),LV);
    sOut.imTwistD = [dTV',lTV'];
    sOut.imD = [DDV', LDV'];
    

function midline = FindMidline(im, rect, FishLev)
        %im = read(Vid,i);
        im = imcrop(im,rect);       % only use the section of frame  
        imshow(im);                 % specified by the user in CropVideo 
        hold on
        X=[];
        Y=[];
        if (size(X,1) == 0)                         % 39 in MidlineWob2
            disp('click on the nose of the fish');
            [X Y] = ginput(1);      % get the initial location of the fish
        end
        plot(X,Y,'or');                             % 47 in MidlineWob2 
                                    % show user the point they selected 
        [AngleToNext,D] = cart2pol(X, Y);           % 62 in MidlineWob2
        Nose = FindNose(im, X, Y, AngleToNext+pi, FishLev);
        plot(X,Y,'og');
        
                % set radius for midline finding circle 
        Radius = RadFind(im,X,Y,FishLev);           % 69 in MidlineWob2
    
        [TempCenter(1), TempCenter(2)] = pol2cart(AngleToNext+pi,2*Radius);
        TempCenter(1) = TempCenter(1)+X;
        TempCenter(2) = TempCenter(2)+Y;
        plot(TempCenter(1),TempCenter(2),'og');
        
                % finds circle on clicked point and plots for debug
                % coordinates of circle centered on user point
        FullCircle = GetArc(TempCenter(1),TempCenter(2),3*Radius,0,2*pi);     
        plot(FullCircle(:,1),FullCircle(:,2),'.b');
 
                % 180 degrees of arc centered on the user point
        FullArc = GetArc(TempCenter(1),TempCenter(2),3*Radius,...
            AngleToNext-pi/2,AngleToNext+pi/2);     
                % shows arc crossing fish body posterior to current point 
        plot(FullArc(:,1),FullArc(:,2),'.r');   
                % removes out of bounds values
        FullArc = TrimArc(im,FullArc);              % 86 in MidlineWob2
                % narrow list points to those on the fish
        FishArc = FindFish(im,FullArc,FishLev);     % 87 in MidlineWob2
                % first point of midline is user point
                % Is this necessary? Check it out
        Centers=[X, Y];                             % 89 in MidlineWob2 
                % get the rest of the midline
                                                    % 90 in MidlineWob2 
        Centers = FindMidPoint(im,FishArc,Centers,FishLev);
        
        % auto tracking works better if the next starting point is a bit
        % back from the nose.
        X = Centers(2,1);
        Y = Centers(2,2);
        midline = [X,Y];

function rect = CropVideo(im)
    disp('Select the portion of the frame the fish swims through');
    choice = 0;
    while choice == 0
        imshow(im)
        rect = getrect;
        im2 = imcrop(im,rect);
        imshow(im2)
        choice = input('Does this look right? :');
    end
    
function [Back, Obj] = GetLevels(im)
    OBlu = []; BBlu = [];
    imshow(im); hold on
    [Xo Yo] = getpts();
    plot(Xo,Yo,'bo');
    hold on
    for i = 1:length(Xo)
        O = impixel(im,Xo(i),Yo(i));
        OBlu = [OBlu,O(3)];
    end
    [Xb Yb] = getpts(1);
    plot(Xb,Yb,'ro');
    hold on
    for i = 1:length(Xb)
        B = impixel(im,Xb(i),Yb(i));
        BBlu = [BBlu,B(3)];
    end
    
    MaxObj = max(OBlu); MinObj = min(OBlu);
    MaxBac = max(BBlu); MinBac = min(BBlu);
    
    % If the levels are overlapping, find the average
    % For now assuming that the background and fish are pretty different
    % so the only overlapping levels considered are as follows:
    % MaxFish > MaxBackground > MinFish > MinBackground
    % MaxBackground > MaxFish > MinBackground > MinFish
    % Looking to create an order that looks like one of the following:
    % MaxFish > MinFish > MaxBackground > MinBackground
    % MaxBackground > MinBackground > MaxFish > MinFish
    
    if MaxObj >= MinBac 
        if MaxBac >= MinObj 
            Avg = round(mean([MaxBac MinObj]));
            MinObj = Avg;
            MaxBac = Avg-1;
        end
    end
    if MaxBac >= MinObj 
        if MaxObj >= MinBac   
            Avg = round(mean([MaxObj MinBac]));
            MacObj = Avg;
            MinBac = Avg+1;
        end
    end
    hold off
    Back = [MaxBac, MinBac]; Obj = [MaxObj, MinObj];
    
function Nose = FindNose(Frame, X, Y, Angle, level)
    [XTemp,YTemp] = pol2cart(Angle,1);
    while Frame(round(Y),round(X)) >= level(1) && ...
          Frame(round(Y),round(X)) <= level(2)
        X = X+XTemp;
        Y = Y+YTemp;
    end
    Nose = [X,Y]; 

function R = RadFind(Image,X,Y, level)
        R = 25;
        changes = 0;
        [m,n] = size(Image);
        while changes < 2
            circ = GetArc(X,Y,R,0,2*pi);
            del = [];
            for i = 1:length(circ)
                B = impixel(Image,circ(i,1),circ(i,2));
                if circ(i,1)>n || circ(i,2)>m || B(3)<=level(2) || B(3)>=level(1)
                    del = [del,i];
                end
            end
            circ(del,:) = []; 
            for i = 1:length(circ)
                vals(i) = Image(circ(i,2), circ(i,1));
            end
            for i = 1:length(vals)-1
                if vals(i) ~= vals(i+1)
                    changes = changes +1;
                end
            end
            %plot(circ(:,1), circ(:,2)); hold on
            R = R+5;
        end

function Arc = GetArc(X,Y,R,PhiStart,PhiFinish)
Arc=[];
for Theta = PhiStart:2*pi/720:PhiFinish    %make a reading each degree                                            
    [DX, DY] = pol2cart(Theta,R);   %get the cartesian coordinates of the polar expression
    Arc = [Arc;DX DY];      %save the coordinates in the list
end

Arc(:,1) = (Arc(:,1) + X);  %add the center X value
Arc(:,2) = (Arc(:,2) + Y);  %add the center Y value
Arc=floor(Arc); %round everything down
NewArc = [Arc(1,:)];
for i = 2:size(Arc,1)
    if Arc(i,1) ~= Arc(i-1,1) || Arc(i,2) ~= Arc(i-1,2)
        NewArc=[NewArc; Arc(i,1) Arc(i,2)];
    end
end
Arc = NewArc;        

function Arc = TrimArc(Image, Arc)
    Arc(Arc(:,1)>size(Image,2)-1,1) = size(Image,2)-1;
    Arc(Arc(:,2)>size(Image,1)-1,2) = size(Image,1)-1;
    Arc(Arc(:,1)<0,1) = 0;
    Arc(Arc(:,2)<0,1) = 0;
    
function Fish = FindFish(frame,Points, level)
    [m,n] = size(frame);
    del = [];
    for i = 1:length(Points)
        B = impixel(frame,Points(i,1),Points(i,2));
        if Points(i,1)>n || Points(i,2)>m || B(3)<level(2) || B(3)>level(1)
            del = [del,i];
        end
    end
    Points(del,:) = [];
    Fish =[];
    for i = 1:size(Points,1)
        X=Points(i,1);
        Y=Points(i,2);
        B = impixel(frame,X,Y);
        if B(3)>level(2) && B(3)<level(1)   % check if x,y coordinate is fish 
            Fish=[Fish;X Y];        % add the coordinate to the list
        end
    end

function Centers = FindMidPoint(FishImage,FishArc,Centers,level)
if size(FishArc,1)>1
    MidPoint = FishArc(floor(size(FishArc,1)/2),:);  %the midpoint
    Centers = [Centers;MidPoint];   %add the midpoint to the list

    NewRadius = RadFind(FishImage, MidPoint(1), MidPoint(2),level);
    NewRadius = NewRadius + 10;
    %get the arc specified by the new midpoint and radius. The hemicircle
    %should start at right angles to a line between the two previous
    %centers
    CenterAngle = cart2pol(Centers(end,1)-Centers(end-1,1),Centers(end,2)-Centers(end-1,2));
    hold on
    %As in th initail step take a point along the line between the two
    %recent centers, 2* radius away from the tail
    %first find the temporary circle center
    [TempCenter(1), TempCenter(2)] = pol2cart(CenterAngle+pi,2*NewRadius);
    TempCenter(1) = TempCenter(1)+MidPoint(1);
    TempCenter(2) = TempCenter(2)+MidPoint(2);
    %plot(TempCenter(1),TempCenter(2),'og');
    hold on
    RawArc = GetArc(TempCenter(1),TempCenter(2),NewRadius*3,CenterAngle-pi/2, CenterAngle+pi/2);
    RawArc = TrimArc(FishImage,RawArc);
    FishArc = FindFish(FishImage,RawArc, level);   %find the intersection of the arc and the image
    plot(MidPoint(:,1),MidPoint(:,2),'.g'); %plot a green circle on the midline
    %plot(RawArc(:,1),RawArc(:,2),'r'); %debug to show the arc
    Centers = FindMidPoint(FishImage,FishArc,Centers, level);   %recursively look for midpoints
end

