function [T, A] = wobblePhaseLag(csvName)

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

    phaseLag = [];
    RowNames = [];
    for i = 1:length(Individuals)
        NameIndex = strfind(Names, Individuals(i)); % all elements in list
                                                    % where name matches
                                                    % individual i
        Index = [];
        for j = 1:length(NameIndex)                 % find actual index in
            if cell2mat(NameIndex(j)) == 1          % list of the values in
                Index = [Index;j];                  % NameIndex
            else
            end
        end
        
        for j = 1:length(Index)                 % go through one individual
            Struct = load(cell2mat(Names(Index(j))));
            Struct = Struct.Struct;
            phaseLagRaw = [];
            
            bending = Struct.tailPeakT(:,5);
            wobble = Struct.wobTailT(:,5);
            wobAmp = Struct.wobTailPk(:,5);
        
            for k = 1:length(bending)-1    % look at peaks within one indiv
                range = [bending(k), bending(k+1)];
                inRange = find(wobble > range(1) & wobble < range(2));
                if isempty(inRange)
                    phaseLagRaw = [phaseLagRaw;NaN];
                else
                    timeRange = wobble(inRange);
                    ampRange = wobAmp(inRange);
                    [M, I] = max(ampRange);
                    phaseLagRaw = [phaseLagRaw; timeRange(I) - range(1)];
                end
            end
            
            medPhase = nanmedian(phaseLagRaw); % get the median of the lag
        end
        
        phaseLag = [phaseLag; medPhase];
        
    end

   T = table(  phaseLag, ...
               'RowNames', Individuals);
   A = table2array(T);
   writetable(T,csvName);

end