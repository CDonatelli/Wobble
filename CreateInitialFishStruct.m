function [ name ] = CreateInitialFishStruct( nameString )

name = struct;
videos = input('How many videos?: ');
currentFolder = pwd;
disp('Select the directory with your images')
directory = uigetdir();
cd(directory);
dImName = uigetfile('*.png','Select the Dorsal Image');
name.dorsalIm = imread(dImName);
lImName = uigetfile('*.png','Select the Lateral Image');
name.lateralIm = imread(lImName);
name.fishLength = input('What is the length of the fish?: ');
%name.twistPts = input('Enter the twisting points ([paste]): ');
cd(currentFolder);

name = imageInfo(name);

save(nameString, 'name');

    for i = 1:videos
        Struct = name;
        Struct.vid = input(['Name of video for struct ',num2str(i),': ']);
        save([nameString,'_',num2str(i)], 'Struct');
    end

end

