% https://jp.mathworks.com/help/reinforcement-learning/ug/create-custom-reinforcement-learning-environment-in-matlab.html
function [InitialObservation, LoggedSignal] = myResetFunction(FZ)

FZ.FZreset();

X0=FZ.X;
xd0=FZ.xd;
Y0=FZ.Y;
gamma0=FZ.gamma;
alpha0=FZ.alpha;

delta0=FZ.delta0;
KL0=FZ.KL0;
HR0=FZ.HR0;



% Return initial environment state variables as logged signals.(v,X,Y,gamma,alpha,delta,KL,HR)
LoggedSignal.State = [xd0;X0;Y0;gamma0;alpha0;delta0;KL0;HR0];
InitialObservation = LoggedSignal.State;

end


