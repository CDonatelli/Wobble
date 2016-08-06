function struct = wobbleWaveKineMod(struct)

% Initiating variables
    % reading variables from structure
    length = struct.fishlength;
    mids = struct.midLines;
    % points along the fish's body near its tail
    perc = linspace(0.5,0.9,17);
    struct.tailPts = length.*perc;
    tail = struct.tailPts ./length; %for interparc
    % points to generate data for
    npts = 20;
    % frame number
    nfr = length(mids);
    % initiating new variables
    x = []; y = [];
    tailPtCordsY = []; tailPtCordsX = [];
    for i = 1:nfr
        % Generate equation if the midline
        [pts, deriv, funct] = interparc(npts,  mids(i).MidLine(:,1),  ... 
                                        mids(i).MidLine(:,2), 'spline');
        % add those points to an array
        x = [x,pts(:,1)]; y = [y,pts(:,2)];
        
        % usee the above function to find the coordinates of the points
        % of interest in the tail region (to be used later
        for j = 1:length(tail)
            cordinate = funct(tail(j));
            tailPtCordsX(j,i) = cordinate(1);
            tailPtCordsY(j,i) = cordinate(2);
        end
    end
    struct.tailPtCordsX = tailPtCordsX;
    struct.tailPtCordsY = tailPtCordsY;
    struct.X = x; struct.Y = y;
    % figure out time for each frame and make a vector of times
    fr = 120;
    total = nfr/fr; 
    struct.t = linspace(0,total,nfr);
    s = linspace(1,fishlen,npts);
    struct.s = s';

%%%% 2D Wave Kinematics
    tailY = struct.Y(19,:);
    
    %%%%% Mini-Peak Finder
        [p1,k1] = findpeaks(tailY,struct.t);
        [p2,k2] = findpeaks(-tailY,struct.t);
        p = [p1';abs(p2')]; k = [k1';abs(k2')];
        
        % check if peakfinder did it's damn job
        [k,p] = correctPeakFinder(k,p,struct.t,tailY(i,:),['Tail peaks']);
        peaks = [k,p]; peaks = sortrows(peaks);
        k = peaks(:,1); p = peaks(:,2);
        tailPeaks = [k,p];
    %%%%%
    
    
    p = polyfit(time1, tailY,1);   % fit line for the tail wave
    yT = p(1).*(tailPeaks(:,1)) + p(2); % y values for that line
    amps = tailPeaks(:,2) - yT;         % subtract those y values from that
                                        % line to get actual amplitude
    tailAmps = abs(amps*struct.VidScale);
        
    wavenum = length(tailPeaks(:,2));

    if mod(length(tailPeaks(:,1)),2) == 0
        modEnd = 2;
    else 
        modEnd = 1;
    end
    for i = 1:2:length(tailPeaks(:,1))-modEnd
        tailTime = tailPeaks(:,1);
        wavelen = [wavelen; tailTime(i+2) - tailTime(i)];
    end
    
    nose = [struct.midLines(1).MidLine(1,:);struct.midLines(end).MidLine(1,:)];
    distance = pdist(nose, 'euclidean');
    distance = distance.*struct.VidScale;
    %speed in m/s
    struct.swimmingSpeed = (distance/struct.t(end))/1000;
    struct.bendingFrequency = wavenum/2/struct.t(end);
    struct.bendingPeriod = 1/struct.bendingFrequency;
    struct.wavelength = median(wavelen);
    struct.bendingStrideLength = distance/(wavenum/2);
    struct.bendingWS = struct.wavelength*struct.bendingfrequency;
    struct.bendingAmp = median(tailAmps);
    struct.bendingAmps = tailAmps;
    
    
    
    
end

function [k,p] = correctPeakFinder(k,p,X,Y,Title)
    activeFigure = figure;
    plot(X,Y);
    hold on
    plot(k,p,'r*');
    title(Title);
    
    prompt = {'How Many False Peaks?', 'How Many Missing Peaks?'};
    BoxName = 'FindPeak Error correction';
    default = {'0','0'};
    answer = inputdlg(prompt, BoxName,1,default);
    answer = str2double(answer);
    % if the user needs to eliminate points
    if answer(1) ~= 0
        % to eliminate peaks
        for i = 1:answer(1)
            rect = getrect();
            elim = find(k>rect(1) & k<(rect(1)+rect(3)));
            k(elim) = []; p(elim) = [];
            plot(k,p,'o');
        end
    else
    end
    % if the user needs to specify points
    if answer(2) ~= 0
        [x, y] = getpts();
        p = [p;y];
        k = [k;x];
        plot(k,p,'o');
    else
    end
    close(activeFigure)
end
