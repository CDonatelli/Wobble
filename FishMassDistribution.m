function [totalVol, massPerSeg] = FishMassDistribution()

% user input Data
prompt = {  'Fish Length: ',...
            'Segments: ', ...
            'Fish Mass: ',...
            'Excel File Name:'};
dlg_title = 'Fish Info';
num_lines = 1;
defaultans = {'4.215','25','2.12','fishData'};
answer = inputdlg(prompt,dlg_title,num_lines,defaultans);

% convert user input to numbers
fishLength    = str2num(answer{1});
segments      = str2num(answer{2});
fishMass      = str2num(answer{3});
fileName      = [answer{4},'.xls'];

% Image processing
disp('Select your color lateral view');
[fLV] = uigetfile({'*.jpg';'*.png';'*.bmp'});   % User selects lateral view
fishLateralView = imread(fLV);                  % Read in lateral view
bwLV = fishImConvert(fishLateralView);          % convert to black and white

disp('Select your color dorsal view');
[fDV] = uigetfile({'*.jpg';'*.png';'*.bmp'});   % User selects dorsal view
fishDorsalView = imread(fDV);                   % Read in dorsal view
bwDV = fishImConvert(fishDorsalView);           % convert to black and white
close gcf                                       % close images

% Create Segments
figure
imshow(bwDV);
hold on
waitfor(msgbox('Select a few points from nose to tail. Then press ''enter'''));
[userDVx, userDVy] = getpts;
DVx = linspace(min(userDVx), max(userDVx),segments+1);
DVy = interp1(userDVx, userDVy, DVx);
plot(DVx, DVy, 'b*')
pause(1)
close gcf
[DVLength, segLen] = arclength(DVx, DVy);
DVscale = DVLength/fishLength; %(pixels/cm)
fishWidth = ImageThicknessWob(DVx, DVy, bwDV);
fishWidth = fishWidth/DVscale;
close gcf

imshow(bwLV)
hold on
waitfor(msgbox('Select a few points from nose to tail. Then press ''enter'''));
[userLVx, userLVy] = getpts;
LVx = linspace(min(userLVx), max(userLVx),segments+1);
LVy = interp1(userLVx, userLVy, LVx);
plot(LVx, LVy, 'b*')
pause(1)
close gcf
[LVLength, segLen] = arclength(LVx, LVy);
LVscale = LVLength/fishLength; %(pixels/cm)
fishHeight = ImageThicknessWob(LVx, LVy, bwLV);
fishHeight = fishHeight/LVscale;
close gcf

%Find Volume distribution
volumes = zeros(segments,1);
%Length of each segment
segLength = fishLength/segments;
for i = 1:segments
    h1 = fishHeight(i); h2 = fishHeight(i+1);
    w1 = fishWidth(i); w2 = fishWidth (i+1);
    volumes(i) = segLength*(pi/12)*(h1*w1 + h2*w2 + sqrt(h1*h2*w1*w2));
end

totalVol = sum(volumes);
massPerVol = totalVol/fishMass;

masses = volumes.*massPerVol;
lenPerSeg = linspace(1, fishLength, segments)';
massesFilt = smooth(masses,'lowess');
massPerSeg = [lenPerSeg, volumes, masses, massesFilt];
T = table(lenPerSeg,volumes,masses,massesFilt);
writetable(T,fileName)

subplot(2,1,1)
plot(lenPerSeg, masses,'linewidth',3)
set(gca,'LineWidth',2,'fontsize',20, 'box','off')
set(gcf,'color','white');
xlabel('Position along Body (cm)','fontsize',20)
ylabel('Mass (g)','fontsize',20)
title('Mass Along Body (raw)')

subplot(2,1,2)
plot(lenPerSeg, massesFilt,'linewidth',3)
set(gca,'LineWidth',2,'fontsize',20, 'box','off')
set(gcf,'color','white');
xlabel('Position along Body (cm)','fontsize',20)
ylabel('Mass (g)','fontsize',20)
title('Mass Along Body (smoothed)')

end

function bwFish = fishImConvert(fish)
    
    waitfor(msgbox('Please crop the image around the fish'));
    Pic = imcrop(fish);           
    h = ones(5,5) / 25; BlurIm = imfilter(Pic,h);
%     Level = graythresh(BlurIm); 
    Level = 0.5;
    good = 0;
    while good ~= 1
        bwFish = ~im2bw(BlurIm,Level);
        imshow(bwFish);

        choice = questdlg('Does this look OK?', ...
        'Choose One', ...
        'Yes','Too Bright','Too Dark','Too Dark');
        % Handle response
        switch choice
            case 'Yes'
                good = 1;
            case 'Too Bright'
                good = 0;
                Level = Level - 0.05;
            case 'Too Dark'
                good = 0;
                Level = Level + 0.05;
        end
    end
    bwFish = imclearborder(bwFish,4);
    choice = questdlg('Does your image require processing?', ...
        'ie are there black spots in the middle?', ...
        'Yes','No','No');
    % Handle response
    switch choice
        case 'Yes'
            bwFish = fixSpots(bwFish);
        case 'No'
            bwFish = bwFish;
    end


end

function bwFish = fixSpots(fish)

    waitfor(msgbox('Create a polygon around the regions with spots'));
    fishMask = roipoly(fish);
    fish(fishMask == 1) = 1;
    bwFish = fish;
    imshow(bwFish);
end

function Thickness = ImageThicknessWob(LineX, LineY, ImageFile)

    % Read in midline data
    XF = LineX; YF = LineY;
    [xx,yy] = size(ImageFile);         % get size of the image  
    imshow(ImageFile); hold on % show the image
    plot(XF,YF,'b');     % plot the midline
    for j = 2: length(XF)
        % calculate the slope of the midline from j-1 to j
        M =(YF(j-1)-YF(j))/(XF(j-1)-XF(j));
        if M == 0
            perpY = linspace(1,xx,(2*xx));
            Xs = repmat(XF(j),1,(2*xx));
        else
            B = YF(j) - XF(j)*(1/(-M)); % calculate B of the perpendicular line
            xlower = (1-B)/(1/-M);
            xupper = (xx-B)/(1/-M);
            Xs = linspace(xupper,xlower,2*xx);
            perpY = (1/(-M))*Xs + B;
        end
        plot(Xs,perpY,'g');          % plot the perpendicular line               
        Black = [];
        for k = 1:length(Xs)                  % create an array of points
            if ImageFile(round(perpY(k)), round(Xs(k))) == 1 % where the perp 
                add = [Xs(k), perpY(k)];      % line passes through a black 
                Black = [Black; add];         % spot presumably the fish
            end
        end
        Thickness(j) = sqrt((Black(end,1)-Black(1,1))^2 + ...
            (Black(end,2)-Black(1,2))^2);
        plot(Black(:,1), Black(:,2),'r.')
    end

end

function [arclen,seglen] = arclength(px,py,varargin)
% Author: John D'Errico
% e-mail: woodchips@rochester.rr.com
% Release: 1.0
% Release date: 3/10/2010

% unpack the arguments and check for errors
if nargin < 2
  error('ARCLENGTH:insufficientarguments', ...
    'at least px and py must be supplied')
end

n = length(px);
% are px and py both vectors of the same length?
if ~isvector(px) || ~isvector(py) || (length(py) ~= n)
  error('ARCLENGTH:improperpxorpy', ...
    'px and py must be vectors of the same length')
elseif n < 2
  error('ARCLENGTH:improperpxorpy', ...
    'px and py must be vectors of length at least 2')
end

% compile the curve into one array
data = [px(:),py(:)];

% defaults for method and tol
method = 'linear';

% which other arguments are included in varargin?
if numel(varargin) > 0
  % at least one other argument was supplied
  for i = 1:numel(varargin)
    arg = varargin{i};
    if ischar(arg)
      % it must be the method
      validmethods = {'linear' 'pchip' 'spline'};
      ind = strmatch(lower(arg),validmethods);
      if isempty(ind) || (length(ind) > 1)
        error('ARCLENGTH:invalidmethod', ...
          'Invalid method indicated. Only ''linear'',''pchip'',''spline'' allowed.')
      end
      method = validmethods{ind};
      
    else
      % it must be pz, defining a space curve in higher dimensions
      if numel(arg) ~= n
        error('ARCLENGTH:inconsistentpz', ...
          'pz was supplied, but is inconsistent in size with px and py')
      end
      
      % expand the data array to be a 3-d space curve
      data = [data,arg(:)]; %#ok
    end
  end
  
end

% what dimension do we live in?
nd = size(data,2);

% compute the chordal linear arclengths
seglen = sqrt(sum(diff(data,[],1).^2,2));
arclen = sum(seglen);

% we can quit if the method was 'linear'.
if strcmpi(method,'linear')
  % we are now done. just exit
  return
end

% 'spline' or 'pchip' must have been indicated,
% so we will be doing an integration. Save the
% linear chord lengths for later use.
chordlen = seglen;

% compute the splines
spl = cell(1,nd);
spld = spl;
diffarray = [3 0 0;0 2 0;0 0 1;0 0 0];
for i = 1:nd
  switch method
    case 'pchip'
      spl{i} = pchip([0;cumsum(chordlen)],data(:,i));
    case 'spline'
      spl{i} = spline([0;cumsum(chordlen)],data(:,i));
      nc = numel(spl{i}.coefs);
      if nc < 4
        % just pretend it has cubic segments
        spl{i}.coefs = [zeros(1,4-nc),spl{i}.coefs];
        spl{i}.order = 4;
      end
  end
  
  % and now differentiate them
  xp = spl{i};
  xp.coefs = xp.coefs*diffarray;
  xp.order = 3;
  spld{i} = xp;
end

% numerical integration along the curve
polyarray = zeros(nd,3);
for i = 1:spl{1}.pieces
  % extract polynomials for the derivatives
  for j = 1:nd
    polyarray(j,:) = spld{j}.coefs(i,:);
  end
  
  % integrate the arclength for the i'th segment
  % using quadgk for the integral. I could have
  % done this part with an ode solver too.
  seglen(i) = quadgk(@(t) segkernel(t),0,chordlen(i));
end

% and sum the segments
arclen = sum(seglen);

% ==========================
%   end main function
% ==========================
%   begin nested functions
% ==========================
  function val = segkernel(t)
    % sqrt((dx/dt)^2 + (dy/dt)^2)
    
    val = zeros(size(t));
    for k = 1:nd
      val = val + polyval(polyarray(k,:),t).^2;
    end
    val = sqrt(val);
    
  end % function segkernel

end % function arclength