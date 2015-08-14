function [FileNamePrefix] = VideoConvertWob(Vid)

% script converts an .avi video of an dark object moving on or past
% a white background to
%   1. a series of .tif files
%   2. a series of black & white tif files (black background, white object)
%   3. a black and white version of the original .avi file
% Assumptions
%   1. assumes video is a .avi file
%   2. assumes video is of a dark object on a white background
%   3. assumes video has already been cut and every frame is needed

% prompt user to set directory
% clear all
% close all
% disp('Hello!');
% disp('Please select the directory containing your video');

% go to the directory containing the .avi file
% directory = uigetdir;
% cd(directory);

% prompt user to enter name of video
% user must enter 'name.avi'
% disp('Now type in the name of your video : ');
% Vid = input('Name must be in the format "name.avi" (use apostrophe key): ');

SV = VideoReader(Vid); % read in video
dirName=[Vid,'_breakdown']; % create directory name
mkdir(dirName); cd(dirName); % create and go to new directory
mkdir([Vid,'_tiffs']); mkdir([Vid,'_BWtiffs']); % create two sub-directories
Pref = input('Enter the prefix you want your tif files to have.', 's');
FileNamePrefix = Pref;
FrNum = SV.NumberOfFrames;
VD = dir; DirName = VD.name;

% lev = 0.5;
% cal = read(SV,15); hsv = rgb2hsv(cal); s = hsv(:,:,2); calim = s > 0.5;
% imshow(calim)
% disp('This is what the image looks like with a level of 0.5');
% C = input('Does this look right? (1 or 0)');
% C = strcmp(Ca, 'Y');

% while C ~= 1
%     hl = input('Higher (1) (show less) or Lower (0) (show more)? : ');
%     close all 
%     if hl == 1
%         lev = lev + 0.05;
%         calim = s > lev;
%         imshow(calim);
%     elseif hl == 0
%         lev = lev - 0.05;
%         calim = s > lev;
%         imshow(calim);
%     end
%     disp(lev);
%     C = input('Does this look right? (1 or 0)');
% %     C = strcmp(Ca, 'Y');
% end
close all
    for i = 1:FrNum
        img = read(SV,i);   % read in i-th frame of video
        cd([Vid,'_tiffs']);        % move to tif folder
        if i < 10                                % create tif of i-th frame
            imwrite(img,[Pref, '000', num2str(i), '.tif']);  
        elseif i < 100                           % create tif of i-th frame
            imwrite(img,[Pref, '00', num2str(i), '.tif']);
        elseif i < 1000                          % create tif of i-th frame
            imwrite(img,[Pref, '0', num2str(i), '.tif']); 
        else                                     % create tif of i-th frame
            imwrite(img,[Pref, num2str(i), '.tif']);
        end
        cd ..;                                     % move to main directory
        h = ones(5,5)/25; Blur = imfilter(img,h);
        lev = graythresh(Blur)*0.75;
        frg = ~im2bw(Blur,lev);
        cd([Vid,'_BWtiffs']);                      % move to directory for bw files
        imwrite(frg,['bw',Pref,num2str(i),'.tif']);% create tif of bw frame
        cd ..;                                     % move to main directory
    end
    
cd(Vid,'_BWtiffs')
video = VideoWriter(['BW',Vid]); % create a new video
open(video);                     % open video for modification
for i = 1:FrNum                  % create an array of strings containing 
                                 % the names of the bw .tif files
    ImList{i} = ['bw',Pref,num2str(i),'.tif'];
end
for i = 1:FrNum                % add each frame to the video
    bwimg = double(imread(ImList{i}));
    writeVideo(video,bwimg);
end
close(video)                   % close the video
cd ..;
% disp(['Done! Your files are saved in ', DirName]);
% disp('The tiffs folder contains tiff files of the original video');
% disp('The BWtiffs folder contains the black and white .tif files ');
% disp('and the black and white .avi file');

end

