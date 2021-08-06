function [NextObs,Reward,IsDone,LoggedSignals] = myStepFunction(Action, LoggedSignals,FZ)


%% Previous State, obtaining the state BEFORE next action
%v,X,Y,gamma,alpha,delta,KL,HR
    statePre = [0;0;0;0;0;0;0;0]; %I dont know if statePre is needed. But often written in examples
               
    statePre(1) = FZ.xd;
    statePre(2) = FZ.X;
    statePre(3) = FZ.Y;
    statePre(4) = FZ.gamma;
    statePre(5) = FZ.alpha;
    statePre(6) = FZ.delta;
    statePre(7) = FZ.KL;
    statePre(8) = FZ.HR;
    
    deltaPre = FZ.delta;
    KLPre = FZ.KL;
    HRPre = FZ.HR;
    
    DistancePre = FZ.Distance;

%% Action
    
    if deltaPre+Action(1)<0 || deltaPre+Action(1)>1
        delta = deltaPre;
    else
        delta = deltaPre+Action(1);
    end
    
    
    useKP=true;%choose, if KL will be used(true) or not(false)
    if useKP == true
        if KLPre+Action(2)<0 || KLPre+Action(2)>0.2
            KL = KLPre;
        else
            KL = KLPre+Action(2);
        end
    else
        KL=0;%KL has a enomous effect on climb.
    end
    
    
    if HRPre+Action(3)<-pi/15 || HRPre+Action(3)>pi/15
        HR = HRPre;
    else
        HR = HRPre+Action(3);
    end
    
    FZ.FZstep(delta,KL,HR);
    
%% State update, obtaining the state AFTER the action
    state = [0;0;0;0;0;0;0;0];
             
    state(1) = FZ.xd;
    state(2) = FZ.X;
    state(3) = FZ.Y;
    state(4) = FZ.gamma;
    state(5) = FZ.alpha;
    state(6) = FZ.delta;
    state(7) = FZ.KL;
    state(8) = FZ.HR;
    LoggedSignals.State = state;
    
    delta = FZ.delta;
    KL = FZ.KL;
    HR = FZ.HR;
    
    
    Distance = FZ.Distance;
    
%% Next Observation
    NextObs = LoggedSignals.State;

%% Check terminal condition
    if FZ.X>FZ.XG
        IsDone = true;
        TerminationPenalty = 0;
    elseif FZ.Y<0
        IsDone = true;
        TerminationPenalty = -100;
    elseif FZ.Y>FZ.Ymax
        IsDone = true;
        TerminationPenalty = -100;
    elseif abs(FZ.gamma)>pi/4
        IsDone = true;
        TerminationPenalty = -500;
    elseif FZ.xd<15
        IsDone = true;
        TerminationPenalty = -100;
    elseif abs(FZ.alpha)>pi/4
        IsDone = true;
        TerminationPenalty = -100;
    elseif norm([FZ.X, FZ.Y]-[FZ.XO, FZ.YO])<FZ.RO
        IsDone = true;
        TerminationPenalty = -500;
    else
        IsDone = false;
        TerminationPenalty = 0;
    end


%% Calculation of Reward
    %getting closer to the Goal
    Closer = 1000/(norm([FZ.X, FZ.Y]-[FZ.XG, FZ.YG])+1);
    %Closer = 5*(DistancePre - Distance);
    
    %flying longer without termination
    TimeBonus = 100 * FZ.Ts/FZ.Tf;
    
    %navigation in X direction
    XNavigation = 100 * FZ.X/FZ.Xmax;
    
    %input penalty
    InputPenalty = -10*abs(delta-deltaPre) -500*abs(KL-KLPre) -10*abs(HR-HRPre);

    %%Calculation of Reward
    Reward = Closer + TimeBonus + XNavigation + InputPenalty + TerminationPenalty;
    

end