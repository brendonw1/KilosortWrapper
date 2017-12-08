function createChannelMapFile_Local(basepath,electrode_type)
% Original function by Brendon and Sam
% electrode_type: Two options at this point: 'staggered' or 'neurogrid'
% create a channel map file

if ~exist('basepath','var')
    basepath = cd;
end
d   = dir('*.xml');
[par,rxml] = LoadXml(fullfile(basepath,d(1).name));
xml_electrode_type = rxml.child(1).child(4).value;
switch(xml_electrode_type)
    case 'staggered'
        electrode_type = 'staggered';
    case 'neurogrid'
        electrode_type = 'neurogrid';
    case 'grid'
        electrode_type = 'neurogrid';
end
if ~exist('electrode_type')
    electrode_type = 'staggered';
end
xcoords = [];
ycoords = [];
if ~isfield(par,'nElecGps')
    warning('No Electrode/Spike Groups found in xml.  Using Anatomy Groups instead.')
    tgroups = par.ElecGp;
    ngroups = length(tgroups);
else
    t = par.AnatGrps;
    ngroups = length(par.AnatGrps);
    for g = 1:ngroups
        tgroups{g} = par.AnatGrps(g).Channels;
    end
end
switch(electrode_type)
    case 'staggered'
        for a= 1:ngroups %being super lazy and making this map with loops
            x = [];
            y = [];
            tchannels  = tgroups{a};
            for i =1:length(tchannels)
                x(i) = 10;%length(tchannels)-i;
                y(i) = -i*10;
                if mod(i,2)
                    x(i) = -x(i);
                end
            end
            x = x+a*50;
            xcoords = cat(1,xcoords,x(:));
            ycoords = cat(1,ycoords,y(:));
        end
    case 'neurogrid'
        for a= 1:ngroups %being super lazy and making this map with loops
            x = [];
            y = [];
            tchannels  = tgroups{a};
            for i =1:length(tchannels)
                x(i) = length(tchannels)-i;
                y(i) = -i*30;
            end
            x = x+a*30;
            xcoords = cat(1,xcoords,x(:));
            ycoords = cat(1,ycoords,y(:));
        end
end
Nchannels = length(xcoords);

kcoords = zeros(Nchannels,1);
switch(electrode_type)
    case 'staggered'
        for a= 1:ngroups
            kcoords(tgroups{a}+1) = a;
        end
    case 'neurogrid'
        for a= 1:ngroups
            kcoords(tgroups{a}+1) = floor((a-1)/4)+1;
        end
end
connected = true(Nchannels, 1);

% Removing dead channels by the skip parameter in the xml
order = [par.AnatGrps.Channels];
skip = find([par.AnatGrps.Skip]);
connected(order(skip)+1) = false;

chanMap     = 1:Nchannels;
chanMap0ind = chanMap - 1;
[~,I] =  sort(horzcat(tgroups{:}));
xcoords = xcoords(I);
ycoords  = ycoords(I);

save(fullfile(basepath,'chanMap.mat'), ...
    'chanMap','connected', 'xcoords', 'ycoords', 'kcoords', 'chanMap0ind')

%%
% % 
% Nchannels = 128;
% connected = true(Nchannels, 1);
% chanMap   = 1:Nchannels;
% chanMap0ind = chanMap - 1;
% 
% xcoords   = repmat([1 2 3 4]', 1, Nchannels/4);
% xcoords   = xcoords(:);
% ycoords   = repmat(1:Nchannels/4, 4, 1);
% ycoords   = ycoords(:);
% kcoords   = ones(Nchannels,1); % grouping of channels (i.e. tetrode groups)
% 
% save('C:\DATA\Spikes\Piroska\chanMap.mat', ...
%     'chanMap','connected', 'xcoords', 'ycoords', 'kcoords', 'chanMap0ind')
%%

% kcoords is used to forcefully restrict templates to channels in the same
% channel group. An option can be set in the master_file to allow a fraction 
% of all templates to span more channel groups, so that they can capture shared 
% noise across all channels. This option is

% ops.criterionNoiseChannels = 0.2; 

% if this number is less than 1, it will be treated as a fraction of the total number of clusters

% if this number is larger than 1, it will be treated as the "effective
% number" of channel groups at which to set the threshold. So if a template
% occupies more than this many channel groups, it will not be restricted to
% a single channel group. 