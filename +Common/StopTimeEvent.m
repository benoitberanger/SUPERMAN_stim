function StopTimeEvent(  ER, StartTime, StopTime )

% Record StopTime
ER.AddStopTime( 'StopTime' , StopTime - StartTime );

ShowCursor;
Priority( 0 );

end % function
