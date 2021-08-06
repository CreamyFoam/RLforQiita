clear all;
close all;

% parameters
X0=0;
Y0=1800;
xd0=55;
gamma0=0;
alpha0=0;
q0=0;
Xmax=4000;
Ymax=2000;
RO=200;

% time setting
Ts = 0.05;
Tf = 20;
t1 = [0:Ts:Tf];

% creating class of FZ
FZ=classFZ(Ts,Tf,X0,xd0,gamma0,q0,alpha0,RO,Xmax,Ymax);

%% the movement of FZ
delta=0.6;
KL=0;
HR=-0.05*pi;
for i = 1:length(t1)

    if i<200
    FZ.FZstep(delta,KL,0);
    
    else
    FZ.FZstep(delta,KL,HR);
    
    end
end

hold off

FZ.FZreset();

for i = 1:length(t1)
FZ.FZstep(delta,KL,HR);
end
