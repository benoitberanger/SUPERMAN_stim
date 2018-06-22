function TaskData = Task
global S

TaskData = struct;

try
    %% Fixation cross
    
    dim   = round(S.PTB.wRect(4)*S.Parameters.RestingState.FixationCross.ScreenRatio);
    width = round(dim * S.Parameters.RestingState.FixationCross.lineWidthRatio);
    color = S.Parameters.RestingState.FixationCross.Color;
    
    Cross = FixationCross(...
        dim   ,...                       % dimension in pixels
        width ,...                       % width     in pixels
        color ,...                       % color     [R G B] 0-255
        [S.PTB.CenterH S.PTB.CenterV] ); % center    in pixels
    
    Cross.LinkToWindowPtr( S.PTB.wPtr )
    
    Cross.AssertReady % just to check
    
    
    %% Tunning of the task
    
    [ EP ]  = RestingState.Planning();
    
    % End of preparations
    EP.BuildGraph;
    TaskData.EP = EP;
    
    [ ER, KL ] = Common.PrepareRecorders( EP );
    SR = SampleRecorder( { 'time (s)', 'frame index' } , 10 ); % ( duration of the task +20% )

    
    %% Eyelink
    
    Common.StartRecordingEyelink
    
    
    %% Wait for start
    
    Cross.Draw
    Cross.Flip
    StartTime = Common.StartTimeEvent();
    ffprintf('... Trigger received \n')
    
    
    %% Fixation Cross
    
    secs = StartTime;
    
    while secs < StartTime + 620
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Fetch keys
        [keyIsDown, secs, keyCode] = KbCheck;
        if keyIsDown
            % ~~~ ESCAPE key ? ~~~
            
            if keyCode(S.Parameters.Keybinds.Stop_Escape_ASCII)
                fprintf( 'ESCAPE key pressed \n')
                break
            end
            
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
    end
    
    
    %% End of stimulation
    
    StopTime = Screen('Flip', S.PTB.wPtr); % Flip screen : grey screen
    
    Common.StopTimeEvent( ER, StartTime, StopTime )
    
    TaskData = Common.EndOfStimulation( TaskData, EP, ER, KL, SR, StartTime, StopTime );
    
    
catch err
    Common.Catch(err)
end


end % functuion
