function [T, A] = MTSTableGenerator(csvName)
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
        'Xmuco1', 'Xmuco2', 'Xmuco3', 'Xmuco4', 'Xmuco5' };
    twistPts = [];
    twistAngles = [];
    twistLoads = [];
    wobTwistPk = [];  % rotate this mat
%     wobTwistT = [];   % rotate this mat
    RowNames = [];
    for i = 1:length(Individuals)
        NameIndex = strfind(Names, Individuals(i));
        Index = [];
        for j = 1:length(NameIndex)
            if cell2mat(NameIndex(j)) == 1
                Index = [Index;j];
            else
            end
        end
        
        Struct = load(cell2mat(Names(Index(1))));
        Struct = Struct.Struct;
            twistPts = [twistPts; Struct.twistPts];
            twistAngles = [twistAngles; Struct.twistAngles];
            twistLoads = [twistLoads; Struct.twistLoads];
            Rows = [];
            for j = 1:length(Struct.twistPts)
                spec = cell2mat(Names(Index(1)));
                Rows = [Rows; spec(1:6)];
            end
            RowNames = [RowNames; Rows];
            
        wobPeakMean = [];
        for j = Index(1):Index(end)
            Struct = load(cell2mat(Names(j)));
            Struct = Struct.Struct;
            check = Struct.wobTwistPk';
            [m,n] = size(check);
            [m1, n1] = size(wobPeakMean);
            if m ~= m1
                continue
            end
            wobPeakMean = [wobPeakMean, Struct.wobTwistPk'];
        end
        wobPeakMean = mean(wobPeakMean, 2);
        
        wobTwistPk = [wobTwistPk; wobPeakMean];

    end

    T = table(  twistPts, ...
                twistAngles, ...
                twistLoads, ...
                wobTwistPk, ...
                'RowNames',RowNames);
   A = table2array(T);
   writetable(T,csvName);

end