function newCords = interpolateMids(midline)
    % not necessary anymore. use interparc()
    [arcLength, Dmat] = arclength(midnline(:,1),midline(:,2));
    
    nDmat = [0];
    for i = 1:length(Dmat)
        nDmat(i+1) = nDmat(i) + Dmat(i);
    end
    wpts = linspace(0,arcLength,20);
    newCords = [midline(1,:)];
    for i = 2:20
        len = wpts(i);
        c1 = 1; c2 = 2;
        s1 = nDmat(c1); s2 = nDmat(c2);
        c = 0;
        while c == 0
            if s1 <= len && s2 >= len
                dist
                c = 1;
            else
                c1 = c1+1; c2 = c2+1;
                s1 = nDmat(c1); s2 = nDmat(c2);
            end
            newCords = [newCords; newX, newY];
        end

end