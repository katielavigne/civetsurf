function [filters, filtered_glimfile] = filter_data(glimfile, gfields)
% FILTER_DATA Select glimfile rows based on user-defined variables.

% Select filter variables
[Selection, ~] = listdlg('PromptString', [{'Select Filter Variables'}, {''}],'ListString', gfields);
if isempty(Selection)
    filters='none';
    filtered_glimfile=glimfile;
    return
end

% Input logical expressions for each filter
prompt = {};
for i = 1:size(Selection,2)
    prompt{i} = gfields{Selection(i)};
end

title = 'Input filters (e.g., "~=0" or ".Patient")';
answer = inputdlg(prompt, title, [1, length(title)+30]);

% Identify rows to keep
filters=struct();
for j = 1:size(Selection,2)
    filtvar = gfields{Selection(j)};
    if isnumeric(glimfile.(filtvar))
        findeq=['find(glimfile.' filtvar answer{j} ');'];
    else
        filtvar = regexprep(filtvar, '(?<=(^| ))(.)', '${upper($1)}');
        termvar = term(glimfile.(gfields{Selection(j)}));
        findeq=['find(termvar'  answer{j} ');'];
    end
    filters.(filtvar) = [filtvar answer{j}];
    temprows = eval(findeq);
    if j == 1
        rows = temprows;
    else
        rows = intersect(rows, temprows);
    end
end
filtered_glimfile = glimfile(rows,:);