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
%   - Three way interactions (not feasible)
%   - Mean centre age (if predictor & mixed model)
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

% Predictor(s)
for k = 1:size(predvars,2)
    predname{k} = d.gfields{predvars(k)};
    M = M + term(d.glimfile.(predname{k}));
    u.model = [u.model '+' predname{k}];
end

% Interaction term(s)
% % Two way interactions only (three-way interactions attempted below)
if strcmp(u.interaction, 'yes')
    pairs = nchoosek(1:size(predvars,2), 2);
    for n = 1:size(pairs, 1)
        M = M + term(d.glimfile.(predname{pairs(n,1)}))*term(d.glimfile.(predname{pairs(n,2)}));
        u.model = [u.model '+' predname{pairs(n,1)} '*' predname{pairs(n,2)}];
    end
    ints =n;
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
    M = M + random(d.glimfile.(d.gfields{randvar(1)})) + I;
    u.model = [u.model '+random(' d.gfields{randvar(1)} ')+I'];
end

u.outdir = fullfile(outdir,strrep(strrep(u.model(5:end),'+', '_'), '*', 'X'));
mkdir(fullfile(u.outdir))
fprintf(['\tModel: ' u.model '\n'])

% Fit Model to Thickness Data
u.slm = SurfStatLinMod(Y,M,u.avsurf);

% Define and run contrasts
for n = 1:size(predvars,2)
    u.ME(n).predictor = predname{n};
    if ~isnumeric(d.glimfile.(predname{n}))
        u.ME(n).type = 'categorical';
        u.ME(n).labels = unique(d.glimfile.(predname{n}));
        catpairs = nchoosek(1:size(u.ME(n).labels,1), 2);
        catpairs = [catpairs; flip(nchoosek(1:size(u.ME(n).labels,1),2),2)];
        for p = 1:size(catpairs,1)
            u.ME(n).contrasts(p).name = [u.ME(n).labels{catpairs(p,1)} '-' u.ME(n).labels{catpairs(p,2)}];
            termvar = term(d.glimfile.(predname{n})); % must term categorical variables to access with ".label"
            u.ME(n).contrasts(p).value = termvar.(u.ME(n).labels{catpairs(p,1)})-termvar.(u.ME(n).labels{catpairs(p,2)});
            u.ME(n).contrasts(p).results = contrasts(u, u.ME(n).contrasts(p), 'ME', u.ME(n).predictor);
        end
    else
        u.ME(n).type = 'continuous';
        u.ME(n).labels = {};
        % Positive contrast
        u.ME(n).contrasts(1).name = ['+' predname{n}];
        u.ME(n).contrasts(1).value = d.glimfile.(predname{n});
        u.ME(n).contrasts(1).results = contrasts(u, u.ME(n).contrasts(1), 'ME', u.ME(n).predictor);
        % Negative contrast
        u.ME(n).contrasts(2).name = ['-' predname{n}];
        u.ME(n).contrasts(2).value = -d.glimfile.(predname{n});
        u.ME(n).contrasts(2).results = contrasts(u, u.ME(n).contrasts(2), 'ME', u.ME(n).predictor);
    end
end

if strcmp(u.interaction, 'yes')
    % Two-way interactions
    for r = 1:ints
        u.INT(r).predictors = {predname{pairs(r,1)}, predname{pairs(r,2)}};
        u.INT(r).types = {u.ME(pairs(r,1)).type, u.ME(pairs(r,2)).type};
        u.INT(r).labels = {u.ME(pairs(r,1)).labels, u.ME(pairs(r,2)).labels};

        if all(strcmp(u.INT(r).types,'continuous'))
            u.INT(r).contrasts(1).name = [predname{pairs(r,1)} '*' predname{pairs(r,2)}];
            u.INT(r).contrasts(1).value = d.glimfile.(predname{pairs(r,1)}).*d.glimfile.(predname{pairs(r,2)});
            preds = [u.INT(r).predictors{1} 'X' u.INT(r).predictors{2}];
            u.INT(r).contrasts(1).results = contrasts(u, u.INT(r).contrasts(1), 'INT', preds);
        elseif any(strcmp(u.INT(r).types, 'continuous'))
            contidx = strcmp(u.INT(r).types, 'continuous');
            catidx = strcmp(u.INT(r).types, 'categorical');
            contvars = u.INT(r).predictors{contidx};
            catvars = u.INT(r).predictors{catidx};
            termvar = term(d.glimfile.(catvars));
            catpairs = nchoosek(1:size(u.ME(catidx).labels,1), 2);
            catpairs = [catpairs; flip(nchoosek(1:size(u.ME(catidx).labels,1),2),2)];
            for q = 1:size(catpairs,1)
                u.INT(r).contrasts(q).name = [contvars '*' catvars '.' u.ME(catidx).labels{catpairs(q,1)} '-' contvars '*' catvars '.' u.ME(catidx).labels{catpairs(q,2)}];
                u.INT(r).contrasts(q).value = d.glimfile.(contvars).*termvar.(u.ME(catidx).labels{catpairs(q,1)})-d.glimfile.(contvars).*termvar.(u.ME(catidx).labels{catpairs(q,2)});
                preds = [u.INT(r).predictors{1} 'X' u.INT(r).predictors{2}];
                u.INT(r).contrasts(q).results = contrasts(u, u.INT(r).contrasts(q), 'INT', preds);
            end
        elseif all(strcmp(u.INT(r).types,'categorical'))
            warning('This code is not set up for two categorical predictor variables. Two-way categorical interactions skipped.')
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

%% Three-way interactions - INCOMPLETE - easier just to code it manually!

%         % Three-way interactions
%         if size(predvars,2) == 3
%             M = M + term(glimfile.(predname{1}))*term(glimfile.(predname{1}))*term(glimfile.(predname{1}));
%             uniGLM.model = [uniGLM.model '+' predname{1} '*' predname{2} '*' predname{3}];
%         end

%         % Three-way interactions
%         if ints>1
%             uniGLM.INT(ints+1).predictors = {predname{1}, predname{2}, predname{3}};
%             pred1 = glimfile.(predname{1});
%             pred2 = glimfile.(predname{2});
%             pred3 = glimfile.(predname{3});
%             uniGLM.INT(ints+1).types = {};
%             for i = 1:3
%                 if isnumeric(glimfile.(predname{i}))
%                     uniGLM.INT(ints+1).types{1,i} = 'continuous';
%                 else
%                     uniGLM.INT(ints+1).types{1,i} = 'categorical';
%                 end
%             end
%             if all(strcmp(uniGLM.INT(ints+1).types,'continuous'))
%                 uniGLM.INT(ints+1).contrasts(1).name = [uniGLM.INT(ints+1).predictors{1} '*' uniGLM.INT(ints+1).predictors{2} '*' uniGLM.INT(ints+1).predictors{3}];
%                 uniGLM.INT(ints+1).contrasts(1).value = glimfile.(uniGLM.INT(ints+1).predictors{1})*glimfile.(uniGLM.INT(ints+1).predictors{2})*glimfile.(uniGLM.INT(ints+1).predictors{2});
%             elseif any(strcmp(uniGLM.INT(ints+1).types,'categorical'))
%                 contidx = strcmp(uniGLM.INT(ints+1).types, 'continuous');
%                 catidx = strcmp(uniGLM.INT(ints+1).types, 'categorical');
%                 contvars = uniGLM.INT(ints+1).predictors(contidx);
%                 catvars = uniGLM.INT(ints+1).predictors(catidx);
%                 for i = 1:size(catvars,2)
%                     termvar = term(glimfile.(catvars));
%                     catpairs = nchoosek(1:size(uniGLM.ME(i).labels,1), 2);
%                     catpairs = [catpairs; flip(nchoosek(1:size(uniGLM.ME(catidx).labels,1),2),2)];
%                 end
%                 for q = 1:size(catpairs,1)
%                     uniGLM.INT(ints+1).contrasts(q).name = [contvars '*' catvars '.' uniGLM.ME(catidx).labels{catpairs(q,1)} '-' contvars '*' catvars '.' uniGLM.ME(catidx).labels{catpairs(q,2)}];
%                     uniGLM.INT(ints+1).contrasts(q).value = glimfile.(contvars).*termvar.(uniGLM.ME(catidx).labels{catpairs(q,1)})-glimfile.(contvars).*termvar(uniGLM.ME(catidx).labels{catpairs(q,2)});
%                     preds = [uniGLM.INT(r).predictors(1) 'X' uniGLM.INT(r).predictors(2)];
%                     uniGLM.INT(ints+1).contrasts(q).results = contrasts(uniGLM, uniGLM.INT(ints+1).contrasts(q), 'INT', preds);
%                 end
%             end
%         end