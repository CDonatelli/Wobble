function [Struct] = midlineRestructure(Struct)
    Len = [];
    for i = 1:length(Struct.MidLine)
        Len = [Len, length(Struct.MidLine(i))];
    end
    twist = Struct.twistPts;
    twist = twist./Struct.fishlen;  % scale to fish length 
                                    % interparc funct needs values from 0-1
                                    % representing percentage down the
                                    % length of the spline (lame)
    npts = min(Len);
    nfr = length(mids);
    x = []; y = []; twistPtCordsX = []; twistPtCordsY = [];
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
            twistPtCordsX(j,i) = cordinate(2);
        end
    end
    Struct.twistPtCordsX = twistPtCordsX;
    Struct.twistPtCordsY = twistPtCordsY;
    mids.MidMatX = x; mids.MidMatY = y;
    fr = 120;
    total = nfr/fr;
    mids.t = linspace(0,total,nfr);
    s = linspace(1,fishlen,npts);
    mids.s = s';
end