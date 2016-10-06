function master_file(basepath,basename)
addpath(genpath('/home/brendon/gitrepositories/KiloSort')) % path to kilosort folder
addpath(genpath('/home/brendon/gitrepositories/npy-matlab')) % path to npy-matlab scripts

%% BW STUFF
if ~exist('basepath','var')
   [~,basename] = fileparts(cd);
   basepath = cd; 
end
if ~exist(fullfile(basepath,'chanMap.mat'))
    createChannelMapFile(basepath)
end

%% default options are in parenthesis after the comment
pathToYourConfigFile = basepath; % take from Github folder and put it somewhere else (together with the master_file)
run(fullfile(pathToYourConfigFile, 'StandardConfig.m'))

tic; % start timer
%%
if ops.GPU     
    gpuDevice(1); % initialize GPU (will erase any existing GPU arrays)
end

if strcmp(ops.datatype , 'openEphys')
   ops = convertOpenEphysToRawBInary(ops);  % convert data, only for OpenEphys
end
%%
disp('PreprocessingData')
[rez, DATA, uproj] = preprocessData(ops); % preprocess data and extract spikes for initialization

disp('Fitting templates')
rez = fitTemplates(rez, DATA, uproj);  % fit templates iteratively

disp('Extracting final spike times')
rez = fullMPMU(rez, DATA);% extract final spike times (overlapping extraction)

%% posthoc merge templates (under construction)
%     rez = merge_posthoc2(rez);

%$ save matlab results file
disp('Saving')
save(fullfile(ops.root,  'rez.mat'), 'rez', '-v7.3');

%% save python results file for Phy
% disp('Starting to convert to Phy format')
% rezToPhy(rez, ops.root);
disp('Starting to convert to Klusters format')
ConvertKilosort2Neurosuite(basepath,basename,rez)

%% remove temporary file
delete(ops.fproc);

%%
