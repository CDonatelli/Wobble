function Lines = MidlineCust(FileNamePrefix)
%   finds the midline of a fish swimming across the field of view.  Counts
%   on good contrast and low background noise. Dark fish on light
%   background is required
%       APS 2006
%   The prefix for the image stack is the input arguement.  Assuming the 
%   order is numerical then all the files will be
%   processed in correct order. Otherwise code to
%   sort filenames will be needed. Data is output in a structure with
%   midline points and frame #'s
%still to do:
%2. stats on waves
%

disp('Please select the directory containing your tif files');
pause(0.5);
% go to the directory containing the .avi file
directory = uigetdir;
cd(directory);

FileNameList = dir([FileNamePrefix '*.tif']);   %assume tif files
Lines.Frame = [];
Lines.MidLine = [];
X=[];
Y=[];

for Index = 1:size(FileNameList,1)
    RawImage = imread(FileNameList(Index).name);    %get the first image to allow user to click the fish    
    BinaryImage = ProcessImage(RawImage);       %blur the image, threshold and invert
    LabelImage = bwlabeln(BinaryImage,4);       %label the image to use image props          
    imshow(BinaryImage);
    ImageStats = regionprops(LabelImage,'all');   %get stats on the labelled image

    %if this is the first frame then get teh nose, otherwise use teh front
    %point from the last image as teh temporary nose.
    if (size(X,1) == 0 || BinaryImage(round(Y),round(X)) == 0)
        [X Y] = ginput(1);  %get the location of the fish
    end
    
    FishRegion = LabelImage(round(Y),round(X)); %get the region number of the fish
    FishImage = BinaryImage;%.*(LabelImage==FishRegion);  %kill all the rest of the binary image
    imshow(FishImage)       %show just the fish to make sure all is well
    hold on;
%     plot(X,Y,'or'); %show the dot the user clicked
    
    %figure out which way the rest of the fish lies.
    %going to assume it is in the direction of the centroid from the point
    %on the head.  Setting that general direction establishes a polarity
    %for the midline search to proceed down the animal rather than from the
    %head to the nose.
    XTemp=ImageStats(FishRegion).Centroid(1)-X;
    YTemp=ImageStats(FishRegion).Centroid(2)-Y;
    [AngleToNext,D] = cart2pol(XTemp, YTemp);
    
    %use teh general direction of teh rest of the body to find the 'nose'.
    %for ease this will be the point furthest from the user clicked point
    %in the opposite direction from the centroid.
    
    Nose = FindNose(FishImage, X, Y, AngleToNext+pi);
    X=Nose(1);
    Y=Nose(2);
%     plot(X,Y,'og');
    %set the radius for the midline finding circle 
    % this function was written by Cassandra Donatelli (2014) and grows
    % circle until white space is interrupted.
    Radius = RadFind(BinaryImage,X,Y);   
    
    %find a center for the drawn circle that is 2*Radius in the opposite
    %direction from the centroid
    [TempCenter(1), TempCenter(2)] = pol2cart(AngleToNext+pi,2*Radius);
    TempCenter(1) = TempCenter(1)+X;
    TempCenter(2) = TempCenter(2)+Y;
%     plot(TempCenter(1),TempCenter(2),'og');
    
    %this finds a circle on the clicked point and plots it for debug
    FullCircle = GetArc(TempCenter(1),TempCenter(2),3*Radius,0,2*pi);     %coordinates of a circle centered on the user point
    plot(FullCircle(:,1),FullCircle(:,2),'.b');     %debug code
    hold on
    FullArc = GetArc(TempCenter(1),TempCenter(2),3*Radius,AngleToNext-pi/2,AngleToNext+pi/2);     %180 degrees of arc centered on the user point
    plot(FullArc(:,1),FullArc(:,2),'.r');   %shows arc that crosses fish body posterior to current point 
    
    FullArc = TrimArc(FishImage,FullArc); % removes out of bounds values
    FishArc = FindWhite(FishImage,FullArc);  %narrow the list points to those on the fish

    Centers=[X, Y];     %first point of midline is user point
    Centers = FindMidPoint(FishImage,FishArc,Centers);    %get the rest of the midline
    
    %the auto tracking works better if the next starting point is a bit
    %back from the nose.
    X = Centers(2,1);
    Y = Centers(2,2);
    
    Lines(Index).Frame=Index;       %save data in the output structure
    Lines(Index).MidLine=Centers;
    hold off    %allow the image to be redrawn
end

close   %close the image 
hold on %see multiple traces
%output = fopen([FileNamePrefix,'MidlineData.txt'], 'w');
for Index = 1:size(Lines,2)
    plot(Lines(Index).MidLine(:,1),Lines(Index).MidLine(:,2),'-k');
    %fprintf(output, '%f %f\n',
end
save([FileNamePrefix, 'Mds'], 'Lines');

%this finds a radius of a circle centered on a point that overlaps both
%sides of the fish. written by Cassandra Donatelli 2014

function R = RadFind(Image,X,Y)
        R = 5;
        changes = 0;
        [m,n] = size(Image);
        while changes < 2
            circ = GetArc(X,Y,R,0,2*pi);
            del = [];
            for i = 1:length(circ)
                if circ(i,1) > n || circ(i,1) <=0 || circ(i,2) > m ...
                        || circ(i,2) <=0
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
                else changes = changes;
                end
            end
            %plot(circ(:,1), circ(:,2)); hold on
            R = R+5;
        end
        
%returns the list of points in an arc centered at X,Y of Radius R. A 2014
%revision to this code removes the duplications that arise from the
%floor step.

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

%returns list of points where the binary image equals 1
function White = FindWhite(Frame,Points)
[m,n] = size(Frame);
del = [];
for i = 1:length(Points)
    if Points(i,1) > n || Points(i,1) <= 0 || Points(i,2) > m ...
            || Points(i,2) <= 0
        del = [del,i];
    end
end
Points(del,:) = [];
White =[];
for Index = 1:size(Points,1)
    X=Points(Index,1);  %get the x and y values of the point
    Y=Points(Index,2);
    if Frame(Y,X)==1    %check if the x,y coordinate is white 
        White=[White;X Y];  %add the coordinate to the list
%         plot(X,Y,'ro');
    end
end
    
%Takes an arc through the fish, calculates the midpoint then sets a radius
%for a circle and cuts another arc. This works recursively getting a new
%arc over and over again until it runs out of fish. 
function Centers = FindMidPoint(FishImage,FishArc,Centers)
if size(FishArc,1)>1
    MidPoint = FishArc(floor(size(FishArc,1)/2),:);  %the midpoint
    Centers = [Centers;MidPoint];   %add the midpoint to the list

    NewRadius = RadFind(FishImage, MidPoint(1), MidPoint(2));

    %get the arc specified by the new midpoint and radius. The hemicircle
    %should start at right angles to a line between the two previous
    %centers
    CenterAngle = cart2pol(Centers(end,1)-Centers(end-1,1),Centers(end,2)-Centers(end-1,2));
    imshow(FishImage)
    %As in th initail step take a point along the line between the two
    %recent centers, 2* radius away from the tail
    %first find the temporary circle center
    [TempCenter(1), TempCenter(2)] = pol2cart(CenterAngle+pi,2*NewRadius);
    TempCenter(1) = TempCenter(1)+MidPoint(1);
    TempCenter(2) = TempCenter(2)+MidPoint(2);
    plot(TempCenter(1),TempCenter(2),'og');
    hold on
    RawArc = GetArc(TempCenter(1),TempCenter(2),NewRadius*3,CenterAngle-pi/2, CenterAngle+pi/2);
    RawArc = TrimArc(FishImage,RawArc);
    FishArc = FindWhite(FishImage,RawArc);   %find the intersection of the arc and the image
    plot(MidPoint(:,1),MidPoint(:,2),'.g'); %plot a green circle on the midline
    plot(RawArc(:,1),RawArc(:,2),'r'); %debug to show the arc
    Centers = FindMidPoint(FishImage,FishArc,Centers);   %recursively look for midpoints
end

% blur and crop the image then invert and binary it
function FrameOut = ProcessImage(Frame)
h = ones(5,5) / 25;     %blur the image to kill line artifacts
BlurredImage = imfilter(Frame,h);
%CroppedImage = double(BlurredImage);%(65:405,80:660); %this removes the borders from the images
                                                % assumes motionscope frame
Level = graythresh(CroppedImage)*.75;           %set threshold a little darker than the auto computed one
FrameOut = ~im2bw(CroppedImage,Level);       %make image binary and invert it so fish is white
  
%this makes sure that none of the values in an arc point to locations that
%can't exist in the image.
function Arc = TrimArc(Image, Arc)
    Arc(Arc(:,1)>size(Image,2)-1,1) = size(Image,2)-1;
    Arc(Arc(:,2)>size(Image,1)-1,2) = size(Image,1)-1;
    Arc(Arc(:,1)<0,1) = 0;
    Arc(Arc(:,2)<0,1) = 0;
       
%find the white point furthest from the point clicked on by the user in the direction away from the centroid    
function Nose = FindNose(Frame, X, Y, Angle);
    [XTemp,YTemp] = pol2cart(Angle,1);
    while ~Frame(round(Y),round(X))==0
        X = X+XTemp;
        Y = Y+YTemp;
    end
    Nose = [X,Y];    
    

    
        
        


    
