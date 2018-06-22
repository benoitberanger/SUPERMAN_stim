function TaskData = Task(Category, Movie)
global S

TaskData = struct;

try
    %% Fixation cross
    
    dim   = round(S.PTB.wRect(4)*S.Parameters.SUPERMAN.FixationCross.ScreenRatio);
    width = round(dim * S.Parameters.SUPERMAN.FixationCross.lineWidthRatio);
    color = S.Parameters.SUPERMAN.FixationCross.Color;
    
    Cross = FixationCross(...
        dim   ,...                       % dimension in pixels
        width ,...                       % width     in pixels
        color ,...                       % color     [R G B] 0-255
        [S.PTB.CenterH S.PTB.CenterV] ); % center    in pixels
    
    Cross.LinkToWindowPtr( S.PTB.wPtr )
    
    Cross.AssertReady % just to check
    
    
    %% Open movie
    
    moviename = fullfile(fileparts(pwd), 'video', Category, [Movie S.ext]);
    TaskData.moviename = moviename;
    
    win = S.PTB.wPtr;
    
    % Open movie file:
    [movie,movieinfo.duration,movieinfo.fps,movieinfo.width,movieinfo.height,movieinfo.count,movieinfo.aspectRatio]= ...
        Screen('OpenMovie', win, moviename);
    TaskData.movieinfo = movieinfo;
    
    SR = SampleRecorder( { 'time (s)', 'frame index' } , round(movieinfo.count*1.20) ); % ( duration of the task +20% )
    
    
    %% Tunning of the task
    
    [ EP, Parameters ]  = SUPERMAN.Planning(movieinfo);
    TaskData.Parameters = Parameters;
    
    % End of preparations
    EP.BuildGraph;
    TaskData.EP = EP;
    
    [ ER, KL ] = Common.PrepareRecorders( EP );
    
    
    %% Eyelink
    
    Common.StartRecordingEyelink
    
    
    %% Wait for start
    
    frame_counter = 0;
    
    Cross.Draw
    Cross.Flip
    StartTime = Common.StartTimeEvent();
    ffprintf('... Trigger received \n')
    
    
    %% Fixation Cross
    
    flipOnset = StartTime;
    
    while flipOnset < StartTime + Parameters.CrossDuration - S.PTB.slack
        
        frame_counter = frame_counter + 1;
        
        Cross.Draw
        
        % Update display:
        flipOnset = Screen('Flip', win);
        SR.AddSample([flipOnset-StartTime frame_counter])
        
        if frame_counter == 1
            Common.SendParPortMessage( 'Cross' )
            ER.AddEvent({'Cross' flipOnset-StartTime []})
        end
        
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
    
    
    %% Start movie
    
    % Start playback engine:
    Screen('PlayMovie', movie, 1);
    
    
    %% Go movie ! Go !
    
    draw_dot      = 0;
    dot_counter   = 0;
    movie_frame_counter = 0;
    
    % Playback loop: Runs until end of movie or keypress:
    while 1
        
        frame_counter = frame_counter + 1;
        movie_frame_counter = movie_frame_counter + 1;
        
        % Wait for next movie frame, retrieve texture handle to it
        tex = Screen('GetMovieImage', win, movie);
        
        % Valid texture returned? A negative value means end of movie reached:
        if tex<=0
            % We're done, break out of loop:
            break;
        end
        
        % Draw the new texture immediately to screen:
        Screen('DrawTexture', win, tex);
        
        % Need to draw dot ?
        if any(movie_frame_counter == Parameters.DotFrameOnset)
            draw_dot = 2;
            dot_counter = dot_counter + 1;
        end
        
        if draw_dot
            Screen('FillOval',  win, Parameters.DotColor, CenterRectOnPoint( Parameters.DotRect , Parameters.DotXY(dot_counter,1),Parameters.DotXY(dot_counter,2) )     )
            Screen('FrameOval', win, [0 0 0],             CenterRectOnPoint( Parameters.DotRect , Parameters.DotXY(dot_counter,1),Parameters.DotXY(dot_counter,2) ) , 1 ) % frame is 1 pixel thick
        end
        
        % Update display:
        flipOnset = Screen('Flip', win);
        SR.AddSample([flipOnset-StartTime movie_frame_counter])
        
        % Release texture:
        Screen('Close', tex);
        
        % record Cross real duration
        if movie_frame_counter == 1
            Common.SendParPortMessage( 'MovieStart' )
            ER.Data{ER.EventCount,3} = flipOnset - StartTime - ER.Data{ER.EventCount,2};
            ER.AddEvent({'MovieStart' flipOnset-StartTime 0})
        end
        
        % Store dot onset
        if draw_dot == 2
            Common.SendParPortMessage( 'Dot' )
            dot_onset = flipOnset;
            draw_dot = 1;
            ER.AddEvent({'Dot' dot_onset-StartTime []})
            fprintf('Dot @ %3.3fs \n', dot_onset-StartTime)
        end
        
        % End of movie
        if draw_dot == 0 && dot_counter == length(Parameters.DotFrameOnset)
            if strcmp(S.OperationMode,'FastDebug')
                break
            end
        end
        
        % Only draw the dot for somes frames
        if draw_dot
            if flipOnset - dot_onset >= Parameters.DotDuration
                
                draw_dot = 0;
                ER.Data{ER.EventCount,3} =  flipOnset - dot_onset; % adjust real dut duration
                
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Fetch keys
        [keyIsDown, ~, keyCode] = KbCheck;
        if keyIsDown
            % ~~~ ESCAPE key ? ~~~
            
            if keyCode(S.Parameters.Keybinds.Stop_Escape_ASCII)
                fprintf( 'ESCAPE key pressed \n')
                break
            elseif keyCode(S.Parameters.Fingers.ID)
                fprintf(' Tap @ %3.3fs \n', flipOnset-StartTime)
            end
            
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
    end
    
    
    %% Stop movie
    
    Common.SendParPortMessage( 'MovieStop' )
    ER.AddEvent({'MovieStop' flipOnset-StartTime 0})
    
    % Stop playback:
    Screen('PlayMovie', movie, 0);
    
    % Close movie:
    Screen('CloseMovie', movie);
    
    
    %% Fixation Cross
    
    lastFrameOnset = flipOnset;
    rec = 1;
    
    while flipOnset < lastFrameOnset + Parameters.CrossDuration - S.PTB.slack
        
        frame_counter = frame_counter + 1;
        
        Cross.Draw
        
        % Update display:
        flipOnset = Screen('Flip', win);
        SR.AddSample([flipOnset-StartTime frame_counter])
        
        if rec
            Common.SendParPortMessage( 'Cross' )
            ER.AddEvent({'Cross' flipOnset-StartTime []})
            rec = 0;
        end
        
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
    
    
    %% End of stimulation
    
    StopTime = Screen('Flip', win); % Flip screen : grey screen
    ER.Data{ER.EventCount,3} = StopTime - StartTime - ER.Data{ER.EventCount,2}; % adjust last fixation real duration
    
    Common.StopTimeEvent( ER, StartTime, StopTime )
    
    TaskData = Common.EndOfStimulation( TaskData, EP, ER, KL, SR, StartTime, StopTime );
    
    
catch err
    Common.Catch(err)
end


end % functuion
