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


for s = 1:size(Y1,1)
    leftfile = dir(fullfile(txtdir, ['*' subjs{s} '*left*.txt']));
    fid = fopen(fullfile(txtdir, leftfile.name));
    leftdata = textscan(fid, '%f');
    fclose(fid);
    rightfile = dir(fullfile(txtdir, ['*' subjs{s} '*right*.txt']));
    fid = fopen(fullfile(txtdir, rightfile.name));
    rightdata = textscan(fid, '%f');
    fclose(fid);
    Y2(s,:) = [leftdata{1}' rightdata{1}'];
end

parc.(['ROIs_' name]) = [Y1 Y2];