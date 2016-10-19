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
            
            bending = Struct.tailPeakT;
            wobble = Struct.wobTailT;
            wobAmp = Struct.wobTailPk;
            medPhase = [];
%             bending = Struct.tailPeakT(:,5);
%             wobble = Struct.wobTailT(:,5);
%             wobAmp = Struct.wobTailPk(:,5);
            period = Struct.bendingPeriod;
            for t = 1:5
                [m,n] = size(bending);
                bend = bending(:,t); wob = wobble(:,t); wAmp = wobAmp(:,t);
%                 bend = bending; wob = wobble; wAmp = wobAmp;
                phaseLagRaw = [];
                for k = 1:m-1 %length(bending)-1   % look at peaks within one indiv
                    % find time range of first two bending peaks
                    range = [bend(k), bend(k+1)];
                    % see if there are any wobble peaks in that range
                    inRange = find(wob > range(1) & wob < range(2));
                    if isempty(inRange)     % if there aren't, insert NaN
                        phaseLagRaw = [phaseLagRaw;NaN];
                    else                    % if there are, find the lag
                        timeRange = wob(inRange);
                        ampRange = wAmp(inRange);
                        [M, I] = max(ampRange);
                        phaseLagRaw = [phaseLagRaw; timeRange(I) - range(1)];
                    end
                end
                medPhase = [medPhase,nanmedian(phaseLagRaw)/period]; % get the median of the lag
%                 medPhase = nanmedian(phaseLagRaw)/period;
            end
            
        end
        
        phaseLag = [phaseLag; medPhase];
        
    end

   T = table(  phaseLag, ...
               'RowNames', Individuals);
   A = table2array(T);
   writetable(T,csvName);

end