function Centers = ImageMidlineWob(View)
%   View = input('Please enter the name of the image view. :');
%   DVin = imread(View);
    DVin = View;
    BinaryImage = ProcessImage(DVin);
    LabelImage = bwlabeln(BinaryImage,4);
    imshow(BinaryImage);
    hold on
    ImageStats = regionprops(LabelImage,'all');
    [X, Y] = ginput(1);
    plot(X,Y,'or');
    FishRegion = LabelImage(round(Y),round(X));
    
    XTemp=ImageStats(FishRegion).Centroid(1)-X;
    YTemp=ImageStats(FishRegion).Centroid(2)-Y;
    [AngleToNext,D] = cart2pol(XTemp, YTemp);
    
    Radius = RadFind(BinaryImage,X,Y);
    
    %find a center for the drawn circle that is 2*Radius in the opposite
    %direction from the centroid
    [TempCenter(1), TempCenter(2)] = pol2cart(AngleToNext+pi,2*Radius);
    TempCenter(1) = TempCenter(1)+X;
    TempCenter(2) = TempCenter(2)+Y;
    plot(TempCenter(1),TempCenter(2),'og');

    FullArc = GetArc(TempCenter(1),TempCenter(2),3*Radius,AngleToNext-pi/2,AngleToNext+pi/2);     %180 degrees of arc centered on the user point
    plot(FullArc(:,1),FullArc(:,2),'.r');   %shows arc that crosses fish body posterior to current point 
    hold on
    FullArc = TrimArc(BinaryImage,FullArc);     % removes out of bounds values
    FishArc = FindWhite(BinaryImage,FullArc);   % narrow list points to those on fish
    Centers=[X, Y];                             % first point of midline is user point
    Centers = FindMidPoint(BinaryImage,FishArc,Centers);    % get the rest of midline
%    View(end-3:end) = [];                           % delete '.avi' from the filename
%    View(1:2) = [];                                 % delete 'bw' from the filename
%    eval(sprintf('%s=%s',[View,'Mds'],'Centers'));      % rename output
%    save([[View, 'Mds'], '.mat'],[View,'Mds']);         % save midline data

close all


function FrameOut = ProcessImage(Frame)
h = ones(5,5) / 25;     %blur the image to kill line artifacts
BlurredImage = imfilter(Frame,h);
%CroppedImage = double(BlurredImage);%(65:405,80:660); %this removes the borders from the images
                                                % assumes motionscope frame
%Level = graythresh(BlurredImage);           %set threshold a little darker than the auto computed one
FrameOut = im2bw(BlurredImage,0.5);       %make image binary and invert it so fish is white
 
function Centers = FindMidPoint(FishImage,FishArc,Centers)
if size(FishArc,1)>1
    MidPoint = FishArc(floor(size(FishArc,1)/2),:);  %the midpoint
    Centers = [Centers;MidPoint];   %add the midpoint to the list

    NewRadius = RadFind(FishImage, MidPoint(1), MidPoint(2));

    %get the arc specified by the new midpoint and radius. The hemicircle
    %should start at right angles to a line between the two previous
    %centers
    CenterAngle = cart2pol(Centers(end,1)-Centers(end-1,1),Centers(end,2)-Centers(end-1,2));
    
    %As in th initail step take a point along the line between the two
    %recent centers, 2* radius away from the tail
    %first find the temporary circle center
    [TempCenter(1), TempCenter(2)] = pol2cart(CenterAngle+pi,2*NewRadius);
    TempCenter(1) = TempCenter(1)+MidPoint(1);
    TempCenter(2) = TempCenter(2)+MidPoint(2);
%     plot(TempCenter(1),TempCenter(2),'og');

    RawArc = GetArc(TempCenter(1),TempCenter(2),NewRadius*3,CenterAngle-pi/2, CenterAngle+pi/2);
    RawArc = TrimArc(FishImage,RawArc);
    FishArc = FindWhite(FishImage,RawArc);   %find the intersection of the arc and the image
    plot(MidPoint(:,1),MidPoint(:,2),'.g');drawnow; %plot a green circle on the midline
%     plot(RawArc(:,1),RawArc(:,2),'r');drawnow; %debug to show the arc
    Centers = FindMidPoint(FishImage,FishArc,Centers);   %recursively look for midpoints
end

function R = RadFind(Image,X,Y)
        R = 5;
        changes = 0;
        while changes < 2
            circ = GetArc(X,Y,R,0,2*pi);
            [m,n] = size(Image); del = [];
            for h = 1:length(circ)
                if circ(h,1) > n || circ(h,1) <= 0 || circ(h,2) > m ...
                        || circ(h,2) <= 0
                    del = [del,h];
                end
            end
            circ(del,:) = []; %circ(del,2) = [];
            for i = 1:length(circ)
                vals(i) = Image(circ(i,2), circ(i,1));
            end
            for i = 1:length(vals)-1
                if vals(i) ~= vals(i+1)
                    changes = changes +1;
                else changes = changes;
                end
            end
            %plot(circ(:,1), circ(:,2)); hold on
            R = R+5;
        end
        
function Arc = TrimArc(Image, Arc)
    Arc(Arc(:,1)>size(Image,2)-1,1) = size(Image,2)-1;
    Arc(Arc(:,2)>size(Image,1)-1,2) = size(Image,1)-1;
    Arc(Arc(:,1)<0,1) = 0;
    Arc(Arc(:,2)<0,1) = 0;
    
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

function White = FindWhite(Frame,Points)
    White =[];
    [m,n] = size(Frame); del = [];
    for q = 1:length(Points)
        if Points(q,1) > n || Points(q,1) <= 0 || Points(q,2) > m ...
                || Points(q,2) <= 0
            del = [del,q];
        end
    end
    Points(del,:) = [];
    for Index = 1:size(Points,1)
        X=Points(Index,1);  %get the x and y values of the point
        Y=Points(Index,2);
        if Frame(Y,X)==1    %check if the x,y coordinate is white 
            White=[White;X Y];  %add the coordinate to the list
    %         plot(X,Y,'ro');
        end
    end