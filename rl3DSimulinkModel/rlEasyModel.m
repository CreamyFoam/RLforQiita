%%this is the main code for the model "EasyModel"
close all


run('Preload.m');

%% Choose what you want to do
NewAgent = true;%create new agent. if false:The later specified agent will be tained further(reuse of agent).
doTraining = true;%if false:run simulation
maxEpisodes = 2500;%Max number of Episodes. (Each simulation is called "Episode". )

Ts = 0.01; % Simulation step time
Tf = 300; % Simulation end time


%% Load Model
%load the Simulink file
mdl = 'EasyModel';%if Error "Unrecognized function or variable 'mdl'".=> try run this code several times
open_system(mdl)

numObs = 10;%Number of observation values.
obsInfo = rlNumericSpec([numObs 1]);
obsInfo.Name = 'observations';

numAct = 2;
actInfo = rlNumericSpec([numAct 1],'LowerLimit',[-0.1;-0.1],...
                                   'UpperLimit',[0.1 ;0.1]);%[chiDot,gammaDot] determined by the maneuverbility
actInfo.Name = 'actions';

blk = [mdl,'/RLAgent'];%install the agent which is made in this code to the agent block in simulink
env = rlSimulinkEnv(mdl,blk,obsInfo,actInfo);%making environment
env.ResetFcn = @(in) ResetFcn(in);%assign reset function which you made

%% Options
%Reuse of same agent
agentOpts = rlDDPGAgentOptions;%to save buffer of training for reuse of pretrained agent
agentOpts.SaveExperienceBufferWithAgent = true;% Reference https://jp.mathworks.com/help/reinforcement-learning/ref/rlddpgagentoptions.html?searchHighlight=SaveExperienceBufferWithAgent&s_tid=srchtitle
agentOpts.ResetExperienceBufferBeforeTraining = false;
agentOpts.NumStepsToLookAhead = 1;
agentOpts.ExperienceBufferLength  = 1e6;
%agentOpts.MiniBatchSize = 256;
agentOpts.DiscountFactor = 0.99;
agentOpts.SampleTime = 0.2;% Agent sample time. This defines the time gap between two actions. Once a set of action is given, the values will be held for Sampletime seconds 


maxSteps = floor(Tf/Ts);
trainOpts = rlTrainingOptions(...
    'MaxEpisodes',maxEpisodes,...
    'MaxStepsPerEpisode',maxSteps,...
    'ScoreAveragingWindowLength',250,...
    'Verbose',false,...
    'Plots','training-progress',...%or 'none'
    'StopTrainingCriteria','EpisodeCount',...
    'StopTrainingValue',maxEpisodes,...
    'SaveAgentCriteria','EpisodeCount',...
    'SaveAgentValue',maxEpisodes);


trainOpts.UseParallel = false;%requires at least 3 CPU cores. 
trainOpts.ParallelizationOptions.Mode = 'async';
trainOpts.ParallelizationOptions.StepsUntilDataIsSent = 32;
trainOpts.ParallelizationOptions.DataToSendFromWorkers = 'Experiences';
trainOpts.SaveAgentDirectory = "savedAgents";
trainOpts.StopOnError = "off";


%% new agent or not.

if NewAgent == true
 %agent = rlDDPGAgent(obsInfo, actInfo, agentOpts);%default agent Agent type "DDPG"
 agent = createDDPGAgent(numObs,obsInfo,numAct,actInfo,0.3); %use of agent setting of RLWalker which is an example from Mathworks. Reference https://jp.mathworks.com/help/reinforcement-learning/ug/train-biped-robot-to-walk-using-reinforcement-learning-agents.html
 %With the use of agent setting for Walker, the programs
 %"createDDPGAAgent.m" and "createNetworks.m" will be used.
else
 load('savedAgents/WPObstWP/Agent4000.mat','saved_agent'); %use of an already trained agent    %Reference https://jp.mathworks.com/matlabcentral/answers/495436-how-to-train-further-a-previously-trained-agent
 agent = saved_agent;
end

%{
%use of GPU. cannot be used in Mac.
repOpt = rlRepresentationOptions('UseDevice',"gpu");% Use of GPU. Reference https://jp.mathworks.com/help/reinforcement-learning/ref/rlrepresentationoptions.html

actorNet = getModel(getActor(agent));
actInfo = getActionInfo(agent);
actInfo.Name = 'actInfo';
obsInfo = getObservationInfo(agent);
obsInfo.Name = 'obsInfo';
actor = rlDeterministicActorRepresentation(actorNet,obsInfo,actInfo, ...
    'Observation',actInfo.Name,'Action',obsInfo.Name,repOpt);
agent = setActor(agent,actor);

criticNet = getModel(getCritic(agent));
actInfo = getActionInfo(agent);
actInfo.Name = 'actInfo';
obsInfo = getObservationInfo(agent);
obsInfo.Name = 'obsInfo';
critic = rlDeterministicActorRepresentation(criticNet,obsInfo,actInfo, ...
    'Observation',actInfo.Name,'Action',obsInfo.Name,repOpt);
agent = setCritic(agent,critic);
%}


%% Training? Simulation?

if doTraining    
    % Train the agent.
    trainingStats = train(agent,env,trainOpts);
else
    % Simulation
    % Load a pretrained agent for the selected agent type.
    load('savedAgents/WPObstWP/Agent4000.mat','agent');
    rng(0)%if values are randamised. This specifies the seed of "rand".

    simOptions = rlSimulationOptions('MaxSteps',maxSteps);
    experience = sim(env,agent,simOptions);

end