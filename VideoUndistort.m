function [] = VideoUndistort( )

disp('When entering filenames, please remember not to input extensions');
disp('Be sure you are in the directory containing your video files.');
disp('You should have run VideoCalib and have the resulting calibration');
disp('paramaters saved in a .mat file in the current directory');
calFile = input('Enter the name of the file : ');
load([calFile, '.mat']);

%-------------------------------------------------------------------------%
% Create Projection Matrix
KK = [fc(1), alpha_c*fc(1), cc(1) ; ...
        0        fc(2)      cc(2) ; ...
        0          0          1  ];
%-------------------------------------------------------------------------%

orig = input('Enter the filename of the video you want to undistort :');

SV = VideoReader([orig, '.MP4']);          % read in video
dirName = orig;                            % create directory name
mkdir(dirName); cd(dirName);               % create and go to new directory
origT = 'Originals'; newT = 'Undistorted'; % create directory names for frames
mkdir(origT); mkdir(newT);                 % create directories for frames

Pref = input('Enter the prefix you want your tif files to have :');
FrNum = SV.NumberOfFrames;
cd(origT)

%-------------------------------------------------------------------------%
% Get and save frames from original video
    for i = 1:FrNum
        img = read(SV,i);   % read in i-th frame of video
        if i < 10 
            imwrite(img,[Pref, '00000', num2str(i), '.tif']);  % create tif of i-th frame
        elseif i < 100
            imwrite(img,[Pref, '0000', num2str(i), '.tif']);  % create tif of i-th frame
        elseif i < 1000
            imwrite(img,[Pref, '000', num2str(i), '.tif']);  % create tif of i-th frame
        elseif i < 10000
            imwrite(img,[Pref, '00', num2str(i), '.tif']);  % create tif of i-th frame
        elseif i < 100000
            imwrite(img,[Pref, '0', num2str(i), '.tif']);  % create tif of i-th frame
        else
            imwrite(img,[Pref, num2str(i), '.tif']);  % create tif of i-th frame
        end
    end
%-------------------------------------------------------------------------%
cd ..
cd(newT)
%-------------------------------------------------------------------------%
% Undistort video frame by frame and save new frames
    for i = 1:FrNum
        I1 = double(read(SV,i));
            if size(I1,3)>1,
                I1 = I1(:,:,2);
            end;
        I2 = rect(I1,eye(3),fc,cc,kc,alpha_c,KK);

        if i < 10 
            imwrite(uint8(round(I2)),gray(256),[Pref, '00000', num2str(i), '.tif']);  % create tif of i-th frame
        elseif i < 100
            imwrite(uint8(round(I2)),gray(256),[Pref, '0000', num2str(i), '.tif']);  % create tif of i-th frame
        elseif i < 1000
            imwrite(uint8(round(I2)),gray(256),[Pref, '000', num2str(i), '.tif']);  % create tif of i-th frame
        elseif i < 10000
            imwrite(uint8(round(I2)),gray(256),[Pref, '00', num2str(i), '.tif']);  % create tif of i-th frame
        elseif i < 100000
            imwrite(uint8(round(I2)),gray(256),[Pref, '0', num2str(i), '.tif']);  % create tif of i-th frame
        else
            imwrite(uint8(round(I2)),gray(256),[Pref, num2str(i), '.tif']);  % create tif of i-th frame
        end
    end
%-------------------------------------------------------------------------%
cd ..
cd ..
%-------------------------------------------------------------------------%
% Create undistorted video
imageNames = dir(fillfile(orig, newT , '*.tif'));    
imageNames = {imageNames.name}';

newVid = VideoWriter(fullfile(pwd, [orig, '_undistorted.avi']));
newVid.FrameRate = SV.FrameRate;
open(newVid)

    for j = 1:length(imageNames)
        img = imread(fullfile(orig, newT , imageNames{j}));
        writeVideo(newVid,img);
    end

close(newVid)
%-------------------------------------------------------------------------%
% Convert original into .avi format
imageNames2 = dir(fillfile(orig, oldT , '*.tif'));    
imageNames2 = {imageNames2.name}';

newVid2 = VideoWriter(fullfile(pwd, [orig, '_fixed.avi']));
newVid2.FrameRate = SV.FrameRate;
open(newVid2)

    for j = 1:length(imageNames2)
        img = imread(fullfile(orig, origT , imageNames{j}));
        writeVideo(newVid2,img);
    end

close(newVid2)

end

