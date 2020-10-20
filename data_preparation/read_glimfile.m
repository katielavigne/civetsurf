function [glimfile, gfields, id] = read_glimfile()
% READ_GLIMFILE Read data from a n x m (subjects by variables) tabular file with headers.

[file, path] = uigetfile(fullfile(pwd, '*.*'), 'Select Glimfile (including headers):');
opts = detectImportOptions(fullfile(path,file),'NumHeaderLines',0);
glimfile = readtable(fullfile(path,file),opts);
gfields = fieldnames(glimfile);

% Identify ID variable (first column with fully unique values)
for k = 1:size(gfields,1)
    if size(unique(glimfile.(gfields{k})),1) == size(glimfile.(gfields{k}),1)
        id = gfields{k};
        if isnumeric(glimfile.(gfields{k}))
            glimfile.(gfields{k}) = cellstr(num2str(glimfile.(gfields{k})));
        end
        break
    end
end