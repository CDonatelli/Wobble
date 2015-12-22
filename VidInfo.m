function sOut = VidInfo(struct)
    sOut = struct;
    % dValues,wobble,tDvals,tWob
    disp('Please select the directory holding your video.');
    direct = uigetdir;
    cd(direct);
    Vid = VideoReader(struct.vid);
    FrNum = Vid.NumberOfFrames;
    FrNum = floor(FrNum/5);
    fr = 1;
    for i = 2:FrNum
        fr = [fr;fr(i-1)+5];
    end
    ImStart = read(Vid,1);
    rect = struct.rect;
    BackLev = struct.backLevel;
    FishLev = struct.fishLevel;
    len = struct.fishLength;
    imDvalues = struct.imD;
    imTDvals = struct.imDTwist;
% DataFile = input('What is the name of the structure file? :');
% ImageFile = input('What is the prefix of the image files? :');
% Format = input('What is the format of the image? :');
% FileNameList = dir([ImageFile,'*.tif']);
% PicNames = cell(length(FileNameList),1); % create a cell array                        
% for t = 1:length(FileNameList);          % put names into cell array
%     PicNames{t}= FileNameList(t).name;
% end
    sOut.dValues = [];
    X = struct.X; 
    Y = struct.Y;
    level = FishLev;
    twistPts = struct.twistPts;
    twistX = struct.twistPtCordsX;
    twistY = struct.twistPtCordsY;
    sOut.dValues = [];
    sOut.wobble = [];
    sOut.tDvals  = [];   
    sOut.tWob = [];
    % getting the scale using body length
    [m,n] = size(X);
    arclen = [];
    for i = 1:n
        arclen = [arclen; arclength(X(:,i), Y(:,i))];
    end
    VidScale = len/mean(arclen);
    ImScale = len/mean([arclength(struct.dMid(:,1),struct.dMid(:,2)),...
                        arclength(struct.lMid(:,1),struct.lMid(:,2))]);
    sOut.ImScale = ImScale; sOut.VidScale = VidScale;
    imDvalues = imDvalues.*ImScale;
    imTDvals = imTDvals.*ImScale;
    for i = 1:length(fr)
        disp(['frame = ',num2str(fr(i))]);
        % Thickness(i).Frame = DataFile(i).Frame;
        XF = X(:,fr(i)); YF = Y(:,fr(i));
        Xt = twistX(:,fr(i)); Yt = twistY(:,fr(i));
        Xt = [XF(1,:); Xt; XF(end,:)];
        Yt = [YF(1,:); Yt; YF(end,:)]; 
        frame = read(Vid,fr(i));
        frame = imcrop(frame,rect);
        imshow(frame); hold on  % show the image
%         plot(XF,YF,'b');        % plot the midline
%         plot(Xt,Yt,'ro');       % plot the twist points
%            [Ds Ws] = findDvalues(XF,YF,frame,level, imDvalues);
        [TDs, TWs] = findDvalues(Xt,Yt,frame,level,imTDvals,VidScale);
%         sOut.dValues = [sOut.dValues, Ds]; 
%         sOut.wobble = [sOut.wobble, Ws];
        sOut.tDvals  = [sOut.tDvals, TDs];   
        sOut.tWob = [sOut.tWob, TWs];
    end
    
function [dValues,wobble] = findDvalues(XF,YF,frame,level,imDvalues,scale)
    dValues = [0];
    wobble = [0];
    imshow(frame); hold on
    plot(XF,YF,'ro');
    for j = 2:length(XF)
        disp(['j = ',num2str(j)]);
        % create a new array of X's in order to create a line
        % perpendicular to the midline at the jth point
        Xup = XF(j)+25; Xend = XF(j)-25; Xs = Xend:0.25:Xup;
        % calculate the slope of the midline from j-1 to j
        M =(YF(j-1)-YF(j))/(XF(j-1)-XF(j));
        B = YF(j) - XF(j)*(1/(-M)); % calculate B of perpendicular line
        if abs(M) <= (0.1)          % if slope is close to 0 make it 0
            M = 0;
        end
        if M == 0            % if slope is zero, create a vertical line
            perpY = (YF(j)-50):0.2:(YF(j)+49);
            x(1:0.5:length(perpY/4)) = XF(j); Xs = x;
        else                         % if slope is not zero, calculate
            perpY = (1/(-M))*Xs + B; % Y's for perpendicular line
        end
        plot(Xs,perpY,'r');          % plot the perpendicular line
        % -->   plot(Xs,perpY,'r*'); % debug, make sure it's getting enough pts
        big = [];                    % create an empty array to
        [xx,yy] = size(frame);         % get size of the image
        for p = 1:length(Xs)
            if perpY(p) > xx || perpY(p) <= 0.5 % fill with values of the
                big = [big, p];
            end                              % points where y is out of
            if Xs(p) > yy || Xs(p) <=0.5     %  the range in the tif
                big = [big, p];
            end
        end
        Xs(big) = []; perpY(big) = [];        % subtract those points

        Fish = [];
        for k = 1:length(Xs)
            Blev = impixel(frame,Xs(k),perpY(k));
            if Blev(3)>level(2) && Blev(3)<level(1) % is this pt on the fish?
                add = [Xs(k),perpY(k)];      % line passes through a white 
                Fish = [Fish; add];             % add pt to list
            end
        end
        if isempty(Fish) == 0
            plot(Fish(:,1), Fish(:,2), 'c');
            d = sqrt((Fish(end,1)-Fish(1,1))^2 ... 
                    +(Fish(end,2)-Fish(1,2))^2) * scale;
            w =       (d - imDvalues(j,1))/...
                 (imDvalues(j,2) - imDvalues(j,1));
        else
            d = 0;
            w = 0;
        end
        dValues = [dValues;d];
        wobble = [wobble;w];
        % add the thicknesses at each point along the midline to a
        % structure array

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