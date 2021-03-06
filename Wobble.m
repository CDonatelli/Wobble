function [ ] = Wobble( )
waitfor(msgbox(['Please be sure you have the following in one folder: ', ...
            '1 - Video of your fish, ', ...
            '2 - A dorsal view photo of your fish ', ...
            '3 : A lateral view photo of your fish']));

waitfor(msgbox('Please select the directory containing Video file and image files'));
directory = uigetdir; % go to the directory containing the .avi file
cd(directory);

Vid = input('Please enter the name of your video :', 's');

FileNamePrefix = VideoConvertWob(Vid);
PicConvertWob();

disp('Please select the directory containing your b&w tif files');
pause(0.5);
directory = uigetfdir;
cd(directory);

Midlines = MidlineWob(FileNamePrefix);
SWthk = FishRadGetWob(Midlines, FileNamePrefix);

h = msgbox('Select the Dorsal View image of your fish');
DV = uigetfile();
h = msgbox('Select the Lateral View image of your fish');
LV = uigetfile();

DVmid = ImageMidlineWob(DV);
LVmid = ImageMidlineWob(LV);

DVthk = ImageThicnkessWob(DVmid, DV);
LVthk = ImageThicnkessWob(LVmid, LV);

prompt = {'Enter Video Scale:', 'Enter Dorsal Image Scale:', ...
                                'Enter Lateral Image Scale:',};
dlg_title = 'Scales';
num_lines = 1;
def = {'0','0','0'};
answer = inputdlg(prompt, dlg_title, num_lines, def);
Scales = str2double(answer);

[DVC, LVC] = ThicknessMapWob(Midlines, DVmid, LVmid, SWthk, DVthk, LVthk, Scales);

[MeanWobble, MaxWobble] = WobblePlot(DVC, LVC, SWthk, Midlines);

end

