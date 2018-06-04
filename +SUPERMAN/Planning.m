function [ EP, Parameters ] = Planning( movieinfo )
global S

if nargout < 1 % only to plot the paradigme when we execute the function outside of the main script
    S.Environement  = 'MRI';
    S.OperationMode = 'Acquisition';
    movieinfo.count = 15013;
    movieinfo.fps = 25;
    S.Parameters = GetParameters();
    S.PTB.wRect = [0 0 1 1];
end


%% Paradigme

switch S.OperationMode
    case 'Acquisition'
        nrFrames = movieinfo.count;
    case 'FastDebug'
        nrFrames = round( movieinfo.count/20 );
    case 'RealisticDebug'
        nrFrames = movieinfo.count;
end

Parameters = struct; % init

vect = linspace(1,nrFrames,S.Parameters.SUPERMAN.Dot.N + 2); vect = vect(2:end-1); % pick 10 time points
vect = vect + 20*movieinfo.fps*(rand(1,S.Parameters.SUPERMAN.Dot.N) - 0.5); % add a random value from -20s to +20s
vect = round(vect);

Parameters.DotFrameOnset = vect; % frame indext @ video speed
Parameters.DotDuration   = S.Parameters.SUPERMAN.Dot.Duration/1000; % in seconds

X = linspace(S.PTB.wRect(1),S.PTB.wRect(3), S.Parameters.SUPERMAN.Dot.N + 2 ) ; X = Shuffle(round(X(2:end-1)));
Y = linspace(S.PTB.wRect(2),S.PTB.wRect(4), S.Parameters.SUPERMAN.Dot.N + 2 ) ; Y = Shuffle(round(Y(2:end-1)));
    
Parameters.DotXY = [X;Y]'; % position in pixels

Parameters.DotColor = S.Parameters.SUPERMAN.Dot.Color; % color

Parameters.DotRect = round([0 0 S.Parameters.SUPERMAN.Dot.SizeRatio*S.PTB.wRect(3) S.Parameters.SUPERMAN.Dot.SizeRatio*S.PTB.wRect(3)]);


%% Define a planning <--- paradigme


% Create and prepare
header = { 'event_name', 'onset(s)', 'duration(s)' };
EP     = EventPlanning(header);

% NextOnset = PreviousOnset + PreviousDuration
NextOnset = @(EP) EP.Data{end,2} + EP.Data{end,3};

% --- Start ---------------------------------------------------------------

EP.AddStartTime('StartTime',0);

% --- Stim ----------------------------------------------------------------

for d = 1 : S.Parameters.SUPERMAN.Dot.N
    EP.AddPlanning({ 'Dot' Parameters.DotFrameOnset(d)/movieinfo.fps Parameters.DotDuration});
end


% --- Stop ----------------------------------------------------------------

EP.AddStopTime('StopTime',movieinfo.count/movieinfo.fps);


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
