
function Thickness = ImageThicknessWob(DataFile,ImageFile)
% DataFile = input('What is the name of the data file? :');
% ImageFile = input('What is the name of the image files? :');
%Format = input('What is the format of the image? :');
ImageName = [ImageFile];

    % Read in midline data from MidlineCust
    XF = DataFile(:,1); YF = DataFile(:,2);
    FI = imread(ImageName); Lev = graythresh(FI)*.75; FIb = im2bw(FI, Lev);
    DFi = double(FIb);    % convert image file to double
    imshow(DFi); hold on % show the image
    plot(XF,YF,'b');     % plot the midline
    for j = 2: length(XF)
        % create a new array of X's in order to create a line perpendicular
        % to the midline at the jth point
        Xup = XF(j)+50; Xend = XF(j)-50; Xs = Xend:0.05:Xup;
        % calculate the slope of the midline from j-1 to j
        M =(YF(j-1)-YF(j))/(XF(j-1)-XF(j));
        B = YF(j) - XF(j)*(1/(-M)); % calculate B of the perpendicular line
        if abs(M) <= (1e-3)  % if slope is close to 0 make it 0
            M = 0;
        end
        if M == 0            % if the slope is zero, create a vertical line
            perpY = (YF(j)-150):0.05:(YF(j)+149);
            x(1:0.5:length(perpY/4)) = XF(j); Xs = x;
        else                         % if the slope is not zero, calculate
            perpY = (1/(-M))*Xs + B; % set of Y's for perpendicular line
        end
        plot(Xs,perpY,'r');          % plot the perpendicular line
%        plot(Xs,perpY,'r*');   % debug, make sure it's getting enough pts
        big = [];                    % create an empty array to 
        [xx,yy] = size(DFi);         % get size of the image                 
        for p = 1:length(Xs)                   
            if perpY(p) > xx || perpY(p) <= 0.5 % fill with values of the
                big = [big, p];   
            end                                  % points where y is out of
            if Xs(p) > yy || Xs(p) <=0.5         %  the range in the tif
                big = [big, p];
            end        
        end
        Xs(big) = []; perpY(big) = [];        % subtract those points
        Black = [];             
        for k = 1:length(Xs)                  % create an array of points
            if DFi(round(perpY(k)), round(Xs(k))) == 1 % where the perp 
                add = [Xs(k), perpY(k)];      % line passes through a black 
                Black = [Black; add];         % spot presumably the fish
            end
        end
        % plot(Black, 'c');
        % add the thicknesses at each point along the midline to a
        % structure array
        Thickness(j) = sqrt((Black(end,1)-Black(1,1))^2 + ...
            (Black(end,2)-Black(1,2))^2);
    end
    ImageName(end-3:end)= []; ImageName(1:2) = [];
    eval(sprintf('%s=%s',[ImageName,'Thk'],'DVThickness'));
    save([[ImageName,'Thk'],'.mat'],[ImageName,'Thk']);
end