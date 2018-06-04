function TaskData = Task(Category, Movie)
global S

TaskData = struct;

try
    %% Open movie
    
    moviename = fullfile(fileparts(pwd), 'video', Category, [Movie S.ext]);
    TaskData.moviename = moviename;
    
    win = S.PTB.wPtr;
    
    % Open movie file:
    [movie,movieinfo.duration,movieinfo.fps,movieinfo.width,movieinfo.height,movieinfo.count,movieinfo.aspectRatio]= ...
        Screen('OpenMovie', win, moviename);
    TaskData.movieinfo = movieinfo;
    
    SR = SampleRecorder( { 'time (s)', 'frame index' } , round(movieinfo.count*1.20) ); % ( duration of the task +20% )
    frame_counter = 0;
    
    
    %% Tunning of the task
    
    [ EP, Parameters ] = SUPERMAN.Planning(movieinfo);
    TaskData.Parameters = Parameters;
    
    % End of preparations
    EP.BuildGraph;
    TaskData.EP = EP;
    
    [ ER, KL ] = Common.PrepareRecorders( EP );
    
    
    %% Eyelink
    
    Common.StartRecordingEyelink
    
    
    %% Wait for start
    
    % Start playback engine:
    Screen('PlayMovie', movie, 1);
    
    StartTime = Common.StartTimeEvent();
    
    
    %% Go !
    
    % Playback loop: Runs until end of movie or keypress:
    while 1
        
        % Wait for next movie frame, retrieve texture handle to it
        tex = Screen('GetMovieImage', win, movie);
        
        % Valid texture returned? A negative value means end of movie reached:
        if tex<=0
            % We're done, break out of loop:
            break;
        end
        
        % Draw the new texture immediately to screen:
        Screen('DrawTexture', win, tex);
        
        
        % Update display:
        flipOnset = Screen('Flip', win);
        frame_counter = frame_counter + 1;
        SR.AddSample([flipOnset-StartTime frame_counter])
        
        % Release texture:
        Screen('Close', tex);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Fetch keys
        [keyIsDown, ~, keyCode] = KbCheck;
        if keyIsDown
            % ~~~ ESCAPE key ? ~~~
            
            if keyCode(S.Parameters.Keybinds.Stop_Escape_ASCII)
                fprintf( 'ESCAPE key pressed \n')
                break
            end
            
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
    end
    
    
    %% Stop
    
    % Stop playback:
    Screen('PlayMovie', movie, 0);
    
    % Close movie:
    Screen('CloseMovie', movie);
    
    
    
    
    %% End of stimulation
    
    StopTime = flipOnset;
    
    Common.StopTimeEvent( ER, StartTime, StopTime )
    
    TaskData = Common.EndOfStimulation( TaskData, EP, ER, KL, SR, StartTime, StopTime );
    
    
catch err
    Common.Catch(err)
end


end % functuion
