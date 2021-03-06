function [Struct] = imageInfoMod(fileName)
    
    Struct = fileName;
    %Struct = Struct.(fileName(1:end-4));
    
%     disp('Select your color lateral view');
%     [cLV] = uigetfile({'*.jpg';'*.png';'*.bmp'});
%     cLateral = imread(cLV);
%     Struct.cLateral = cLateral;
%     
%     disp('Select your color dorsal view');
%     [cDV] = uigetfile({'*.jpg';'*.png';'*.bmp'});
%     cDorsal= imread(cDV);
%     Struct.cDorsal = cDorsal;
%     
%     disp('Select your BW lateral view');
%     [bwLV] = uigetfile({'*.jpg';'*.png';'*.bmp'});
%     bwLateral = imread(bwLV);
%     Struct.bwLateral = bwLateral;
%     
%     disp('Select your BW dorsal view');
%     [bwDV] = uigetfile({'*.jpg';'*.png';'*.bmp'});
%     bwDorsal= imread(bwDV);
%     Struct.bwDorsal = bwDorsal;
    
    bwLateral = Struct.lateralIm;
    bwDorsal = Struct.dorsalIm;
    
    disp('Set lateral scale');
    imshow(bwLateral);
    [x,y] = getpts;
    close
    latScale = pdist([x,y],'euclidean')/10; %pixles/mm
    Struct.latScale = latScale;
    
    disp('Set dorsal scale');
    imshow(bwDorsal);
    [x,y] = getpts;
    close
    dorScale = pdist([x,y],'euclidean')/10; %pixles/mm
    Struct.dorScale = dorScale;

    perc = [0.5,0.6,0.7,0.8,0.9];
    LV = Struct.lateralIm;
    DV = Struct.dorsalIm;
    
    imshow(DV);
    disp('Select nose and tail');
    Dpoints = ginput(2);
    close
    imshow(LV);
    ('Select nose and tail');
    Lpoints = ginput(2);
    
    Struct.dMid = ImageMidlineCol(DV);
    Struct.dMid(1,:) = Dpoints(1,:); Struct.dMid(end,:) = Dpoints(2,:);
    close all
    Struct.lMid = ImageMidlineCol(LV);
    if any(diff(Struct.lMid(:,1)) <= 0)
        screwed = false; over = [];
        for i = 2:length(Struct.lMid)
            if Struct.lMid(i-1,1) > Struct.lMid(i,1)
                screwed = true;
                over = i-1;
                break
            else
                screwed = false;
            end
        end
        Struct.lMid(over:end,:) = [];
    end
    Struct.lMid(1,:) = Lpoints(1,:); Struct.lMid(end,:) = Lpoints(2,:);
    close all

    [Struct.dMidRes,Dd,Dfun] = interparc(20,Struct.dMid(:,1),Struct.dMid(:,2),'spline');
    [Struct.lMidRes,Ld,Lfun] = interparc(20,Struct.lMid(:,1),Struct.lMid(:,2),'linear');
    
    [Struct.fishLength, segLength] = arclength(Struct.lMidRes(:,1),Struct.lMidRes(:,2));
    Struct.fishLength = Struct.fishLength/latScale;
    
    len = Struct.fishLength;
%     Struct.tailPts = len.*perc;
%     twist = Struct.twistPts./len;
%     tail = Struct.tailPts./len;
%     for j = 1:length(twist)
%         Dcordinate = Dfun(twist(j));
%         Lcordinate = Lfun(twist(j));
%         DX(j) = Dcordinate(1);
%         DY(j) = Dcordinate(2);
%         LX(j) = Lcordinate(1);
%         LY(j) = Lcordinate(2);
%     end
%     Struct.dImTwist = [Struct.dMidRes(1,:); 
%                           DX',DY';
%                      Struct.dMidRes(20,:)];
%     Struct.lImTwist = [Struct.lMidRes(1,:);
%                           LX',LY';
%                      Struct.lMidRes(20,:)];
    %redefine as empty just in case length(twist) > length(tail)
%     Dcordinate = []; Lcordinate = [];
%     DX = []; DY = []; LX = []; LY = [];
%     for j = 1:length(tail)
%         Dcordinate = Dfun(tail(j));
%         Lcordinate = Lfun(tail(j));
%         DX(j) = Dcordinate(1);
%         DY(j) = Dcordinate(2);
%         LX(j) = Lcordinate(1);
%         LY(j) = Lcordinate(2);
%     end    
%     Struct.dImTail = [Struct.dMidRes(1,:); 
%                           DX',DY';
%                      Struct.dMidRes(20,:)];
%     Struct.lImTail = [Struct.lMidRes(1,:);
%                           LX',LY';
%                      Struct.lMidRes(20,:)];

    DDV  = imageDvals(Struct.dMidRes(:,1), Struct.dMidRes(:,2),DV);
    LDV  = imageDvals(Struct.lMidRes(:,1), Struct.lMidRes(:,2),LV);
%     dTV  = imageDvals(Struct.dImTwist(:,1),Struct.dImTwist(:,2),DV);
%     lTV  = imageDvals(Struct.lImTwist(:,1),Struct.lImTwist(:,2),LV);
%     dTlV = imageDvals(Struct.dImTail(:,1),Struct.dImTail(:,2),DV);
%     lTlV = imageDvals(Struct.lImTail(:,1),Struct.lImTail(:,2),LV);
%     Struct.imDTwist = [dTV',lTV'];
%     Struct.imDTail  = [dTlV',lTlV'];
    Struct.imD      = [DDV'/dorScale, LDV'/latScale];
    
    save(fileName, 'Struct')
    

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