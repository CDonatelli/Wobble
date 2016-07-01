function [Struct] = wobblePeaks(Struct,varargin)

    tailY = Struct.tailYs;
    twistY = Struct.twistYs;
    tailX = Struct.tailXs;
    twistX = Struct.twistXs;
    tailWob = Struct.tailWobs;
    twistWob = Struct.twistWobs;
    time1 = Struct.t;
    time2 = Struct.time2;
    % m1 = number of twist pts, n1 = number of frames
    % m2 = number of twist pts, n2 = number of wobble frames
    [m1, n1] = size(twistY);
    [m2, n2] = size(twistWob);
    twistPeaks = [];
    twistPeakT = [];
    wobTwistPk = [];
    wobTwistT = [];
    tailPeaks = [];
    tailPeakT = [];
    wobTailPk = [];
    wobTailT = [];
    
    placementFig = figure;
    waitfor(msgbox('Move the figure to where you want it to pop up'));
    p = get(gcf,'Position');
    set(0, 'DefaultFigurePosition', p);
    close(placementFig)
    
    compareFig = figure;
    subplot(2,2,1)
    plot(tailY')
    title('Tail Bending')
    subplot(2,2,2)
    plot(tailWob')
    title('Tail Wobble');
    subplot(2,2,3)
    plot(twistY')
    title('Twist Bending');
    subplot(2,2,4)
    plot(twistWob')
    title('Twist Wobble');
    if nargin > 1
        bigTitle = varargin{1};
        annotation('textbox', [0 0.9 1 0.1], 'String', bigTitle , ...
            'EdgeColor', 'none', 'HorizontalAlignment', 'center', ...
            'FontSize', 14)
    else
    end
    waitfor(msgbox('Move the comparison figure to where you want it.'));
    
    % find peaks at twist points
    for i = 1:m2
        [p1,k1] = findpeaks(twistY(i,:),time1);
        [p2,k2] = findpeaks(-twistY(i,:),time1);
        p = [p1';abs(p2')]; k = [k1';abs(k2')];
        
        % if there are no peaks (ie the smoother killed it)
        if isempty(p)
            [twistY(i,:)] = fixSmoother(time1, twistY(i,:), ...
                                        Struct.twistPtCordsY(i,:));
            [p1,k1] = findpeaks(twistY(i,:),time1);
            [p2,k2] = findpeaks(-twistY(i,:),time1);
            p = [p1';abs(p2')]; k = [k1';abs(k2')];
        else
        end
        
        % check if peakfinder did it's damn job
        [k,p] = correctPeakFinder(k,p,time1,twistY(i,:),['Twist Bending ',num2str(i)]);
        peaks = [k,p]; peaks = sortrows(peaks);
        k = peaks(:,1); p = peaks(:,2);

        % if there are more or fewer peaks in one frame then another
        if i > 1 && length(p) ~= length(twistPeaks(:,(i-1))) && ...
                    length(k) ~= length(twistPeakT(:,(i-1)))
            [mP,nP] = size(twistPeaks);
            [mK,nK] = size(twistPeakT);
            [k,p,twistPeakT,twistPeaks] = fixMatSize(k,p,mK,mP,twistPeakT,twistPeaks);
        else
        end
        
        twistPeaks = [twistPeaks,p];
        twistPeakT = [twistPeakT,k];
        
        
        [p,k] = findpeaks(twistWob(i,:),time2);
        
        % if there are no peaks (ie the smoother killed it)
        if isempty(p)
            [twistWob(i,:)] = fixSmoother(time2, twistWob(i,:), ...
                                        Struct.tWob(i+1,:));
            [p,k] = findpeaks(twistWob(i,:),time2);
        else
        end
        p = p'; k = k';
        
        [k,p] = correctPeakFinder(k,p,time2,twistWob(i,:),['Twist Wobble ',num2str(i)]);
        peaks = [k,p]; peaks = sortrows(peaks);
        k = peaks(:,1); p = peaks(:,2);
        % if there are more or fewer peaks in one frame then another
        if i > 1 && length(p) ~= length(wobTwistPk(:,(i-1))) && ...
                    length(k) ~= length(wobTwistT(:,(i-1)))
            [mP,nP] = size(wobTwistPk);
            [mK,nK] = size(wobTwistT);
            [k,p,wobTwistT, wobTwistPk] = fixMatSize(k,p,mK,mP,wobTwistT, wobTwistPk);
        else
        end
        
        wobTwistPk = [wobTwistPk,p];
        wobTwistT = [wobTwistT,k];
    end
    
    % find peaks at tail points
    for i = 1:5
        [p1,k1] = findpeaks(tailY(i,:),time1);
        [p2,k2] = findpeaks(-tailY(i,:),time1);
        p = [p1';abs(p2')]; k = [k1';abs(k2')];
        
        % if there are no peaks (ie the smoother killed it)
        if isempty(p)
            [tailY(i,:)] = fixSmoother(time1, tailY(i,:), ...
                                        Struct.tailPtCordsY(i,:));
            [p1,k1] = findpeaks(tailY(i,:),time1);
            [p2,k2] = findpeaks(-tailY(i,:),time1);
            p = [p1';abs(p2')]; k = [k1';abs(k2')];
        else
        end
        
        % check if peakfinder did it's damn job
        [k,p] = correctPeakFinder(k,p, time1,tailY(i,:),['Tail Bending ',num2str(i)]);
        peaks = [k,p]; peaks = sortrows(peaks);
        k = peaks(:,1); p = peaks(:,2);
        % if there are more or fewer peaks in one frame then another
        if i > 1 && length(p) ~= length(tailPeaks(:,(i-1))) && ...
                    length(k) ~= length(tailPeakT(:,(i-1)))
            [mP,nP] = size(tailPeaks);
            [mK,nK] = size(tailPeakT);
            [k,p,tailPeakT,tailPeaks] = fixMatSize(k,p,mK,mP,tailPeakT,tailPeaks);
        else
        end
        tailPeaks = [tailPeaks,p];
        tailPeakT = [tailPeakT,k];

        
        [p,k] = findpeaks(tailWob(i,:),time2);
        
        % if there are no peaks (ie the smoother killed it)
        if isempty(p)
            [tailWob(i,:)] = fixSmoother(time2, tailWob(i,:), ...
                                        Struct.tLWob(i+1,:));
            [p,k] = findpeaks(tailWob(i,:),time2);
        else
        end
        p = p'; k = k';
        [k,p] = correctPeakFinder(k,p,time2,tailWob(i,:),['Tail Wobble ',num2str(i)]);
        peaks = [k,p]; peaks = sortrows(peaks);
        k = peaks(:,1); p = peaks(:,2);
        % if there are more or fewer peaks in one frame then another
        if i > 1 && length(p) ~= length(wobTailPk(:,(i-1))) && ...
                    length(k) ~= length(wobTailT(:,(i-1)))
            [mP,nP] = size(wobTailPk);
            [mK,nK] = size(wobTailT);
            [k,p,wobTailT,wobTailPk] = fixMatSize(k,p,mK,mP,wobTailT,wobTailPk);
        else
        end
        
        wobTailPk = [wobTailPk,p];
        wobTailT = [wobTailT,k];
    end
    
    Struct.tailYs = tailY;
    Struct.twistYs = twistY;
    Struct.tailWobs = tailWob;
    Struct.twistWobs = twistWob;
    Struct.twistPeaks = twistPeaks;
    Struct.twistPeakT = twistPeakT;
    Struct.wobTwistPk = wobTwistPk;
    Struct.wobTwistT = wobTwistT;
    Struct.tailPeaks = tailPeaks;
    Struct.tailPeakT = tailPeakT;
    Struct.wobTailPk = wobTailPk;
    Struct.wobTailT = wobTailT;
    close(compareFig)
end

function [k,p] = correctPeakFinder(k,p,X,Y,Title)
    activeFigure = figure;
    plot(X,Y);
    hold on
    plot(k,p,'r*');
    title(Title);
    
    prompt = {'How Many False Peaks?', 'How Many Missing Peaks?'};
    BoxName = 'FindPeak Error correction';
    default = {'0','0'};
    answer = inputdlg(prompt, BoxName,1,default);
    answer = str2num(cell2mat(answer));
    % if the user needs to eliminate points
    if answer(1) ~= 0
        % to eliminate peaks
        for i = 1:answer(1)
            rect = getrect();
            elim = find(k>rect(1) & k<(rect(1)+rect(3)));
            k(elim) = []; p(elim) = [];
            plot(k,p,'o');
        end
    else
    end
    % if the user needs to specify points
    if answer(2) ~= 0
        [x, y] = getpts();
        p = [p;y];
        k = [k;x];
        plot(k,p,'o');
    else
    end
    close(activeFigure)
end

function [k,p,kMat,pMat] = fixMatSize(k,p,mK,mP,kMat,pMat)
    if mP < length(p)
        diff = length(p)-mP;
        for i = 1:diff
            pMat = [pMat; zeros(1, size(pMat,2))];
        end
    elseif mP > length(p)
        diff = mP-length(p);
        for i = 1:diff
            p = [p;0];
        end
    else
    end
    
    if mK < length(k)
        diff = length(k)-mK;
        for i = 1:diff
            kMat = [kMat; zeros(1, size(kMat,2))];
        end
    elseif mK > length(k)
        diff = mK-length(k);
        for i = 1:diff
            k = [k;0];
        end
    else
    end
  
end

function [Yout] = fixSmoother(X,Y,Yorig)
%     plot(X,Yorig);
%     hold on
%     plot(X,Y);
    Yout = smooth(X,Yorig);
%     plot(X,Yout);
%     legend('orig','bad smooth','new smooth');
end
