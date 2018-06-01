function [ ER, RR, KL, BR] = PrepareRecorders( EP )
global S

%% Prepare event record

% Create
ER = EventRecorder( EP.Header(1:3) , EP.EventCount );

% Prepare
ER.AddStartTime( 'StartTime' , 0 );


%% Response recorder

% Create
RR = EventRecorder( { 'event_name' , 'onset(s)' , 'duration(s)' , 'content' } , 5000 ); % high arbitrary value : preallocation of memory

% Prepare
RR.AddStartTime( 'StartTime' , 0 );


%% Behaviour recorder

% Create

switch S.Task
    case 'STOPSIGNAL'
        BR = EventRecorder( { 'event_name' , 'Go/Stop', 'Left/Right', 'StopSignalDelay (ms)' , 'ReactionTime (ms)' 'Side (Left/Right)'} , EP.EventCount-2 ); % high arbitrary value : preallocation of memory
    case 'LIKERT'
        BR = EventRecorder( { 'event_name' , 'ReactionTime (ms)' , 'Likert_value [0-7]' } , EP.EventCount-2 ); % high arbitrary value : preallocation of memory
end


%% Prepare the logger of MRI triggers

KbName('UnifyKeyNames');

switch S.Task
    case 'STOPSIGNAL'
        KL = KbLogger( ...
            [ struct2array(S.Parameters.Keybinds) S.Parameters.Fingers.Left S.Parameters.Fingers.Right ] ,...
            [ KbName(struct2array(S.Parameters.Keybinds)) S.Parameters.Fingers.Names ] );
    case 'LIKERT'
        KL = KbLogger( ...
            [ struct2array(S.Parameters.Keybinds) S.Parameters.Fingers.Left S.Parameters.Fingers.Validate S.Parameters.Fingers.Right ] ,...
            [ KbName(struct2array(S.Parameters.Keybinds)) S.Parameters.Fingers.Names ] );
end


% Start recording events
KL.Start;


end % function
