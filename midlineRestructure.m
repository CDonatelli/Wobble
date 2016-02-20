function sOut = midlineRestructure(struct)
    sOut = struct;
%     Len = [];
%     for i = 1:length(struct.MidLine)
%         Len = [Len, length(struct.MidLine(i))];
%     end
    twist = struct.twistPts;
    fishlen = struct(1).fishLength;
    tail = struct.tailPts ./fishlen;
    twist = twist./fishlen;  % scale to fish length 
                                    % interparc funct needs values from 0-1
                                    % representing percentage down the
                                    % length of the spline (lame)
    npts = 20;
    mids = struct.midLines;
    nfr = length(mids);
    x = []; y = []; twistPtCordsX = []; twistPtCordsY = [];
    tailPtCordsY = []; tailPtCordsX = [];
    for i = 1:nfr
%         if length(mids(i).MidLine) == npts
%             x = [x, mids(i).MidLine(:,1)];
%             y = [y, mids(i).MidLine(:,1)];
%         else
%             over = length(mids(i).MidLine) - npts;
%             temp = mids(i).MidLine(over+1:end,:);
%             x = [x,temp(:,1)];
%             y = [y,temp(:,1)];
%         end
        [pts, deriv, funct] = interparc(npts,  mids(i).MidLine(:,1),  ... 
                                        mids(i).MidLine(:,2), 'spline');
        x = [x,pts(:,1)]; y = [y,pts(:,2)];
        for j = 1:length(twist)
            cordinate = funct(twist(j));
            twistPtCordsX(j,i) = cordinate(1);
            twistPtCordsY(j,i) = cordinate(2);
        end
        
        for j = 1:length(tail)
            cordinate = funct(tail(j));
            tailPtCordsX(j,i) = cordinate(1);
            tailPtCordsY(j,i) = cordinate(2);
        end
    end
    sOut.twistPtCordsX = twistPtCordsX;
    sOut.twistPtCordsY = twistPtCordsY;
    sOut.tailPtCordsX = tailPtCordsX;
    sOut.tailPtCordsY = tailPtCordsY;
    sOut.X = x; sOut.Y = y;
    fr = 120;
    total = nfr/fr; 
    sOut.t = linspace(0,total,nfr);
    s = linspace(1,fishlen,npts);
    sOut.s = s';
    
    % insert analyzeKinematics here once you figure shit out
    %[sOut.indpeak, sOut.per, sOut.amp,     ...
    % sOut.midX, sOut.midY, sOut.confpeak,  ...
    % sOut.exc, sOut.wavevel, sOut.wavelen, ...
    % sOut.waver, sOut.waven]    =  analyzeKinematics(sOut.s, sOut.t, x, y, ...
    %                                                   'dssmoothcurve',1);
    
end