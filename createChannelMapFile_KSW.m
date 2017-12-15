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

t = par.AnatGrps;
ngroups = length(par.AnatGrps);
for g = 1:ngroups
    tgroups{g} = par.AnatGrps(g).Channels;
end

switch(electrode_type)
    case 'staggered'
        for a= 1:ngroups %being super lazy and making this map with loops
            x = [];
            y = [];
            tchannels  = tgroups{a};
            for i =1:length(tchannels)
                x(i) = 20;%length(tchannels)-i;
                y(i) = -i*20;
                if mod(i,2)
                    x(i) = -x(i);
                end
            end
            x = x+a*200;
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

kcoords = zeros(1,Nchannels);
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
xcoords = xcoords(I)';
ycoords  = ycoords(I)';

save(fullfile(basepath,'chanMap.mat'), ...
    'chanMap','connected', 'xcoords', 'ycoords', 'kcoords', 'chanMap0ind')
