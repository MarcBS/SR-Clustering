function [h]=VisualBinFunction(Nimages,man_limits,auto_limits,adwin_limits)
ymin=-5; ymax=5;

%man_limits: vector con inicio de cada cluster. A partir del Excel 
x1=-(ones(1,Nimages));
for i=2:2:length(man_limits)-1
    x1(man_limits(i):(man_limits(i+1)-1))=1;
end
%auto_limits: man_limits,auto_limits. A partir del clustering
x2=-(ones(1,Nimages));
for i=2:2:length(auto_limits)-1
    x2(auto_limits(i):(auto_limits(i+1)-1))=1;
end

x3=-(ones(1,Nimages));
for i=2:2:length(adwin_limits)-1
    x3(adwin_limits(i):(adwin_limits(i+1)-1))=1;
end
X=1:1:Nimages;
y1=1*x1;
y2=2*x2;
y3=3*x3;
h=figure('visible','off'),
stairs(X,y1,'b','LineStyle','--', 'Marker','s','MarkerFaceColor','blue'),ylim([ymin ymax]),
title('Grountruth vs Clustering Representation'), xlabel('Nframes')
hold on
stairs(X,y2,'r', 'Marker','s','MarkerFaceColor','red'),ylim([ymin ymax]),
hold on
stairs(X,y3,'g', 'Marker','s','MarkerFaceColor','green'),ylim([ymin ymax]),