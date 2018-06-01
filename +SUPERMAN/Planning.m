function [ EP, Parameters ] = Planning
global S

if nargout < 1 % only to plot the paradigme when we execute the function outside of the main script
    S.Environement  = 'MRI';
    S.OperationMode = 'Acquisition';
end


%% Paradigme

Parameters.TrialMaxDuration            = 5.0; % seconds
Parameters.TimeSpentOnTargetToValidate = 0.5; % seconds
Parameters.MinPauseBetweenTrials       = 0.5; % seconds
Parameters.MaxPauseBetweenTrials       = 1.5; % seconds
Parameters.TimeWaitReward              = 0.5; % seconds
Parameters.RewardDisplayTime           = 1.0; % seconds


%% Define a planning <--- paradigme


% Create and prepare
header = { 'event_name', 'onset(s)', 'duration(s)' };
EP     = EventPlanning(header);

% NextOnset = PreviousOnset + PreviousDuration
NextOnset = @(EP) EP.Data{end,2} + EP.Data{end,3};

% --- Start ---------------------------------------------------------------

EP.AddStartTime('StartTime',0);

% --- Stim ----------------------------------------------------------------



EP.AddPlanning({ '' 0 0});


% --- Stop ----------------------------------------------------------------

EP.AddStopTime('StopTime',NextOnset(EP));


%% Compute gain when rewarded


%% Display

% To prepare the planning and visualize it, we can execute the function
% without output argument

if nargout < 1
    
    fprintf( '\n' )
    fprintf(' \n Total stim duration : %g seconds \n' , NextOnset(EP) )
    fprintf( '\n' )
    
    EP.Plot
    
end

end % function
