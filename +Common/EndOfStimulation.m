function TaskData = EndOfStimulation( TaskData, EP, ER, KL, SR, StartTime, StopTime )
global S

%% End of stimulation

ER.ClearEmptyEvents;
% ER.ComputeDurations; % not in this project
ER.BuildGraph;
ER.MakeBlocks;
ER.BuildGraph('block');
TaskData.ER = ER;

% KbLogger
KL.GetQueue;
KL.Stop;
switch S.OperationMode
    case 'Acquisition'
    case 'FastDebug'
        TR = 1.600; % seconds
        nbVolumes = ceil( EP.Data{end,2} / TR ) ; % nb of volumes for the estimated time of stimulation
        KL.GenerateMRITrigger( TR , nbVolumes + 2 , StartTime );
    case 'RealisticDebug'
        TR = 2.030; % seconds
        nbVolumes = ceil( EP.Data{end,2} / TR ); % nb of volumes for the estimated time of stimulation
        KL.GenerateMRITrigger( TR , nbVolumes + 2, StartTime );
    otherwise
end
KL.ScaleTime(StartTime);
KL.ComputeDurations;
KL.BuildGraph;
TaskData.KL = KL;

% SampleRecorder
SR.ClearEmptySamples
TaskData.SR = SR;

% Save some values
TaskData.StartTime = StartTime;
TaskData.StopTime  = StopTime;


%% Send infos to base workspace

assignin('base','EP',EP)
assignin('base','ER',ER)
assignin('base','KL',KL)
assignin('base','SR',SR)
assignin('base','TaskData',TaskData)


%% Close all audio devices

% % Close the audio device
% PsychPortAudio('Close');


%% Close parallel port

switch S.ParPort
    
    case 'On'
        CloseParPort;
        
    case 'Off'
        
end


%% Diagnotic

switch S.OperationMode
    
    case 'Acquisition'
        
    case 'FastDebug'
        plotDelay(EP,ER)
        
    case 'RealisticDebug'
        plotDelay(EP,ER)
        
end


end % function
