function data = addglimvars(d, data, glimfile, vars, name)
% addglimvars Append glimfile variables to data matrix.
%
% prerequisites:    data structure created from data = dataprep();
% external funcs:   none
% function:         structcov/addglimvars.m
% function input:   data, cortical parcellation, glimfile, variables to add, name)
% online input:     none

Y1 = d;

data.parc.pinfo.abbreviation = [data.parc.pinfo.abbreviation; vars];
data.parc.pinfo.description = [data.parc.pinfo.description; vars];
data.parc.pinfo.name = [data.parc.pinfo.name '_' name];

Y2 = zeros(size(Y1,1),size(vars,1));

for i = 1:size(vars,1)
    Y2(:,i) = glimfile.(vars{i});
end

data.(['ROIs_' name]) = [Y1 Y2];