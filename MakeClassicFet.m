function MakeClassicFet(basename,dirname)

if ~exist('basename','var')
    [~,basename] = fileparts(cd);
end
if ~exist('dirname','var')
    dirname = cd;
end

d = dir(fullfile(dirname,[basename '.fet.*']));
if ~isempty(d);
    mkdir(fullfile(dirname,'PreviousFets'))
    for a = 1:length(d);
        movefile(fullfile(dirname,d(a).name),fullfile(dirname,'PreviousFets',d(a).name));
    end
end

cd(dirname)
if ~exist([basename '.fil'],'file')
    cmd = ['process_mhipass ' basename];
    system(cmd)
end

%get xml
[xml, rxml] = LoadXml([basename '.xml']);
nCh = length(xml.SpkGrps);
for i = 1:nCh
    cmd = ['process_pca_multi ' basename ' ' num2str(i)];
%     cmd = ['ndm_pca ' basename ' ' num2str(i)];
    disp(cmd)
    system(cmd)
end


% cmd = ['rm ' basename '.fil'];
system(cmd)
