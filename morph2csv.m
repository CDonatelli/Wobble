function [] = morph2csv

    dataFiles = dir('*_*.mat');
    mkdir('morphCSVs');
    
    for i = 1:length(dataFiles)
        dataFile = load(dataFiles(i).name);
        dataFile = dataFile.Struct;
        
        cd('morphCSVs')
        writematrix(dataFile.imD.*dataFile.ImScale, [dataFiles(i).name(1:end-4),'_morpho.csv']);
        writematrix(dataFile.fishLength,[dataFiles(i).name(1:end-4),'_length.csv']);
        cd ..
    end
    

end