function [Struct] = wobbleKinematics(Struct)

    Struct.indpeakTail = [];
    Struct.indpeakTwist = [];
    
    Struct.indpeakTail = analyzeKinematics(Struct.stail, Struct.t, ...
                        Struct.tailXs,Struct.tailYs, 'dssmoothcurve',3.75);
    Struct.indpeakTwist = analyzeKinematics(Struct.stwist', Struct.t, ...
                        Struct.twistXs,Struct.twistYs, 'dssmoothcurve',3.75);
    
    save(NameStr, 'Struct');

end