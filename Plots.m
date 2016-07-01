% Plots

%%%%% Kinematics Pannel Plot
subplot(3,3,2)
    hist(Arr(:,2))
    title('Bending Frequency')
subplot(3,3,3)
    hist(Arr(:,7))
    title('Wobble Frequency')
subplot(3,3,1)
    plot(Arr(:,1),Arr(:,2),'*',Arr(:,1),Arr(:,7),'*')
    hold on
    p1 = polyfit (Arr(:,1),Arr(:,2),1);
    p2 = polyfit (Arr(:,1),Arr(:,7),1);
    x = linspace(min(Arr(:,1)), max(Arr(:,1)),100);
    y1 = p1(1).*x + p1(2);
    y2 = p2(1).*x + p2(2);
    plot(x,y1,'b')
    plot(x,y2,'r')
    xlabel('Swimming Speed')
    ylabel('Frequency')
    legend('Bending','Wobble')
subplot(3,3,5)
    hist(Arr(:,6))
    title('Bending Amplitude')
subplot(3,3,6)
    hist(Arr(:,11))
    title('Wobble Amplitude')
subplot(3,3,4)   
    p3 = polyfit (Arr(:,1),Arr(:,6),1);
    p4 = polyfit (Arr(:,1),Arr(:,11),1);
    y3 = p3(1).*x + p3(2);
    y4 = p4(1).*x + p4(2);
    plot(Arr(:,1),Arr(:,6),'*')
    yyaxis right
    plot(Arr(:,1),Arr(:,11),'*')
    hold on
    plot(x,y4,'r')
    yyaxis left
    hold on
    plot(x,y3,'b')
    xlabel('Swimming Speed')
    ylabel('Bending Amplitude (mm)')
    yyaxis right
    ylabel('Wobble Amplitude')
subplot(3,3,8)
    hist(Arr(:,4))
    title('Bending Stride Length')
subplot(3,3,9)
    hist(Arr(:,9))
    title('Wobble Stride Length')
subplot(3,3,7)
    plot(Arr(:,1), Arr(:,4), '*', Arr(:,1), Arr(:,9),'*')
    p5 = polyfit (Arr(:,1),Arr(:,4),1);
    p6 = polyfit (Arr(:,1),Arr(:,9),1);
    y5 = p5(1).*x + p5(2);
    y6 = p6(1).*x + p6(2);
    hold on
    plot(x,y5,'b',x,y6,'r')
    xlabel('Swimming Speed')
    ylabel('Stride Length')
   