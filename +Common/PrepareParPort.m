function ParPortMessages = PrepareParPort
global S

%% On ? Off ?

switch S.ParPort
    
    case 'On'
        
        % Open parallel port
        OpenParPort;
        
        % Set pp to 0
        WriteParPort(0)
        
    case 'Off'
        
end


%% Prepare messages

msg.Start = bin2dec('1 1 0 0 0 0 0 0'); % 192
msg.Stop  = bin2dec('1 0 0 0 0 0 0 0'); % 128

msg.Dot   = bin2dec('0 0 0 0 0 0 0 1'); % 1


%% Finalize

% Pulse duration
msg.duration    = 0.003; % seconds

ParPortMessages = msg; % shortcut

end % function
