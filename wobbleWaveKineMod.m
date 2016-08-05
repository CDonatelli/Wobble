function struct = wobbleWaveKineMod(struct)

    length = struct.fishlength;
    mids = struct.midLines;
    perc = linspace(0.5,0.9,17);
    struct.tailPts = length.*perc;
    tail = struct.tailPts ./length; %for interparc
    npts = 20;
    nfr = length(mids);
    x = []; y = [];
    tailPtCordsY = []; tailPtCordsX = [];
    for i = 1:nfr
        [pts, deriv, funct] = interparc(npts,  mids(i).MidLine(:,1),  ... 
                                        mids(i).MidLine(:,2), 'spline');
        x = [x,pts(:,1)]; y = [y,pts(:,2)];
        
        for j = 1:length(tail)
            cordinate = funct(tail(j));
            tailPtCordsX(j,i) = cordinate(1);
            tailPtCordsY(j,i) = cordinate(2);
        end
    end
    sOut.tailPtCordsX = tailPtCordsX;
    sOut.tailPtCordsY = tailPtCordsY;
    sOut.X = x; sOut.Y = y;
    fr = 120;
    total = nfr/fr; 
    sOut.t = linspace(0,total,nfr);
    s = linspace(1,fishlen,npts);
    sOut.s = s';
    
end