function [Struct] = COMWaveInfo(Struct)
    SV = VideoReader(Struct.vid);
    scale = Struct.scale; % knownDist/pxlDist; %mm/pxl
    fishLength = Struct.fishLength; % input('How long is the fish? (in mm) : ');
    
    Dur = SV.Duration;
    FrNum = SV.NumberOfFrames;
    
    TailAngle = [];
    Points = Struct.Points;
    %%% Calculate body line
    for i = 1:FrNum
        P1 = [Points(i,1), Points(i,2)];
        P0 = [Points(i,3), Points(i,4)];
        P2 = [Points(i,5), Points(i,6)];
%         ang = atan2(abs(det([P2-P0;P1-P0])),dot(P2-P0,P1-P0));
        ang = atan2(det([P2-P0;P1-P0]),dot(P2-P0,P1-P0));
        ang = ang*180/pi;
%         if ang > 180
%             ang = 180-ang;
%         else
%         end
        TailAngle = [TailAngle;ang];
    end
        TailAngleCorr = [];
        for i = 1:length(TailAngle)
            if TailAngle(i) > 0
                TailAngleCorr(i) = 180 - TailAngle(i);
            else
                TailAngleCorr(i) = -180 - TailAngle(i);
            end
        end
        Struct.TailAngleCorr = TailAngleCorr;
        Struct.TailAngle = TailAngle;
    time = linspace(0,Dur,FrNum)';
        Struct.time = time;
    [p1,k1] = findpeaks(TailAngle,time);
    [p2,k2] = findpeaks(-TailAngle, time);
    p = [p1;abs(p2)]; k = [k1;abs(k2)];
    peaks = [k,p]; peaks = sortrows(peaks);
        Struct.peaks = peaks;
%     p = polyfit(time(2:end), TailAngle,1);     % fit line for the tail wave
%     yT = p(1).*(peaks(:,1)) + p(2);     % y values for that line
%     relAngles = peaks(:,2) - yT;        % subtract those y values from that
%                                         % line to get actual amplitude
%     Struct.relAngles = relAngles;
        noseOne = [Points(1,1), Points(1,2)];
        noseEnd = [Points(end,1), Points(end,2)];
        swimmingDistance = pdist([noseOne;noseEnd], 'euclidean')*scale;
    Struct.swimmingSpeed = (swimmingDistance/1000/Dur); % mm/s
    Struct.relSwimSpeed = Struct.swimmingSpeed/fishLength/1000;
        wavenum = length(peaks(:,1));
    Struct.bendingFrequency = wavenum/2/Dur; % cycles per second
    Struct.bendingPeriod = 1/Struct.bendingFrequency;
%         if mod(length(peaks(:,1)),2) == 0
%             modEnd = 2;
%         else 
%             modEnd = 1;
%         end
%         for i = 1:2:length(peaks(:,1))-modEnd
%             tailTime = peaks(:,1);
%             WS = [WS; tailTime(i+2) - tailTime(i)];
%         end

        wavelength = swimmingDistance/(wavenum/2); % m/cycle
        Struct.wavelength = wavelength; %Struct.bendingWS/Struct.bendingFrequency;
    Struct.bendingStrideLength = swimmingDistance/(wavenum/2);
    Struct.bendingWS = Struct.wavelength*Struct.bendingFrequency;
                        %m/cycle * cycles/second = m/second!
        %%%%% Mini-Peak Finder
            tailY = Points(:,6);
            [p1,k1] = findpeaks(tailY,time);
            [p2,k2] = findpeaks(-tailY,time);
            p = [p1;abs(p2)]; k = [k1;abs(k2)];
            tailPeaks = [k,p]; tailPeaks = sortrows(tailPeaks);
        %%%%%
            p = polyfit(time, tailY,1);        % fit line for the tail wave
            yT = p(1).*(tailPeaks(:,1)) + p(2); % y values for that line
            amps = tailPeaks(:,2) - yT;         % subtract those y values from that
                                                % line to get actual amplitude
            tailAmps = abs(amps*Struct.scale);
    
    Struct.bendingAmp = median(tailAmps);
    Struct.bendingAmps = tailAmps;
    save([Struct.vid(1:end-4),'Dat.mat'],'Struct')                                      
end