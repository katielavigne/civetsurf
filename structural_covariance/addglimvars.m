function parc = addglimvars(parc, glimfile, vars, name)
% addglimvars Append glimfile variables to data matrix.
%
% prerequisites:    data structure created from data = dataprep();
% external funcs:   none
% function:         structcov/addglimvars.m
% function input:   cortical parcellation, glimfile, variables to add, name
% online input:     none

Y1 = parc.ROIs;
parc.pinfo.abbreviation = [parc.pinfo.abbreviation; vars];
parc.pinfo.description = [parc.pinfo.description; vars];
parc.pinfo.name = [parc.pinfo.name '_' name];

Y2 = zeros(size(Y1,1),size(vars,1));

for i = 1:size(vars,1)
    Y2(:,i) = glimfile.(vars{i});
end

parc.(['ROIs_' name]) = [Y1 Y2];