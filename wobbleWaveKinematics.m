function [Struct] = wobbleWaveKinematics(Struct, varargin)
    tailY = Struct.tailYs;
    twistY = Struct.twistYs;
    tailX = Struct.tailXs;
    twistX = Struct.twistXs;
    tailWob = Struct.tailWobs;
    twistWob = Struct.twistWobs;
    time1 = Struct.t;
    time2 = Struct.time2;
    midlines = Struct.midLines;
    
    % load peak amplitudes
    twistPeaks = Struct.twistPeaks;
    wobTwistPk = Struct.wobTwistPk;
    tailPeaks = Struct.tailPeaks;
    wobTailPk = Struct.wobTailPk;
    % deal with values greater then 1
    wobTwistPk = replaceOnes(wobTwistPk);
    wobTailPk = replaceOnes(wobTailPk);
    
    % load times
    twistPeakT = Struct.twistPeakT;
    wobTwistT = Struct.wobTwistT;
    tailPeakT = Struct.tailPeakT;
    wobTailT = Struct.wobTailT;
    
    tailAmps = [];
    tailWobAmps = [];
    tailWobFreq = [];
    tailWobWS = [];
    wavenum = [];
    wavelen = [];
%%%%%%%%%%%%%%%%%%% --- BENDING --- %%%%%%%%%%%%%%%%%%% 
%     [m,n] = size(tailPeaks);
%     wavelen = zeros(round(m/2),n); % empty array for looking at the time of
%                                    % every other peak (which is one cycle)
%     for i = 1:5
    p = polyfit(time1, tailY(5,:),1);
    yT = p(1).*(tailPeakT(:,5)) + p(2);
    amps = tailPeaks(:,5) - yT;
    tailAmps = abs(amps*Struct.VidScale);
        
%         wavenum(i) = length(tailPeaks(:,i));
    wavenum = length(tailPeaks(:,5));
%         for j = 1:2:m-2
%             if tailPeakT (j+2,i) ~= 0
%                 wavelen(i,j) = tailPeakT(j+2, i) - tailPeakT(j,i);
%             else
%                 wavelen(i,j) = 0;
%             end
%         end
    if mod(length(tailPeakT(:,5)),2) == 0
        modEnd = 2;
    else
        modEnd = 1;
    end
    for i = 1:2:length(tailPeakT(:,5))-modEnd
        tailTime = tailPeakT(:,5);
        wavelen = [wavelen; tailTime(i+2) - tailTime(i)];
    end
%     end
    
    nose = [Struct.midLines(1).MidLine(1,:);Struct.midLines(end).MidLine(1,:)];
    distance = pdist(nose, 'euclidean');
    distance = distance.*Struct.VidScale;
    %speed in m/s
    Struct.swimmingSpeed = (distance/time1(end))/1000;
    Struct.bendingFrequency = wavenum/2/time1(end);
    Struct.bendingPeriod = 1/Struct.bendingFrequency;
    
    % find a mean of the wavelengths
%     [ii,~,v] = find(wavelen); rowMeans = accumarray(ii,v,[],@mean);
%     Struct.wavelength = mean(rowMeans); %lambda = average wavelength
    Struct.wavelength = median(wavelen);
    Struct.bendingStrideLength = distance/(wavenum/2);
%     Struct.bendingWS = Struct.wavelength/Struct.bendingPeriod;
    
    % find a mean of the bending amplitude
%     [ii,~,v] = find(tailAmps); rowMeans = accumarray(ii,v,[],@mean);
%     Struct.bendingAmp = mean(rowMeans);
    Struct.bendingAmp = median(tailAmps);
    Struct.bendingAmps = tailAmps;
    
%%%%%%%%%%%%%%%%%%% --- WOBBLE --- %%%%%%%%%%%%%%%%%%% 
    p = polyfit(time2, tailWob(5,:),1);
    yT = p(1).*(wobTailT(:,5)) + p(2);
    amps = wobTailPk(:,5) - yT;
    wobAmps = abs(amps*Struct.VidScale);

    wavenum = length(wobTailPk(:,5));
    wobWL = [];
    for i = 1:length(wobTailT(:,5))-1
        wobTime = wobTailT(:,5);
        wobWL = [wobWL; wobTime(i+1) - wobTime(i)];
    end
    
    Struct.wobbleFrequency = wavenum/2/time2(end);
    Struct.wobblePeriod = 1/Struct.wobbleFrequency;
    Struct.wobbleWavelength = median(wobWL);
%     Struct.bendingWS = wavenum/2/distance;
    Struct.wobbleStrideLength = distance/(wavenum/2);
    
    Struct.wobbleAmp = median(wobAmps);
    Struct.wobblwAmps = wobAmps;
    
    if nargin > 1
        nameStr = varargin{1};
        save(nameStr, 'Struct')
    else
    end
    
end

function [broken] = replaceOnes(broken)
    [m,n] = size(broken);
    for i = 1:n
        col = broken(:,i);
        notOne = col<1 & col>0;
        if any(col > 1)
            One = col > 1;
            replace = median(col(notOne));
            col(One) = replace;
            broken(:,i) = col;
        elseif any(col > 1) && isempty(notOne)
            One = col > 0;
            nextCol = broken(:,i+1);
            nextNotOne = nextCol<1 & nextCol>0;
            replace = median(nextCol(nextNotOne));
            col(One) = replace;
            broken(:,i) = col;
        else
        end
    end
end
%%%%%%%%%%%%%%%%%%%% RUNNING THE CODE FOR A.FLAV
% load('Aflav2_1.mat')
% Struct = wobbleWaveKinematics(Struct,'Aflav2_1.mat');
% load('Aflav2_2.mat')
% Struct = wobbleWaveKinematics(Struct,'Aflav2_2.mat');
% load('Aflav2_3.mat')
% Struct = wobbleWaveKinematics(Struct,'Aflav2_3.mat');
% load('Aflav2_4.mat')
% Struct = wobbleWaveKinematics(Struct,'Aflav2_4.mat');
% load('Aflav2_5.mat')
% Struct = wobbleWaveKinematics(Struct,'Aflav2_5.mat');
% load('Aflav3_1.mat')
% Struct = wobbleWaveKinematics(Struct,'Aflav3_1.mat');
% load('Aflav3_2.mat')
% Struct = wobbleWaveKinematics(Struct,'Aflav3_2.mat');
% load('Aflav3_3.mat')
% Struct = wobbleWaveKinematics(Struct,'Aflav3_3.mat');
% load('Aflav3_4.mat')
% Struct = wobbleWaveKinematics(Struct,'Aflav3_4.mat');
% load('Aflav3_5.mat')
% Struct = wobbleWaveKinematics(Struct,'Aflav3_5.mat');
% load('Aflav4_1.mat')
% Struct = wobbleWaveKinematics(Struct,'Aflav4_1.mat');
% load('Aflav4_2.mat')
% Struct = wobbleWaveKinematics(Struct,'Aflav4_2.mat');
% load('Aflav4_3.mat')
% Struct = wobbleWaveKinematics(Struct,'Aflav4_3.mat');
% load('Aflav4_4.mat')
% Struct = wobbleWaveKinematics(Struct,'Aflav4_4.mat');
% load('Aflav4_5.mat')
% Struct = wobbleWaveKinematics(Struct,'Aflav4_5.mat');
% load('Aflav5_1.mat')
% Struct = wobbleWaveKinematics(Struct,'Aflav5_1.mat');
% load('Aflav5_2.mat')
% Struct = wobbleWaveKinematics(Struct,'Aflav5_2.mat');
% load('Aflav5_3.mat')
% Struct = wobbleWaveKinematics(Struct,'Aflav5_3.mat');
% load('Aflav5_4.mat')
% Struct = wobbleWaveKinematics(Struct,'Aflav5_4.mat');
% load('Aflav5_5.mat')
% Struct = wobbleWaveKinematics(Struct,'Aflav5_5.mat');
% load('Aflav6_1.mat')
% Struct = wobbleWaveKinematics(Struct,'Aflav6_1.mat');
% load('Aflav6_2.mat')
% Struct = wobbleWaveKinematics(Struct,'Aflav6_2.mat');
% load('Aflav6_3.mat')
% Struct = wobbleWaveKinematics(Struct,'Aflav6_3.mat');
% load('Aflav6_4.mat')
% Struct = wobbleWaveKinematics(Struct,'Aflav6_4.mat');
% load('Aflav6_5.mat')
% Struct = wobbleWaveKinematics(Struct,'Aflav6_5.mat');
% load('Aflav1_1.mat')
% Struct = wobbleWaveKinematics(Struct,'Aflav1_1.mat');
% load('Aflav1_2.mat')
% Struct = wobbleWaveKinematics(Struct,'Aflav1_2.mat');
% load('Aflav1_3.mat')
% Struct = wobbleWaveKinematics(Struct,'Aflav1_3.mat');
% load('Aflav1_4.mat')
% Struct = wobbleWaveKinematics(Struct,'Aflav1_4.mat');
% load('Aflav1_5.mat')
% Struct = wobbleWaveKinematics(Struct,'Aflav1_5.mat');
    
    
    
    
    
    
    
    
    