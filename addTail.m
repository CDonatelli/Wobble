function [ Sout ] = addTail( Sin, Sraw)

    Sout = Sin;
    
    Sout.tailPts = Sraw.tailPts;
    Sout.lImTail = Sraw.lImTail;
    Sout.dImTail = Sraw.dImTail;
    Sout.imDTail = Sraw.imDTail;

end

