function TaskData = Task
global S

TaskData = struct;

try
    %% Open movie
    
    moviename = fullfile(fileparts(pwd), 'video', S.Category, [S.Movie S.ext]);
    TaskData.moviename = moviename;
    
    win = S.PTB.wPtr;
    
    % Open movie file:
    [movie,movieinfo.duration,movieinfo.fps,movieinfo.width,movieinfo.height,movieinfo.count,movieinfo.aspectRatio]= ...
        Screen('OpenMovie', win, moviename);
    TaskData.movieinfo = movieinfo;
    
    
    %% Tunning of the task
    
    KbName('UnifyKeyNames'); % because we use ESCAPE to quit
    
    Parameters = S.TaskData.Parameters;
    
    S.OperationMode = 'FastDebug'; % to skip MRI trigger
    
    
    %% Wait for start
    
    StartTime = Common.StartTimeEvent();
    ffprintf('... Trigger received \n')
    
    
    %% Start movie
    
    % Start playback engine:
    Screen('PlayMovie', movie, 1);
    
    
    %% Go movie ! Go !
    
    draw_dot      = 0;
    dot_counter   = 0;
    movie_frame_counter = 0;
    flipOnset = 0;
    
    PD = S.data.trial{1}(4,:);
    PD = PD / max(PD) * Parameters.DotRect(3);
    
    % Playback loop: Runs until end of movie or keypress:
    while 1
        
        movie_frame_counter = movie_frame_counter + 1;
        
        % Wait for next movie frame, retrieve texture handle to it
        tex = Screen('GetMovieImage', win, movie);
        
        % Valid texture returned? A negative value means end of movie reached:
        if tex<=0
            % We're done, break out of loop:
            break;
        end
        
        % Draw the new texture immediately to screen:
        Screen('DrawTexture', win, tex, [], S.PTB.wRect);
        
        % Need to draw dot ?
        if any(movie_frame_counter == Parameters.DotFrameOnset)
            draw_dot = 2;
            dot_counter = dot_counter + 1;
        end
        
        if draw_dot
            Screen('FillOval',  win, Parameters.DotColor, CenterRectOnPoint( Parameters.DotRect , Parameters.DotXY(dot_counter,1),Parameters.DotXY(dot_counter,2) )     )
            Screen('FrameOval', win, [0 0 0],             CenterRectOnPoint( Parameters.DotRect , Parameters.DotXY(dot_counter,1),Parameters.DotXY(dot_counter,2) ) , 1 ) % frame is 1 pixel thick
        end
        
        [~,idx] = min(abs(flipOnset - StartTime - S.data.time{1})); % time synchro
        Screen('FillOval',  win, [0 255 0], CenterRectOnPoint( [0 0 PD(idx) PD(idx)] , S.data.trial{1}(2,idx), S.data.trial{1}(3,idx))     )
        
        % Update display:
        flipOnset = Screen('Flip', win);
        
        % Release texture:
        Screen('Close', tex);
        
        % Store dot onset
        if draw_dot == 2
            dot_onset = flipOnset;
            draw_dot = 1;
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
                
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Fetch keys
        [keyIsDown, ~, keyCode] = KbCheck;
        if keyIsDown
            % ~~~ ESCAPE key ? ~~~
            
            if keyCode(KbName('ESCAPE'))
                fprintf( 'ESCAPE key pressed \n')
                break
            end
            
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
    end
    
    
    %% Stop movie
    
    
    % Stop playback:
    Screen('PlayMovie', movie, 0);
    
    % Close movie:
    Screen('CloseMovie', movie);
    
    
catch err
    Common.Catch(err)
end


end % functuion
