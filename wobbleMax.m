function sOut = wobbleMax(struct)
    sOut = struct;
    tWob = struct.tWob;
    wobble = struct.wobble;
    
    [m,n] = size(tWob);
    tMax = [];
    pct = [];
    for i = 1:m
        f = findpeaks(tWob(i,:));
        tMax = [tMax;mean(f)];
        p = prctile(f,90);
        pct = [pct;p];
    end
    sOut.tMax = [tMax, pct];  

    [m,n] = size(wobble);
    wMax = [];
    pct = [];
    for i = 1:m
        f = findpeaks(wobble(i,:));
        p = prctile(f,90);
        wMax = [wMax;mean(f)];
        pct = [pct;p];
    end
    sOut.wMax = [wMax, pct];  
end