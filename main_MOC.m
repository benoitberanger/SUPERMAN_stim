function main_MOC(hObject, ~)
% main_MOC is the main program, calling the different tasks and
% routines, accoding to the paramterts defined in the GUI


%% GUI : open a new one or retrive data from the current one

if nargin == 0
    
    gui_MOC;
    
    return
    
end

handles = guidata(hObject); % retrieve GUI data


%% MAIN : Clean the environment

clc
sca
rng('default')
rng('shuffle')


%% Fetch the corresponding .mat file

global S

datapath = fullfile( fileparts( fileparts( mfilename('fullpath') ) ), 'data', get(handles.edit_SubjectID,'String'));

% .asc
val  = get(handles.listbox_Files,'Value');
list = get(handles.listbox_Files,'String');
ascfile = fullfile( datapath, list{val} );

% .mat
[ ~ , fname , ~ ] = fileparts(ascfile);
matfile = [fullfile(datapath, fname) '.mat'];
assert( exist(matfile,'file')>0 , 'Corresponding .mat file does not exist : %s', matfile )
fprintf('Loading .mat file : %s \n', matfile)
l=load(matfile);
S = l.S;


%% Load Eyelink file

cfg                  = struct;
cfg.dataset          = ascfile;
cfg.montage.tra      = eye(5);
cfg.montage.labelorg = {'1', '2', '3', '4', '5'};
cfg.montage.labelnew = {'EYE_TIMESTAMP', 'EYE_HORIZONTAL', 'EYE_VERTICAL', 'EYE_DIAMETER', 'INPUT'};

fprintf('Loading .asc file : %s \n', ascfile)

data  = ft_preprocessing(cfg);
event = ft_read_event(ascfile);
if isfield(S.ParPortMessages,'Start')
    target_message = 'Start';
elseif isfield(S.ParPortMessages,'MovieStart')
    target_message = 'MovieStart';
end
start_evt_idx = [ event.value ] == S.ParPortMessages.(target_message);
start_sample = event(start_evt_idx).sample;

% cut
data.time{1} = data.time{1}(1:end-start_sample+1);
data.trial{1} = data.trial{1}(:,start_sample:end);
data.sampleinfo(2) = length(data.time{1});

S.data = data;


%% MAIN : Get stimulation parameters

% Screen mode selection
AvalableDisplays = get(handles.listbox_Screens,'String');
SelectedDisplay = get(handles.listbox_Screens,'Value');
S.ScreenID = str2double( AvalableDisplays(SelectedDisplay) );


%% MAIN : Open PTB window & sound

S.PTB = MOC.StartPTB;


%% MAIN : MOC

EchoStart('MOC')
MOC.Task;
EchoStop('MOC')


%% MAIN : Close PTB

sca;
Priority( 0 );


%% MAIN + GUI : Ready for another run

WaitSecs(0.100);
pause(0.100);
fprintf('\n')
fprintf('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ \n')
fprintf('  Ready for another session   \n')
fprintf('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ \n')


end % function
