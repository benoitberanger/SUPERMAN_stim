function [ ER, KL ] = PrepareRecorders( EP )
global S

%% Prepare event record

% Create
ER = EventRecorder( EP.Header(1:3) , EP.EventCount );

% Prepare
ER.AddStartTime( 'StartTime' , 0 );


%% Prepare the logger of MRI triggers

KbName('UnifyKeyNames');

KL = KbLogger( ...
    [ struct2array(S.Parameters.Keybinds) S.Parameters.Fingers.ID ] ,...
    [ KbName(struct2array(S.Parameters.Keybinds)) S.Parameters.Fingers.Names ] );

% Start recording events
KL.Start;


end % function
