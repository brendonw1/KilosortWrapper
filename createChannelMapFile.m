function createChannelMapFile(basepath,basename)
%  create a channel map file

if ~exist('basepath','var')
    basepath = cd;
end




XMLfile = [basepath '/' basename '.xml'];

    [par, rxml] = LoadXml(XMLfile);
    
% add bad channel-handling
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
Nchannels = par.nChannels;

connected = true(Nchannels, 1);
chanMap   = 1:Nchannels;
chanMap0ind = chanMap - 1;

% xcoords   = ones(Nchannels,1);
% ycoords   = [1:Nchannels]';
xcoords = [];
ycoords = [];
for a= 1:length(par.AnatGrps)%being super lazy and making this map with loops
    x = [];
    y = [];
    tchannels  = par.AnatGrps(a).Channels;
    for i =1:length(tchannels)
%         if ~ismember(tchannels(i),badchannels)
            x(i) = length(tchannels)-i;
            y(i) = -i*1;
            if mod(i,2)
                x(i) = -x(i);
            end
%         end
    end
    x = x+a*100;
    xcoords = cat(1,xcoords,x(:));
    ycoords = cat(1,ycoords,y(:));
end

kcoords = zeros(Nchannels,1);
for a= 1:length(par.AnatGrps)
    kcoords(par.AnatGrps(a).Channels+1) = a;
end


save(fullfile(basepath,'chanMap.mat'), ...
    'chanMap','connected', 'xcoords', 'ycoords', 'kcoords', 'chanMap0ind')

%%
% 