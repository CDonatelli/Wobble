% mapping values

SwimmingData = input('Swimming Data: ');  % Swimming Midline points
DVData = input('Dorsal view Data: ');     % Dorsal Midline points
LVData = input('Lateral view Data: ');    % Lateral
SwimmingThickness = input('Swimming Thickness: '); % Swimming Thickness                                   
DVThickness = input('Dorsal view thickness: ');    % Dorsal width
LVThickness = input('Lateral view thickness: ');   % Lateral height
SWScale = input('Swimming vid Scale: ');           % Scale of video
DVScale = input('Dorsal View Scale: ');            % Scale of Dorsal image
LVScale = input('Lateral View Scale: ');           % Scale of Lateral image
% scales should be in pixles/unit

DVTscale = DVThickness/DVScale; % scale the image thicknesses
LVTscale = LVThickness/LVScale;

for i = 1:length(SwimmingData)
    SwimmingThickness(i).Scaled = (SwimmingThickness(i).Thick)/SWScale;
    dist = [];
    for j = 2:length(SwimmingData(i).MidLine)
        X1 = SwimmingData(i).MidLine(j-1,1); 
        Y1 = SwimmingData(i).MidLine((j-1),2);
        X = SwimmingData(i).MidLine(j,1); 
        Y = SwimmingData(i).MidLine(j,2);
        dist(j) = sqrt((X1-X)^2 + (Y1-Y)^2);
    end
    dist = dist/SWScale;
    Xdist = [0];
    for k = 2:length(dist)
        Xdist(k) = Xdist(k-1)+dist(k);
    end
    filter = mean(SwimmingThickness(i).Scaled);
    delete = [];
    for m = 1:length(SwimmingThickness(i).Scaled)
        if SwimmingThickness(i).Scaled(m) >= 2*filter
            delete = [delete,m];
        end
    end
    SwimmingThickness(i).Scaled(delete) = [];
    Xdist(delete) = [];
    plot(Xdist,SwimmingThickness(i).Scaled);
    hold on
end

for jj = 2:length(DVData)
        x1 = DVData(jj-1,1); 
        y1 = DVData((jj-1),2);
        x = DVData(jj,1); 
        y = DVData(jj,2);
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

for ii = 2:length(LVData)
        xx1 = LVData(ii-1,1); 
        yy1 = LVData((ii-1),2);
        xx = LVData(ii,1); 
        yy = LVData(ii,2);
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
    