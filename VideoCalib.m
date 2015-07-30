function [  ] = VideoCalib( )

disp('Please select the directory containing your video');

% go to the directory containing the .avi file
directory = uigetdir;
cd(directory);

% prompt user to enter name of video
% user must enter 'name.avi'
disp('Type in the name of your video file : ');
Vid = input('Name must be in the format ''name.avi'' : ');

SV = VideoReader(Vid); % read in video
dirName=[Vid,'Tiffs']; % create directory name
mkdir(dirName); cd(dirName); % create and go to new directory

disp('Enter the prefix you want your tif files to have.');
Pref = input('Prefix must be in the format ''prefix'':');
FrNum = SV.NumberOfFrames;

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
    
calib

today = date;

save(today,'fc','cc','kc','alpha_c');

end

