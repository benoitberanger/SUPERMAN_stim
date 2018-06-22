function [ Parameters ] = GetParameters
% GETPARAMETERS Prepare common parameters
global S

if isempty(S)
    S.Environement = 'MRI';
    S.Side         = 'Right';
end


%% Echo in command window

EchoStart(mfilename)


%% Set parameters

%%%%%%%%%%%
%  Audio  %
%%%%%%%%%%%

% Parameters.Audio.SamplingRate            = 44100; % Hz
%
% Parameters.Audio.Playback_Mode           = 1; % 1 = playback, 2 = record
% Parameters.Audio.Playback_LowLatencyMode = 1; % {0,1,2,3,4}
% Parameters.Audio.Playback_freq           = Parameters.Audio.SamplingRate ;
% Parameters.Audio.Playback_Channels       = 2; % 1 = mono, 2 = stereo
%
% Parameters.Audio.Record_Mode             = 2; % 1 = playback, 2 = record
% Parameters.Audio.Record_LowLatencyMode   = 0; % {0,1,2,3,4}
% Parameters.Audio.Record_freq             = Parameters.Audio.SamplingRate;
% Parameters.Audio.Record_Channels         = 1; % 1 = mono, 2 = stereo


%%%%%%%%%%%%%%
%   Screen   %
%%%%%%%%%%%%%%
% Prisma scanner @ CENIR
Parameters.Video.ScreenWidthPx   = 1024;  % Number of horizontal pixel in MRI video system @ CENIR
Parameters.Video.ScreenHeightPx  = 768;   % Number of vertical pixel in MRI video system @ CENIR
Parameters.Video.ScreenFrequency = 60;    % Refresh rate (in Hertz)
Parameters.Video.SubjectDistance = 0.120; % m
Parameters.Video.ScreenWidthM    = 0.040; % m
Parameters.Video.ScreenHeightM   = 0.030; % m

Parameters.Video.ScreenBackgroundColor = [128 128 128]; % [R G B] ( from 0 to 255 )

%%%%%%%%%%%%
%   Text   %
%%%%%%%%%%%%
Parameters.Text.SizeRatio   = 0.03; % Size = ScreenWide *ratio
Parameters.Text.Font        = 'Arial';
Parameters.Text.Color       = [128 128 128]; % [R G B] ( from 0 to 255 )
Parameters.Text.ClickCorlor = [0   255 0  ]; % [R G B] ( from 0 to 255 )


%%%%%%%%%%%%
% SUPERMAN %
%%%%%%%%%%%%

% Video
Parameters.SUPERMAN.Dot.N         = 10;          % 10 for 10min video means 1 per minute
Parameters.SUPERMAN.Dot.SizeRatio = 5/100;       % Size = ScreenWide *ratio
Parameters.SUPERMAN.Dot.Color     = [255 0 255]; % [R G B] ( from 0 to 255 )
Parameters.SUPERMAN.Dot.Duration  = 250;         % milliseconds
% right now videos are @25Hz, so 2 or 3 frames for screen @60Hz.
% 100ms is 6 frames, a multiple of 2 and 3

% Fixation cross
Parameters.SUPERMAN.FixationCross.ScreenRatio    = 0.10;          % ratio : dim   = ScreenWide *ratio_screen
Parameters.SUPERMAN.FixationCross.lineWidthRatio = 0.05;          % ratio : width = dim        *ratio_width
Parameters.SUPERMAN.FixationCross.Color          = [0 0 0]; % [R G B] ( from 0 to 255 )

%%%%%%%%%%%%%%%%
% RestingState %
%%%%%%%%%%%%%%%%

% Fixation cross
Parameters.RestingState = Parameters.SUPERMAN;

%%%%%%%%%%%%%%
%  Keybinds  %
%%%%%%%%%%%%%%

KbName('UnifyKeyNames');

Parameters.Keybinds.TTL_t_ASCII          = KbName('t'); % MRI trigger has to be the first defined key
% Parameters.Keybinds.emulTTL_s_ASCII      = KbName('s');
Parameters.Keybinds.Stop_Escape_ASCII    = KbName('ESCAPE');


switch S.Side
    
    case 'Left'
        
        switch S.Environement
            
            case 'MRI'
                
                Parameters.Fingers.ID  = KbName('y');
                
            case 'Practice'
                
                Parameters.Fingers.ID  = KbName('LeftArrow' );
                
        end
        
        Parameters.Fingers.Names = {'Left'};
        
    case 'Right'
        
        switch S.Environement
            
            case 'MRI'
                
                Parameters.Fingers.ID = KbName('b');
                
            case 'Practice'
                
                Parameters.Fingers.ID = KbName('RightArrow');
                
        end
        
        Parameters.Fingers.Names = {'Right'};
        
end




%% Echo in command window

EchoStop(mfilename)


end