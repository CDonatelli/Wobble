function [] = wobble2csv

    dataFiles = dir('*_*.mat');
    mkdir('wobbleCSVs');
    
    for i = 1:length(dataFiles)
        dataFile = load(dataFiles(i).name);
        dataFile = dataFile.Struct;
        
        cd('wobbleCSVs')
        writematrix(...
            dataFile.X.*dataFile.VidScale, [dataFiles(i).name(1:end-4),'_X.csv']);
        writematrix(...
            dataFile.Y.*dataFile.VidScale, [dataFiles(i).name(1:end-4),'_Y.csv']);
        writematrix(dataFile.t, [dataFiles(i).name(1:end-4),'_T.csv']);
        cd ..
    end
    

end