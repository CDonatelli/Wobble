% wooorrrkkkk
function [MaxWobble MeanWobble] = WobblePlot(DVC, LVC, Dvals, Midlines)

%     DVC = input('DV cords: ');
%     LVC = input('LV cords: ');
%     Dvals = input('Thickness vals: ');
      SWScale = input('Swimming Scale: ');
      Lbl = input('Prefix for outputs: ');

    DorsalPoly = polyfit(DVC(:,1), DVC(:,2),3);   % apply poly fit to Dorsal and 
    LateralPoly = polyfit(LVC(:,1), LVC(:,2),3);   % Lateral views. gives coeficients 
    x1 = 1:DVC(end,1); x2 = 1:LVC(end,1); % of best fit line
    y1 = DorsalPoly(1).*x1.^3 + DorsalPoly(2).*x1.^2 + DorsalPoly(3).*x1 + DorsalPoly(4); % get y vals of
    y2 = LateralPoly(1).*x2.^3 + LateralPoly(2).*x2.^2 + LateralPoly(3).*x2 + LateralPoly(4); % best fit lines
    figure(1);                                            % for both views
    plot(LVC(:,1), LVC(:,2), 'r'); hold on  % plot the best fit lines vs              
    plot(DVC(:,1), DVC(:,2), 'r');hold on   % the thickness of each view
    plot(x1,y1); hold on                    % measured with ImageThickness()
    plot(x2,y2, 'k'); hold on
    legend('Lateral Thickness','Dorsal Thickness', 'Lateral fit', 'Dorsal fit');

    MeasuredWidth = [];
    for i = 1:length(Dvals)
        Dvals(i).Scaled = (Dvals(i).Thick)/SWScale; % apply the scale to video width...lateral and dorsal are already scaled
        for j = 1:length(Dvals(i).Thick)
            MeasuredWidth(i,j) = Dvals(i).Scaled(j); 
        end % Create an array of thicknesses. Each column in averages() will                          
    end     % be the thickness measurements from every frame at one point 
            % along the midline (computed with MidlineCust and FishRadGet)
    [m n] = size(MeasuredWidth);
    PlotAvg = [];
    
    for Frame = 1:m
        for MidCoord = 2:n
            if MeasuredWidth(Frame,MidCoord) ~= 0    
                X = CurrentPosition(Frame,MidCoord, Midlines)/SWScale;
                Wobble(Frame,MidCoord) = (MeasuredWidth(Frame,MidCoord)-Width(DorsalPoly,X)) /...
                    ((Height(LateralPoly, X) - MeasuredWidth(Frame,MidCoord)) * ...
                    (MeasuredWidth(Frame,MidCoord) - Width(DorsalPoly, X)));
            else
                break
            end
        end
    end
    %because the image data and the thickness data are suboptimal there are
    %still some spurious values.  Let's set obious screw ups to 0
    %These two lines shoudl do less and less as the image data are
    %better and better.
    size(Wobble(Wobble>1),1) %show how many bad values there are
    size(Wobble(Wobble<0),1)
    Wobble(Wobble<0)=0;
    Wobble(Wobble>1)=0;
    
    %compute teh average and teh mean wobble.  This is very simple minded
    %in that it assumes the matrix position is equivalent to a percent
    %along the body.  As teh prior code is written this is close to true
    %but not true.  Earlier code needs to be rewritten to produce a midline
    %matrix that has evenly spaced centers
    MeanWobble = mean(Wobble,1);
    Wobble9 = prctile(Wobble,90);
    
    hold off;   %new plot
    plot(Wobble9,'or');
    hold on;
    plot(MeanWobble,'ob');
    eval(sprintf('%s=%s',[Lbl,'MeanWobble'],'MeanWobble'));          % rename output
    save([[Lbl,'MeanWobble'], '.mat'],[Lbl,'MeanWobble']);         % save midline data
    eval(sprintf('%s=%s',[Lbl,'Wobble9'],'Wobble9'));          % rename output
    save([[Lbl,'Wobble9'], '.mat'],[Lbl,'Wobble9']);         % save midline data
   

    
    

function w = Width(p,x)  % use the coeficients from polyval to calculate the
                       % width of the fish at a given posion along its body
    w = p(1)*x^3 + p(2)*x^2 + p(3)*x + p(4);

function h = Height(p,x)  % use the coeficients from polyval to calculate the
                       % height of the fish at a given posion along its body
    h = p(1)*x^3 + p(2)*x^2 + p(3)*x + p(4);
    
   
%Returns the straightened length of the fish at midiline position MidCoord 
%in the image Frame by adding the lengths of the distances between midline segments.    
function Position = CurrentPosition(Frame,MidCoord, Midlines)

Position = 0;
for i = 2:MidCoord
    Position = Position +...
        ((Midlines(Frame).MidLine(i-1,1) - Midlines(Frame).MidLine(i,1))^2+...
        ((Midlines(Frame).MidLine(i-1,2) - Midlines(Frame).MidLine(i,2))^2))^.5;
end

