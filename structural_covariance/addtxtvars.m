function parc = addtxtvars(parc, subjs, txtdir, vars, name)
% addtxtvars Append text files (e.g., qT1 hippocampal values) to data matrix.
%
% prerequisites:    data structure created from data = dataprep();
% external funcs:   none
% function:         structcov/addtxtvars.m
% function input:   cortical surface parcellation structure, subject list, text directory, variables to add
% online input:     none

Y1 = parc.ROIs;
parc.pinfo.abbreviation = [parc.pinfo.abbreviation; vars];
parc.pinfo.description = [parc.pinfo.description; vars];
parc.pinfo.name = [parc.pinfo.name '_' name];

type = class(subjs);
switch type
    case 'double'
        subjs = cellstr(num2str(subjs));
end

Y2 = zeros(size(Y1,1),size(vars,1));
for s = 1:size(Y1,1)
    files = dir(fullfile(txtdir, ['*' subjs{s} '*.txt']));
    fid = fopen(fullfile(txtdir, files.name));
    data = textscan(fid, '%f');
    fclose(fid);
    Y2(s,:) = data{1}';
end

parc.(['ROIs_' name]) = [Y1 Y2];