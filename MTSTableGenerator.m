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
    wobTwistPk = [];  
%   wobTwistT = []; 
    vertsGage = [];  % verts in the gage
    loadVerts = [];  % load/angle/vert
    CrossSectArea = [];
    loadArea = [];
    loadArea2 = [];
    torque = [];
    shear = [];
    strain = [];
    G = []; % shear modulus/modulus of rigidity
    J = []; % torsional constant
    RowNames = [];
    momentArm = 43/1000;
    % load/(angle/vert)
    for i = 1:length(Individuals)  % go through each individual
        NameIndex = strfind(Names, Individuals(i));
        Index = [];
        for j = 1:length(NameIndex)         % find the index of the different
            if cell2mat(NameIndex(j)) == 1  % trials from the same individual
                Index = [Index;j];
            else
            end
        end
        
        Struct = load(cell2mat(Names(Index(1))));   % load a representative trial
        Struct = Struct.Struct;
            fishLength = Struct.fishLength;         % rep fish length
            twistPts = [twistPts; Struct.twistPts/fishLength];  % twist pts
                angles = Struct.twistAngles;                    
            twistAngles = [twistAngles; angles];
                loads = Struct.twistLoads;
            twistLoads = [twistLoads; loads];
            vertsLength = Struct.averageVerts/fishLength; % verts/mm
            % guage = mm
            Rows = [];
            vertsGageIndiv = [];
            torque = [torque; loads*momentArm];
            heightWidth = Struct.imDTwist(2:end-1,:) * Struct.ImScale;
                CSArea = heightWidth(:,1).*heightWidth(:,2).*pi;
            CrossSectArea = [CrossSectArea;CSArea];
            for j = 1:length(Struct.twistPts) % for each twist point get a thing
                vertsGageIndiv = [vertsGageIndiv; vertsLength*Struct.guageLength];
                w = heightWidth(j,1)/1000; h = heightWidth(j,2)/1000;
                Jcurrent = (pi * (h/2)^3 * (w/2)^3)/((h/2)^2 + (w/2)^2);
                J = [J; Jcurrent];
                shear = [shear; torque(j)./Jcurrent];                                 %Shear = T/J
                G = [G; (torque(j)*(Struct.guageLength/1000))/(Jcurrent*(angles(j)*pi/180)) ]; % G = T*L/J*Ang
                spec = cell2mat(Names(Index(1)));
                Rows = [Rows; [spec(1:6),'p',num2str(j)]];
            end
            RowNames = [RowNames; Rows];
            loadVerts = [loadVerts; loads./(angles./vertsGageIndiv)];
            loadArea = [loadArea; loads./CSArea];
            loadArea2 = [loadArea2; loads./angles./CSArea];
            vertsGage = [vertsGage; vertsGageIndiv];  
            
            
        wobPeakMean = [];
        for j = 1:length(Index)
            Struct = load(cell2mat(Names(Index(j))));
            Struct = Struct.Struct;
            check = Struct.wobTwistPk';
            if j > 1
                [m,n] = size(check);
                [m1, n1] = size(wobPeakMean);
                if m ~= m1
                    continue
                end
            end
            wobPeakMean = [wobPeakMean, Struct.wobTwistPk'];
        end
        wobPeakMean = mean(wobPeakMean, 2);
        
        wobTwistPk = [wobTwistPk; wobPeakMean];

    end
    strain = [shear./G];
    T = table(  twistPts, ...
                twistAngles, ...
                twistLoads, ...
                wobTwistPk, ...
                vertsGage, ...
                loadVerts, ...
                CrossSectArea, ...
                loadArea, ...
                torque, ...
                shear, ...
                strain, ...
                G, ...
                J, ...
                'RowNames',cellstr(RowNames));
   A = table2array(T);
   writetable(T,csvName);

end