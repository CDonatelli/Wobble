function [] = enterMTSData()

list = dir('*.mat');
Names = cell(length(list),1);
for i = 1:length(list);          % put names into cell array
    Names{i}= list(i).name;
end

Individuals = {'Aflav1', 'Aflav2', 'Aflav3', 'Aflav4', 'Aflav5', 'Aflav6', ...
               'Ainsi1', 'Ainsi2', 'Ainsi3', 'Ainsi4', ...
               'Lsagi3', 'Lsagi4', 'Lsagi5', 'Lsagi6', ...
               'Plaet1', 'Plaet2', 'Plaet3', 'Plaet4', 'Plaet5', ...
               'Rjord1', 'Rjord2', 'Rjord3', 'Rjord4', ...
               'Xmuco1', 'Xmuco2', 'Xmuco3', 'Xmuco4', 'Xmuco5' } ;

for i = 1:length(Individuals)
    NameIndex = strfind(Names, Individuals(i));
    Index = [];
    for j = 1:length(NameIndex)
        if cell2mat(NameIndex(j)) == 1
            Index = [Index;j];
        else
        end
    end
    
    prompt = {'Average Vertebrae','Guage Length', 'Loads', 'Angles'};
    dlg_title = cell2mat(Individuals(i));
    num_lines = 1;
    defaultans = {'0','0','0','0'};
    answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
    
    verts = str2num(cell2mat(answer(1)));
    guage = str2num(cell2mat(answer(2)));
    loads = str2num(cell2mat(answer(3)));
    angle = str2num(cell2mat(answer(4)));
    
    for j = Index(1):Index(end)
        Struct = load(cell2mat(Names(j)));
        Struct = Struct.Struct;
        
        Struct.averageVerts = verts;
        Struct.guageLength = guage;
        Struct.twistLoads = loads;
        Struct.twistAngles = angle;
        
        save(cell2mat(Names(j)), 'Struct')
    end
    
end 

end