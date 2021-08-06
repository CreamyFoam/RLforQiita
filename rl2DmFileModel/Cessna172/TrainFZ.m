clear all;
close all;

%% parameters

X0=0;
xd0=55;
gamma0=0;
alpha0=0;
q0=0;
Xmax=4000;
Ymax=2000;
RO=200;

%% time setting
Ts = 0.05;
Tf = 100;
NumberOfSteps = [0:Ts:Tf];
SPS = length([0:Ts:1]);%Steps per second

%% creating class of FZ
FZ=classFZ(Ts,Tf,X0,xd0,gamma0,q0,alpha0,RO,Xmax,Ymax);

%% Definition of the size of observation and its limit (v,X,Y,gamma,alpha,delta,KL,HR)
ObservationInfo = rlNumericSpec([8, 1],'LowerLimit',[0  ;0   ;0   ;-pi/3 ;-pi/3 ;0     ;0   ;-pi/9],...
                                       'UpperLimit',[100;Xmax;Ymax;pi/3  ;pi/3  ;1     ;0.2 ;pi/9]);
                                                  %(v  ,X   ,Y   ,gamma ,alpha ,delta ,KL  ,HR)
%% Definition of the size of action and its limit (delta,KL,HR)
ActionInfo = rlNumericSpec([3, 1],'LowerLimit',[-1/SPS; -0.2/SPS/5 ;-(pi/15+pi/15)/SPS/3],...
                                  'UpperLimit',[1/SPS ; 0.2/SPS/5  ;(pi/15+pi/15)/SPS/3]);



%% Definition of Reset and Step function
ResetHandle = @()myResetFunction(FZ);
StepHandle = @(Action,LoggedSignals) myStepFunction(Action,LoggedSignals,FZ);

%% Definition of Env. and Agent
env = rlFunctionEnv(ObservationInfo, ActionInfo, StepHandle, ResetHandle);
agent = rlDDPGAgent(ObservationInfo, ActionInfo);

%% Set ups of agent
%{
agent.AgentOptions.EpsilonGreedyExploration.Epsilon = 0.95;
agent.AgentOptions.EpsilonGreedyExploration.EpsilonDecay = 0.0001;
agent.AgentOptions.EpsilonGreedyExploration.EpsilonMin = 0.1;
%}

%% Training options
MaxEpisodes=1000;
opt = rlTrainingOptions("MaxEpisodes",MaxEpisodes,...
    "MaxStepsPerEpisode",length(NumberOfSteps),...%"MaxStepsPerEpisode",length(NumberOfSteps),...
    "StopTrainingCriteria","AverageReward",...
    "StopTrainingValue",100000,...
    "ScoreAveragingWindowLength",50,...
    'SaveAgentCriteria','EpisodeCount',...
    'SaveAgentValue',MaxEpisodes);%"UseParallel", false,...

%Resuse of same agent
agentOpts = rlDDPGAgentOptions;   %to save buffer of training for reuse of the agent
agentOpts.SaveExperienceBufferWithAgent = true;   % Reference https://jp.mathworks.com/help/reinforcement-learning/ref/rlddpgagentoptions.html?searchHighlight=SaveExperienceBufferWithAgent&s_tid=srchtitle
agentOpts.ResetExperienceBufferBeforeTraining = false;%
agentOpts.NumStepsToLookAhead = 1;

repOpt = rlRepresentationOptions('UseDevice',"gpu");
%% Do the Training or Simulation
doTraining = true;
if doTraining == true
    % Train the agent.
    trainingStats = train(agent,env,opt);
else
    load('savedAgents/Agent300.mat','saved_agent')
    simOpts = rlSimulationOptions('MaxSteps',200,"NumSimulations",1);
    experience = sim(env,agent,simOpts);
end

