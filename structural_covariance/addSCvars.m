function Y = addSCvars(Y1, glimfile, vars)
% addSCvars Append variables to data matrix.
%
% prerequisites:    data structure created from data = dataprep();
% external funcs:   none
% function:         structcov/addSCvars.m
% function input:   cortical surface data, glimfile, variables to add
% online input:     none

Y2 = zeros(size(Y1,1),size(vars,2));

for i = 1:size(vars,2)
    Y2(:,i) = glimfile.(vars{i});
end

Y = [Y1 Y2];