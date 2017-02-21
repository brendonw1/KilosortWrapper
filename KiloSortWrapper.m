function KiloSortWrapper(basepath,basename,n)

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

% Copyright (C) 2016 Brendon Watson
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.

%% Addpath if needed
%addpath(genpath('gitrepositories/KiloSort')) % path to kilosort folder
%addpath(genpath('gitrepositories/npy-matlab')) % path to npy-matlab scripts

%% If function is called without argument
if ~exist('basepath','var')
   [~,basename] = fileparts(cd);
   basepath = cd; 
end

%% If a channel map does not exist
if ~exist(fullfile(basepath,'chanMap.mat'))
    createChannelMapFile_Local(basepath)
end


%% default options are in parenthesis after the comment
XMLFilePath = fullfile(basepath, [basename '.xml']);

if exist(fullfile(basepath,'StandardConfig.m'),'file') %this should actually be unnecessary
    addpath(basepath);
end
ops = StandardConfig(XMLFilePath);

tic; % start timer
%%
if ops.GPU     
    gpuDevice(1); % initialize GPU (will erase any existing GPU arrays)
end

if strcmp(ops.datatype , 'openEphys')
   ops = convertOpenEphysToRawBInary(ops);  % convert data, only for OpenEphys
end

%% Lauches KiloSort

disp('PreprocessingData')
[rez, DATA, uproj] = preprocessData_KSWrapper(ops); % preprocess data and extract spikes for initialization

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
