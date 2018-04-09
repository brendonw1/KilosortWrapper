function savepath = KiloSortWrapper(basepath,basename,config_version)
% Creates channel map from Neuroscope xml files, runs KiloSort and
% writes output data in the Neuroscope/Klusters format. 
% StandardConfig.m should be in the path or copied to the local folder
% 
%  USAGE
%
%    KiloSortWrapper()
%    Should be run from the data folder, and file basenames are the
%    same as the name as current directory
%
%    KiloSortWrapper(basepath,basenmae)
%
%    INPUTS
%    basepath       path to the folder containing the data
%    basename       file basenames (of the dat and xml files)
%
%    Dependencies:  KiloSort (https://github.com/cortex-lab/KiloSort)

% Copyright (C) 2016 Brendon Watson and the Buzsakilab
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
disp('Running Kilosort spike sorting with the Buzsaki lab wrapper')

%% Addpath if needed
% addpath(genpath('gitrepositories/KiloSort')) % path to kilosort folder
% addpath(genpath('gitrepositories/npy-matlab')) % path to npy-matlab scripts

%% If function is called without argument
switch nargin
    case 0
        [~,basename] = fileparts(cd);
        basepath = cd;
    case 1
        [~,basename] = fileparts(basepath);
    case 2
        if isempty(basepath)
            [~,basename] = fileparts(basepath);
            basepath = cd;
        end
    case 3
        if isempty(basepath)
            [~,basename] = fileparts(cd);
            basepath = cd;
        end
end
cd(basepath)

%% Creates a channel map file
disp('Creating ChannelMapFile')
createChannelMapFile_KSW(basepath,'staggered');

%% Loading configurations
XMLFilePath = fullfile(basepath, [basename '.xml']);
% if exist(fullfile(basepath,'StandardConfig.m'),'file') %this should actually be unnecessary
%     addpath(basepath);
% end
if nargin < 3
    disp('Running Kilosort with standard settings')
    ops = KilosortConfiguration(XMLFilePath);
else
    disp('Running Kilosort with user specific settings')
    config_string = str2func(['KilosortConfiguration_' config_version]);
    ops = config_string(XMLFilePath);
    clear config_string;
end

%% % Defining SSD location if any
if isdir('G:\Kilosort')
    disp('Creating a temporary dat file on the SSD drive')
    ops.fproc = ['G:\Kilosort\temp_wh.dat'];
else
    ops.fproc = fullfile(basepath,'temp_wh.dat');
end

%%
if ops.GPU
    disp('Initializing GPU')
    gpuDevice(1); % initialize GPU (will erase any existing GPU arrays)
end
if strcmp(ops.datatype , 'openEphys')
   ops = convertOpenEphysToRawBInary(ops);  % convert data, only for OpenEphys
end

%% Lauches KiloSort
disp('Running Kilosort pipeline')
disp('PreprocessingData')
[rez, DATA, uproj] = preprocessData(ops); % preprocess data and extract spikes for initialization

disp('Fitting templates')
rez = fitTemplates(rez, DATA, uproj);  % fit templates iteratively

disp('Extracting final spike times')
rez = fullMPMU(rez, DATA); % extract final spike times (overlapping extraction)

%% posthoc merge templates (under construction)
% save matlab results file
CreateSubdirectory = 1;
if CreateSubdirectory
    timestamp = ['Kilosort_' datestr(clock,'yyyy-mm-dd_HHMMSS')];
    savepath = fullfile(basepath, timestamp);
    mkdir(savepath);
    copyfile([basename '.xml'],savepath);
else
    savepath = fullfile(basepath);
end
rez.ops.basepath = basepath;
rez.ops.basename = basename;
rez.ops.savepath = savepath;
disp('Saving rez file')
% rez = merge_posthoc2(rez);
save(fullfile(savepath,  'rez.mat'), 'rez', '-v7.3');

%% save python results file for Phy
disp('Converting to Phy format')
rezToPhy_KSW(rez);

%% save python results file for Klusters
disp('Converting to Klusters format')
Kilosort2Neurosuite(rez)

%% Remove temporary file
delete(ops.fproc);
disp('Kilosort Processing complete')

