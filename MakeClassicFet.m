function MakeClassicFet(basename,dirname)

cd(dirname)
if ~exist([basename '.fil'])
    
    xml =  LoadXml([basename '.xml']);
    inname = [basename '.dat'];
    outname = [basename '.fil'];
    numch = num2str(xml.nChannels);
    sampl = num2str(xml.SampleRate);
    lowband = '800';
    highband = '9500';
    forder = '50';
    gain = '1';
    offset = '0';
    
    firfilter(inname,outname,numch,sampl,lowband,highband,forder,gain,offset);
end

%get xml
[xml, rxml] = LoadXml([basename '.xml']);
nCh = length(xml.SpkGrps);
for i = 1:nCh
   cmd = ['process_pca_multi ' basename ' ' num2str(i)];
    disp(cmd)
     [a,b] =  system(cmd)
end

if a ==0
    cmd = ['rm ' basename '.fil'];
    system(cmd)
end

% function MakeClassicFet(basename,dirname)
% 
% if ~exist('basename','var')
%     [~,basename] = fileparts(cd);
% end
% if ~exist('dirname','var')
%     dirname = cd;
% end
% 
% d = dir(fullfile(dirname,[basename '.fet.*']));
% if ~isempty(d);
%     mkdir(fullfile(dirname,'PreviousFets'))
%     for a = 1:length(d);
%         movefile(fullfile(dirname,d(a).name),fullfile(dirname,'PreviousFets',d(a).name));
%     end
% end
% 
% cd(dirname)
% if ~exist([basename '.fil'],'file')
%     cmd = ['process_mhipass ' basename];
%     system(cmd)
% end
% 
% %get xml
% [xml, rxml] = LoadXml([basename '.xml']);
% nCh = length(xml.SpkGrps);
% for i = 1:nCh
%     cmd = ['process_pca_multi ' basename ' ' num2str(i)];
% %     cmd = ['ndm_pca ' basename ' ' num2str(i)];
%     disp(cmd)
%     system(cmd)
% end
% 
% 
% % cmd = ['rm ' basename '.fil'];
% system(cmd)
