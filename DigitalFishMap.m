function [SV] = DigitalFishMap(vid, FishLength, Dpoints, FishPoints)%, calib)
% Dx, Dy, Dz = Digital fish ellipse coordinates (deleted, do I need this?)
% vid = the video you want to map to
% Dpoints = the coordinates of the nose and tail of the fish for each frame
%           of the video you are mapping to (use clickNose() )
% FishPoints = measurements of fish taken from two images (one dordsal view
%              one lateral view
% calib = result of VideoCalib() function. Contains the camera parameters

%     load(calib) % Load in calibration file
%     % Create Projection Matrix -------------
%     KK = [fc(1), alpha_c*fc(1), cc(1) ; ...
%             0        fc(2)      cc(2) ; ...
%             0          0          1  ];
%     %---------------------------------------
    
    SV = VideoReader(vid);    % Read in video
    Fr = SV.NumberOfFrames;   % Get Frame number
    [m,n] = size(FishPoints); % Get number of measured points
    
    for i = 1:Fr
       % angles start out as zero as an initial guess. They will be 
       % corrected as a parrt of the optimization
       angles = zeros(m,1);   % This will be the twisting/wobble matrix
       
       % Wave motion, will be part of optimization
       X = linspace(Dpoints(i,1),Dpoints(i,3), m); 
       Z = linspace(Dpoints(i,2),Dpoints(i,4), m);
       
       
       im = read(SV,i);       % Read in ith frame of video
       im = im2double(im);    % Convert to double
       imshow(im);            % Show frame
       hold on
       
       plot(X,Z, 'c');
       
       for j = 1:m
           % 20 would be the scale of the image measurements compared to 
           % the video. How to get this?
           
           % X = x coordinates of center of ellipse generated using
           % measured nose and tail points (clickNose())
           % Z = z coordinates of above, this will change in while loop to
           % match the fish's body bending during swimming
           [x y] = calculateEllipse(X(j), Z(j), FishPoints(j,1)*17, ...
                                    FishPoints(j,2)*17, angles(j));
           Fz = x; Fy = y; % Fish coordinates
           % generate x coordinates for ellipse, fill with x coordinate of
           % midline array (X above)
           for k = 1:length(Fz)
               Fx(k) = X(j);
           end
           
           % plot the 2D projection
           % need to correct for camera paramaters before plotting
           % How? Projection matrix
           
           plot(Fx, Fy)
           
           % Insert While loop here
           % While plot is not aligned with the fish, continue
           % Look for parts of the image different from background
           % In my case, fish will be dark, the background will be light
           
           
       end
       
       hold off
       
    end

end

