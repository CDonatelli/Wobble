function PicConvertWob()
% script converts color images to black and white contour images
%
% clear all
% close all
% disp('Hello!');
% disp('Please select the directory containing your photos');
% pause(1);
% % go to the directory containing the picture files
% directory = uigetdir;
% cd(directory);

% prompt user to enter format of photos. must enter as '.format'
Num = menu('What is the format of your photos?', 'tif', 'jpg', 'png', 'gif');
FileNameList = dir(['*.', Num]);         % create a list of the files
PicNames = cell(length(FileNameList),1); % create a cell array
% mkdir('BWpics')                          % create a directory for BW images
for j = 1:length(FileNameList);          % put names into cell array
    PicNames{j}= FileNameList(j).name;
end

for i = 1:length(PicNames)               % process images
    Pic = imread(char(PicNames(i)));             % read in image
    h = ones(5,5) / 25; BlurIm = imfilter(Pic,h);% blur image
    Level = graythresh(BlurIm)*.75;              % determine level of background
    FrameOut = ~im2bw(BlurIm,Level);             % convert the image to BW
%     cd('BWpics')
    imwrite(FrameOut, ['bw',char(PicNames(i))]); % write image to new dir
%     cd ..
end

end