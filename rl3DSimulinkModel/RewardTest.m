%This is to show the behavior of embedded reward function
close all


f2 = figure;
[X,Y] = meshgrid(-300:300,-300:300);

Z = 20*exp(-0.00005*sqrt(X.^2+Y.^2).^2)+10*exp(-0.00005*abs(Y).^2)-10-0.0001*X.^2+10;


f2 = surf(X,Y,Z,'LineStyle','none');
xlabel('Target')
ylabel('GapToPath')