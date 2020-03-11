function [sOut] = imageInfo(struct)
    sOut = struct;
    perc = [0.5,0.6,0.7,0.8,0.9];
    LV = struct.lateralIm;
    DV = struct.dorsalIm;
    len = struct.fishLength;
    %sOut.tailPts = len.*perc;
    %twist = struct.twistPts./len;
    %tail = sOut.tailPts./len;
    
    imshow(DV);
    Dpoints = ginput(2);
    close
    imshow(LV);
    Lpoints = ginput(2);
    
    sOut.dMid = ImageMidlineWob(DV);
    sOut.dMid(1,:) = Dpoints(1,:); sOut.dMid(end,:) = Dpoints(2,:);
    close all
    sOut.lMid = ImageMidlineWob(LV);
    lsigns = diff(sOut.lMid(:,1));
    lsigns = sign(lsigns);
    firstChange = 0;
        for index = 2:length(lsigns)
            if lsigns(index-1) == lsigns(index)
                firstChange = 0;
            else
                firstChange = 1;
                break
            end
        end
    sOut.lMid = sOut.lMid(1:index,:);
    
    sOut.lMid(1,:) = Lpoints(1,:); sOut.lMid(end,:) = Lpoints(2,:);
    close all

    [sOut.dMidRes,Dd,Dfun] = interparc(20,sOut.dMid(:,1),sOut.dMid(:,2),'spline');
    [sOut.lMidRes,Ld,Lfun] = interparc(20,sOut.lMid(:,1),sOut.lMid(:,2),'spline');
    
    [dlength, seglength] = arclength(sOut.dMidRes(:,1),sOut.dMidRes(:,2),'spline');
    [llength, seglength] = arclength(sOut.lMidRes(:,1),sOut.lMidRes(:,2),'spline');
    
    sOut.dImScale = len/dlength;
    sOut.lImScale = len/llength;
    
%     for j = 1:length(twist)
%         Dcordinate = Dfun(twist(j));
%         Lcordinate = Lfun(twist(j));
%         DX(j) = Dcordinate(1);
%         DY(j) = Dcordinate(2);
%         LX(j) = Lcordinate(1);
%         LY(j) = Lcordinate(2);
%     end
%     sOut.dImTwist = [sOut.dMidRes(1,:); 
%                           DX',DY';
%                      sOut.dMidRes(20,:)];
%     sOut.lImTwist = [sOut.lMidRes(1,:);
%                           LX',LY';
%                      sOut.lMidRes(20,:)];
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
%     sOut.dImTail = [sOut.dMidRes(1,:); 
%                           DX',DY';
%                      sOut.dMidRes(20,:)];
%     sOut.lImTail = [sOut.lMidRes(1,:);
%                           LX',LY';
%                      sOut.lMidRes(20,:)];

    DDV  = imageDvals(sOut.dMidRes(:,1), sOut.dMidRes(:,2),DV);
    LDV  = imageDvals(sOut.lMidRes(:,1), sOut.lMidRes(:,2),LV);
%     dTV  = imageDvals(sOut.dImTwist(:,1),sOut.dImTwist(:,2),DV);
%     lTV  = imageDvals(sOut.lImTwist(:,1),sOut.lImTwist(:,2),LV);
%     dTlV = imageDvals(sOut.dImTail(:,1),sOut.dImTail(:,2),DV);
%     lTlV = imageDvals(sOut.lImTail(:,1),sOut.lImTail(:,2),LV);
%     sOut.imDTwist = [dTV',lTV'];
%     sOut.imDTail  = [dTlV',lTlV'];
    sOut.imDScaled   = [(DDV.*sOut.dImScale)', (LDV.*sOut.lImScale)'];
    sOut.imDRaw      = [DDV', LDV'];
    

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

