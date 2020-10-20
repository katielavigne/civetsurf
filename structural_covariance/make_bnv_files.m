function make_bnv_files(d, sc, dir, title)
% MAKE_BNV_FILES Create .edge and .node files to display results with BrainNet Viewer (https://www.nitrc.org/projects/bnv)

if strcmp(d.parc.pscheme, 'DKT')
    node = d.parc.pinfo.coords;
else
    node = d.parc.pinfo.coords';
end
node(:,4) = 1;
for k = 1:size(node,1)
    if max(sc(:,k))>0
        node(k,5) = 1;
    else
        node(k,5) = 0;
    end
end
% create edge array (will skip any added variables as they can't be displayed)
edge = sc(1:length(d.parc.pinfo.coords),1:length(d.parc.pinfo.coords));

fid = fopen(fullfile(dir, [title '_' d.parc.pscheme '.node']),'w+');
fprintf(fid, '%f\t%f\t%f\t%f\t%f\t-\n', node.');
fclose(fid);

fid = fopen(fullfile(dir, [title '_' d.parc.pscheme '.edge']),'w+');
fprintf(fid, [repmat('%d\t',1,length(edge)), '\n'], edge.');
fclose(fid);