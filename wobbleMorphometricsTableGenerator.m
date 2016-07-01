function [T, A] = wobbleMorphometricsTableGenerator(csvName)
    list = dir;
    
     Pos1 = [];     wPos1 = [];
     Pos2 = [];     wPos2 = [];
     Pos3 = [];     wPos3 = [];
     Pos4 = [];     wPos4 = [];
     Pos5 = [];     wPos5 = [];
     Pos6 = [];     wPos6 = [];
     Pos7 = [];     wPos7 = [];
     Pos8 = [];     wPos8 = [];
     Pos9 = [];     wPos9 = [];
    Pos10 = [];    wPos10 = [];
    Pos11 = [];    wPos11 = [];
    Pos12 = [];    wPos12 = [];
    Pos13 = [];    wPos13 = [];
    Pos14 = [];    wPos14 = [];
    Pos15 = [];    wPos15 = [];
    Pos16 = [];    wPos16 = [];
    Pos17 = [];    wPos17 = [];
    Pos18 = [];    wPos18 = [];
    Pos19 = [];    wPos19 = [];
    Pos20 = [];    wPos20 = [];
    
    BodyLength = [];
    RowNames = [];
    for i = 3:length(list)
        NameStr = list(i).name;
        Struct = load(NameStr);
        Struct = Struct.Struct;
        
        h = Struct.imD(:,2)';
        w = Struct.imD(:,1)';
        
         Pos1 =  [Pos1; h(1)];   wPos1 =  [wPos1; w(1)];
         Pos2 =  [Pos2; h(2)];   wPos2 =  [wPos2; w(2)];
         Pos3 =  [Pos3; h(3)];   wPos3 =  [wPos3; w(3)];
         Pos4 =  [Pos4; h(4)];   wPos4 =  [wPos4; w(4)];
         Pos5 =  [Pos5; h(5)];   wPos5 =  [wPos5; w(5)];
         Pos6 =  [Pos6; h(6)];   wPos6 =  [wPos6; w(6)];
         Pos7 =  [Pos7; h(7)];   wPos7 =  [wPos7; w(7)];
         Pos8 =  [Pos8; h(8)];   wPos8 =  [wPos8; w(8)];
         Pos9 =  [Pos9; h(9)];   wPos9 =  [wPos9; w(9)];
        Pos10 = [Pos10; h(10)]; wPos10 = [wPos10; w(10)];
        Pos11 = [Pos11; h(11)]; wPos11 = [wPos11; w(11)];
        Pos12 = [Pos12; h(12)]; wPos12 = [wPos12; w(12)];
        Pos13 = [Pos13; h(13)]; wPos13 = [wPos13; w(13)];
        Pos14 = [Pos14; h(14)]; wPos14 = [wPos14; w(14)];
        Pos15 = [Pos15; h(15)]; wPos15 = [wPos15; w(15)];
        Pos16 = [Pos16; h(16)]; wPos16 = [wPos16; w(16)];
        Pos17 = [Pos17; h(17)]; wPos17 = [wPos17; w(17)];
        Pos18 = [Pos18; h(18)]; wPos18 = [wPos18; w(18)];
        Pos19 = [Pos19; h(19)]; wPos19 = [wPos19; w(19)];
        Pos20 = [Pos20; h(20)]; wPos20 = [wPos20; w(20)];
        
        BodyLength = [BodyLength; Struct.fishLength];
        
        RowNames = [RowNames; NameStr(1:6)];
    end
    RowNames = cellstr(RowNames);
    T = table(   Pos1,     wPos1,   ...
                 Pos2,     wPos2,   ...
                 Pos3,     wPos3,   ...
                 Pos4,     wPos4,   ...
                 Pos5,     wPos5,   ...
                 Pos6,     wPos6,   ...
                 Pos7,     wPos7,   ...
                 Pos8,     wPos8,   ...
                 Pos9,     wPos9,   ...
                Pos10,     wPos10,  ...
                Pos11,     wPos11,  ...
                Pos12,     wPos12,  ...
                Pos13,     wPos13,  ...
                Pos14,     wPos14,  ...
                Pos15,     wPos15,  ...
                Pos16,     wPos16,  ...
                Pos17,     wPos17,  ...
                Pos18,     wPos18,  ...
                Pos19,     wPos19,  ...
                Pos20,     wPos20,  ...
                BodyLength,         ...
                'RowNames',RowNames);
   A = table2array(T);
   writetable(T,csvName);
end