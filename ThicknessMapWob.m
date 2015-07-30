function [DVCords, LVCords] = ThicknessMapWob(Midlines, DVMid, LVMid, SWThk, DVThk, LVThk, ...
                              Scales)
% mapping values

% Midlines = input('Swimming Data: ');  % Swimming Midline points
% DVMid = input('Dorsal view Data: ');     % Dorsal Midline points
% LVMid = input('Lateral view Data: ');    % Lateral
% SWThk = input('Swimming Thickness: '); % Swimming Thickness                                   
% DVThk = input('Dorsal view thickness: ');    % Dorsal width
% LVThk = input('Lateral view thickness: ');   % Lateral height
% SWScale = input('Swimming vid Scale: ');           % Scale of video
% DVScale = input('Dorsal View Scale: ');            % Scale of Dorsal image
% LVScale = input('Lateral View Scale: ');           % Scale of Lateral image
% scales should be in pixles/unit

SWScale = Scales(1);
DVScale = Scales(2);
LVScale = Scales(3);

DVTscale = DVThk/DVScale; % scale the image thicknesses
LVTscale = LVThk/LVScale;

for i = 1:length(Midlines)
    SWThk(i).Scaled = (SWThk(i).Thick)/SWScale;
    dist = [];
    for j = 2:length(Midlines(i).MidLine)
        X1 = Midlines(i).MidLine(j-1,1); 
        Y1 = Midlines(i).MidLine((j-1),2);
        X = Midlines(i).MidLine(j,1); 
        Y = Midlines(i).MidLine(j,2);
        dist(j) = sqrt((X1-X)^2 + (Y1-Y)^2);
    end
    dist = dist/SWScale;
    Xdist = [0];
    for k = 2:length(dist)
        Xdist(k) = Xdist(k-1)+dist(k);
    end
    filter = mean(SWThk(i).Scaled);
    delete = [];
    for m = 1:length(SWThk(i).Scaled)
        if SWThk(i).Scaled(m) >= 2*filter
            delete = [delete,m];
        end
    end
    SWThk(i).Scaled(delete) = [];
    Xdist(delete) = [];
    plot(Xdist,SWThk(i).Scaled);
    hold on
end

for jj = 2:length(DVMid)
        x1 = DVMid(jj-1,1); 
        y1 = DVMid((jj-1),2);
        x = DVMid(jj,1); 
        y = DVMid(jj,2);
        distDV(jj) = sqrt((x1-x)^2 + (y1-y)^2);
end
distDV = distDV/DVScale;
XdistDV = [0];
for l = 2:length(distDV)
    XdistDV(l) = XdistDV(l-1)+distDV(l);
end
plot(XdistDV,DVTscale, 'c*');
hold on
DVCords = transpose([XdistDV; DVTscale]);
DVCords(1,:) = [];
save('DVCords','DVCords');

for ii = 2:length(LVMid)
        xx1 = LVMid(ii-1,1); 
        yy1 = LVMid((ii-1),2);
        xx = LVMid(ii,1); 
        yy = LVMid(ii,2);
        distLV(ii) = sqrt((xx1-xx)^2 + (yy1-yy)^2);
end
distLV = distLV/LVScale;
XdistLV = [0];
for ll = 2:length(distLV)
    XdistLV(ll) = XdistLV(ll-1)+distLV(ll);
end
plot(XdistLV,LVTscale, 'r*');
LVCords = transpose([XdistLV; LVTscale]);
LVCords(1,:) = [];
save('LVCords','LVCords');

end
    