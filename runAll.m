function sOut = runAll(struct)

    sOut = struct;
    sOut = MidlineWob2(sOut);
    choice = questdlg('Does the midline plot look OK?',...
                      'Please Check',...
                      'Yes','No');
    c = true;
    switch choice
        case 'Yes'
            c = true;
        case 'No'
            c = false;
    end
    
    if c == true
        sOut = midlineRestructure(sOut);
        sOut = VidInfo(sOut);
    else
        sOut = sOut;
        h = msgbox({'Wobble was not calculated.' ...
                    'Please check MidlineWob2.'});
    end

end