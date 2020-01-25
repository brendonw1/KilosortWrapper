function createChannelMapFile_Local(basepath,basename,electrode_type)
% Original function by Brendon and Sam
% electrode_type: Two options at this point: 'staggered' or 'neurogrid'
% create a channel map file

if ~exist('basepath','var')
    basepath = cd;
end
if ~exist('basename','var')
    [~,basename] = fileparts(basepath);
end

[par,rxml] = LoadXml(fullfile(basepath,[basename,'.xml']));
xml_electrode_type = rxml.child(1).child(4).value;
switch(xml_electrode_type)
    case 'staggered'
        electrode_type = 'staggered';
    case 'neurogrid'
        electrode_type = 'neurogrid';
    case 'grid'
        electrode_type = 'neurogrid';
    case 'poly3'
        electrode_type = 'poly3';
    case 'poly5'
        electrode_type = 'poly5';
    case 'twohundred'
        electrode_type = 'twohundred';
end

%%Default
if ~exist('electrode_type')
    electrode_type = 'staggered';
end

%%
xcoords = [];%eventual output arrays
ycoords = [];

ngroups = length(par.AnatGrps);
for g = 1:ngroups
    groups{g} = par.AnatGrps(g).Channels;
end

switch(electrode_type)
    case 'staggered'
        for a= 1:ngroups %being super lazy and making this map with loops
            x = [];
            y = [];
            tchannels  = groups{a};
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
    case 'poly3'
        disp('poly3 probe layout')
        for a= 1:ngroups %being super lazy and making this map with loops
            tchannels  = groups{a};
            x = nan(1,length(tchannels));
            y = nan(1,length(tchannels));
            extrachannels = mod(length(tchannels),3);
            polyline = mod([1:length(tchannels)-extrachannels],3);
            x(find(polyline==1)+extrachannels) = -18;
            x(find(polyline==2)+extrachannels) = 0;
            x(find(polyline==0)+extrachannels) = 18;
            x(1:extrachannels) = 0;
            y(find(x == 18)) = [1:length(find(x == 18))]*-20;
            y(find(x == 0)) = [1:length(find(x == 0))]*-20-10+extrachannels*20;
            y(find(x == -18)) = [1:length(find(x == -18))]*-20;
            x = x+a*200;
            xcoords = cat(1,xcoords,x(:));
            ycoords = cat(1,ycoords,y(:));
        end
    case 'poly5'
        disp('poly5 probe layout')
        for a= 1:ngroups %being super lazy and making this map with loops
            tchannels  = groups{a};
            x = nan(1,length(tchannels));
            y = nan(1,length(tchannels));
            extrachannels = mod(length(tchannels),5);
            polyline = mod([1:length(tchannels)-extrachannels],5);
            x(find(polyline==1)+extrachannels) = -2*18;
            x(find(polyline==2)+extrachannels) = -18;
            x(find(polyline==3)+extrachannels) = 0;
            x(find(polyline==4)+extrachannels) = 18;
            x(find(polyline==0)+extrachannels) = 2*18;
            x(1:extrachannels) = 18*(-1).^[1:extrachannels];
            
            y(find(x == 2*18)) =  [1:length(find(x == 2*18))]*-28;
            y(find(x == 18)) =    [1:length(find(x == 18))]*-28-14;
            y(find(x == 0)) =     [1:length(find(x == 0))]*-28;
            y(find(x == -18)) =   [1:length(find(x == -18))]*-28-14;
            y(find(x == 2*-18)) = [1:length(find(x == 2*-18))]*-28;
            
            x = x+a*200;
            xcoords = cat(1,xcoords,x(:));
            ycoords = cat(1,ycoords,y(:));
        end
    case 'neurogrid'
        for a= 1:ngroups %being super lazy and making this map with loops
            x = [];
            y = [];
            tchannels  = groups{a};
            for i =1:length(tchannels)
                x(i) = length(tchannels)-i;
                y(i) = -i*50;
            end
            x = x+a*50;
            xcoords = cat(1,xcoords,x(:));
            ycoords = cat(1,ycoords,y(:));
        end
    case 'twohundred'
        for a= 1:ngroups 
            x = [];
            y = [];
            tchannels  = groups{a};
            for i =1:length(tchannels)
                x(i) = 0;%length(tchannels)-i;
                if mod(i,2)
                    y(i) = 0;%odds
                else
                    y(i) = 200;%evens
                end
            end
            x = x+(a-1)*200;
            xcoords = cat(1,xcoords,x(:));
            ycoords = cat(1,ycoords,y(:));
        end
end
Nchannels = length(xcoords);

kcoords = zeros(1,Nchannels);
switch(electrode_type)
    case {'staggered','poly3','poly5','twohundred'}
        for a= 1:ngroups
            kcoords(groups{a}+1) = a;
        end
    case 'neurogrid'
        for a= 1:ngroups
            kcoords(groups{a}+1) = floor((a-1)/4)+1;
        end
end
connected = true(Nchannels, 1);

% just use AnatGrps
% % Removing dead channels by the skip parameter in the xml
% % order = [par.AnatGrps.Channels];
% % skip = find([par.AnatGrps.Skip]);
% % connected(order(skip)+1) = false;
order = [par.AnatGrps.Channels];
if isfield(par,'SpkGrps')
    skip2 = find(~ismember([par.AnatGrps.Channels], [par.SpkGrps.Channels])); % finds the indices of the channels that are not part of SpkGrps
    connected(order(skip2)+1) = false;
end

chanMap     = 1:Nchannels;
chanMap0ind = chanMap - 1;
[~,I] =  sort(horzcat(groups{:}));
xcoords = xcoords(I)';
ycoords  = ycoords(I)';

save(fullfile(basepath,'chanMap.mat'), ...
    'chanMap','connected', 'xcoords', 'ycoords', 'kcoords', 'chanMap0ind')
