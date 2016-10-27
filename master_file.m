function master_file(basepath,basename)

if ~exist('basepath','var')
   [~,basename] = fileparts(cd);
   basepath = cd; 
end
    createChannelMapFile(basepath,basename)


XMLfile = [basepath '/' basename '.xml'];
    [xml, rxml] = LoadXml(XMLfile);
   
% default options are in parenthesis after the comment
ops = StandardConfig(XMLfile);

tic; % start timer
%
if ops.GPU     
    gpuDevice(1); % initialize GPU (will erase any existing GPU arrays)
end

if strcmp(ops.datatype , 'openEphys')
   ops = convertOpenEphysToRawBInary(ops);  % convert data, only for OpenEphys
end
%

%%
disp('PreprocessingData')
[rez, DATA, uproj] = preprocessData(ops); % preprocess data and extract spikes for initialization

disp('Fitting templates')
rez = fitTemplates(rez, DATA, uproj);  % fit templates iteratively

disp('Extracting final spike times')
rez = fullMPMU(rez, DATA);% extract final spike times (overlapping extraction)

% posthoc merge templates (under construction)
%     rez = merge_posthoc2(rez);

% save matlab results file
disp('Saving')
save(fullfile(ops.root,  'rez.mat'), 'rez', '-v7.3');

% save python results file for Phy
% rezToPhy(rez, ops.root);
disp('Starting to convert to Klusters format')
ConvertKilosort2Neurosuite(basepath,basename,rez)

% remove temporary file
delete(ops.fproc);

%%
