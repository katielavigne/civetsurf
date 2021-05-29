function u = runGLM(d, Y, outdir)
% RUNGLM Run user-defined general linear model.
%
% description:      runs mass univariate GLM
% prerequisites:    data structure created from data = dataprep();
% external funcs:   surfstat (http://www.math.mcgill.ca/keith/surfstat/)
% function:         univariate_GLM/runGLM.m
% function input:   data structure, smoothed data, output directory
% online input:     (1) select predictors
%                   (2) select covariates (optional)
%                   (3) select random term (optional)
%
% output: 
%   (1) creates folder [named Predictor(s)_Covariate(s)] with figures and results
%   (2) outputs uniGLM structure
%           .avsurf:                CIVET-defined average surface
%           .mask:                  CIVET-defined mask
%           .modeltype:             GLM model type (fixed, mixed) based on user selections
%           .interaction:           flag (yes/no) for 2+ predictors
%           .model:                 string showing GLM model tested
%           .outdir:                directory to save GLM results
%           .slm:                   GLM model fit (see surfstat documentation)
%           .ME:                    contrast results for GLM main effect(s)
%           .INT:                   contrast results for interaction(s)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TO DO
%   - Add MNI coordinates and DKT region names to table (testing/GLMtable_Int) &
%   provide interaction plots (testing/Interaction_Plots.m)
%   - Mean centre predictors for mixed models?
%   - Two+ categorical predictor variables
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

u.avsurf = d.avsurf;
u.mask = d.mask;

% Select variables & determine model type
u.modeltype = 'fixed';
u.interaction = 'no';

[predvars, ~] = listdlg('PromptString', 'Select Predictor(s)', 'ListString', d.gfields); % Predictor(s)
[covars, ~] = listdlg('PromptString', 'Select Covariate(s)','ListString', d.gfields); % Covariate(s)
[randvar, ~] = listdlg('PromptString', 'Select Random Term','ListString', d.gfields, 'SelectionMode', 'single'); % Random term

if ~isempty(randvar)
    u.modeltype = 'mixed';
end

if size(predvars,2) > 1
    u.interaction = 'yes';
end

% Define Model
M = 1;
u.model = 'M=1';

% Main effects
for k = 1:size(predvars,2)
    predname{k} = d.gfields{predvars(k)};
    M = M + term(d.glimfile.(predname{k}));
    u.model = [u.model '+' predname{k}];
end

% Interaction effects
ints = 0;
if strcmp(u.interaction, 'yes')
    for i = 1:size(predvars,2)
        % Two-way
        if size(predvars,2) > i
            for j = i+1:size(predvars,2)
                M = M + term(d.glimfile.(predname{i}))*term(d.glimfile.(predname{j}));
                u.model = [u.model '+' predname{i} '*' predname{j}];
            end
        end
    end
    % Three-way
    if size(predvars,2) == 3
        M = M + term(d.glimfile.(predname{1}))*term(d.glimfile.(predname{2}))*term(d.glimfile.(predname{3}));
        u.model = [u.model '+' predname{1} '*' predname{2} '*' predname{3}];
    end
end

% Covariate(s)
for m = 1:size(covars,2)
    covname{m} = d.gfields{covars(m)};
    ctermname{m} = regexprep(covname{m}, '(?<=(^| ))(.)', '${upper($1)}');
    M = M + term(d.glimfile.(covname{m}));
    u.model = [u.model '+' ctermname{m}];
end

% Random term & identity matrix
if strcmp(u.modeltype, 'mixed')
    idvar = d.glimfile.(d.gfields{randvar(1)});
    if strcmp(class(idvar),'double')
        idvar = cellstr(num2str(idvar));
    end
    randterm = term(idvar);
    M = M + random(randterm) + I;
    u.model = [u.model '+random(' d.gfields{randvar(1)} ')+I'];
end

% Name output directory
dirname = [u.modeltype 'GLM' ];
for i = 1:size(predvars,2)
    dirname = [dirname '_' predname{i}];
end
for j = 1:size(covars,2)
    dirname = [dirname '_cov' covname{j}];
end

u.outdir = fullfile(outdir,dirname);
mkdir(fullfile(u.outdir))
fprintf(['\tModel: ' u.model '\n'])

% Fit Model to Thickness Data
u.slm = SurfStatLinMod(Y,M,u.avsurf);

% Define and run contrasts
% % Main effects
for n = 1:size(predvars,2)
    u.ME(n).predictor = predname{n};
    if ~isnumeric(d.glimfile.(predname{n}))
        u.ME(n).type = 'categorical';
        u.ME(n).labels = unique(d.glimfile.(predname{n}));
        termvar = term(d.glimfile.(predname{n})); % must term categorical variables to access with ".label"
        catpairs = nchoosek(1:size(u.ME(n).labels,1), 2);
        catpairs = [catpairs; flip(nchoosek(1:size(u.ME(n).labels,1),2),2)];
        for p = 1:size(catpairs,1)
            cname = [u.ME(n).labels{catpairs(p,1)} '-' u.ME(n).labels{catpairs(p,2)}];
            cvalue = termvar.(u.ME(n).labels{catpairs(p,1)})-termvar.(u.ME(n).labels{catpairs(p,2)});
            u.ME(n).contrasts(p) = contrasts(u, cname, cvalue, 'ME', predname{n});
        end
    else
        u.ME(n).type = 'continuous';
        u.ME(n).labels = {};
        u.ME(n).contrasts(1) = contrasts(u, ['+' predname{n}], d.glimfile.(predname{n}), 'ME', predname{n}); % Positive contrast
        u.ME(n).contrasts(2) = contrasts(u, ['-' predname{n}], -d.glimfile.(predname{n}), 'ME', predname{n}); % % Negative contrast
    end
end

% % Interactions
n = 1;
if strcmp(u.interaction, 'yes')
    for r = 1:size(predvars,2)
        % Two-way
        if size(predvars,2) > r
            for s = r+1:size(predvars,2)
                u.INT(n).predictors = {predname{r}, predname{s}};
                preds = [predname{r} 'X' predname{s}];
                u.INT(n).types = {u.ME(r).type, u.ME(s).type};
                u.INT(n).labels = {u.ME(r).labels, u.ME(s).labels};     
                if all(strcmp(u.INT(n).types,'continuous'))
                    u.INT(n).contrasts = contrasts(u, [predname{r} '*' predname{s}], d.glimfile.(predname{r}).*d.glimfile.(predname{s}), 'INT', preds);
                elseif any(strcmp(u.INT(n).types, 'continuous'))
                    contidx = strcmp(u.INT(n).types, 'continuous');
                    catidx = strcmp(u.INT(n).types, 'categorical');
                    contvars = u.INT(n).predictors{contidx};
                    catvars = u.INT(n).predictors{catidx};
                    termvar = term(d.glimfile.(catvars));
                    catpairs = nchoosek(1:size(u.ME(catidx).labels,1), 2);
                    catpairs = [catpairs; flip(nchoosek(1:size(u.ME(catidx).labels,1),2),2)];
                    for q = 1:size(catpairs,1)
                        cname = [contvars '*' catvars '.' u.ME(catidx).labels{catpairs(q,1)} '-' contvars '*' catvars '.' u.ME(catidx).labels{catpairs(q,2)}];
                        cvalue = d.glimfile.(contvars).*termvar.(u.ME(catidx).labels{catpairs(q,1)})-d.glimfile.(contvars).*termvar.(u.ME(catidx).labels{catpairs(q,2)});
                        u.INT(n).contrasts(q) = contrasts(u, cname, cvalue, 'INT', preds);
                    end
                elseif all(strcmp(u.INT(n).types,'categorical'))
                    warning('This code is not set up for two categorical predictor variables. Two-way categorical interactions skipped.')
                end
                n = n +1;
            end
        end
    end
    % Three-way
    if size(predvars,2) == 3
        u.INT(n+1).predictors = {predname{1}, predname{2}, predname{3}};
        preds = [predname{1} 'X' predname{2} 'X' predname{3}];
        u.INT(n+1).types = {u.ME(1).type, u.ME(2).type, u.ME(3).type};
        if all(strcmp(u.INT(n+1).types,'continuous'))
            cname = [predname{1} '*' predname{2} '*' predname{3}];
            cvalue = d.glimfile.(predname{1})*d.glimfile.(predname{2})*d.glimfile.(predname{3});
            u.INT(n+1).contrasts = contrasts(u, cname, cvalue, INT, preds);
        elseif size(find(strcmp(u.INT(n+1).types,'categorical')),2)==1
            contidx = find(strcmp(u.INT(n+1).types, 'continuous'));
            catidx = find(strcmp(u.INT(n+1).types, 'categorical'));
            contvars = predname(contidx);
            catvar = predname{catidx};
            termvar = term(d.glimfile.(catvar));
            catpairs = nchoosek(1:size(u.ME(catidx).labels,1), 2);
            catpairs = [catpairs; flip(nchoosek(1:size(u.ME(catidx).labels,1),2),2)];
            for q = 1:size(catpairs,1)
                cname = [contvars{1} '*' contvars{2} '*' catvar '.' u.ME(catidx).labels{catpairs(q,1)} '-' contvars{1} '*' contvars{2} '*' catvar '.' u.ME(catidx).labels{catpairs(q,2)}];
                cvalue = (d.glimfile.(contvars{1}).*d.glimfile.(contvars{2}).*termvar.(u.ME(catidx).labels{catpairs(q,1)}))-(d.glimfile.(contvars{1}).*d.glimfile.(contvars{2}).*termvar.(u.ME(catidx).labels{catpairs(q,2)}));
                u.INT(n+1).contrasts(q) = contrasts(u, cname, cvalue, 'INT', preds);
            end
        elseif size(find(strcmp(u.INT(n+1).types,'categorical')),2)>1
            warning('This code is not set up for two categorical predictor variables. Three-way interaction skipped.')
        end
    end
end
save(fullfile(u.outdir, ['uniGLM_' strrep(strrep(u.model(5:end),'+', '_'), '*', 'X') '.mat']))

%% Mean center Age if predictor and mixed model only - TO DO
% if strcmp(uniGLM.modeltype, 'mixed') && (regexp(glimfile.(lower(predvar{i})), regexptranslate('*age*') || regexp(glimfile.(lower(predvar{i})), regexptranslate('*Age*'))))
%     glimfile.([lower(predvar{i}) '_centered']) = glimfile.(lower(predvar{i}))-mean(glimfile.(lower(predvar{i})));
%     glimfile.([predvar{i} '_centered']) = term(glimfile.([lower(predvar{i}) '_centered']));
%     predvar{i} = [predvar{i} '_centered'];
% end