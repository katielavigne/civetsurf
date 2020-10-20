function p = pls(X, info, avsurf, glimfile, behvars, behdesc)
% PLS Runs behavioural PLS on dataprep'd data.
%
% description:      runs behavioural partial least squares analysis using
%                   scripts from Randy McIntosh, Bratislav Misic & Mallar Chakravarty's labs
%                   (https://github.com/CoBrALab/documentation/wiki/Running-PLS-in-MATLAB-with-cross-sectional-data)
% external funcs:   plsmd, surfstat (http://www.math.mcgill.ca/keith/surfstat/)
% function:         partial_least_squares/pls.m
% function input:   data (ROI or vertex), parcellation info, average surface, glimfile, behavioural data names and descriptions
% online input:     (1) input number of latent variables (LV) to extract (PermSig < desired alpha)
%                   (2) decide whether to flip each LV (to aid interpretation)
%
% output: 
%       (1) 
%       (2) pls structure:
%           .recode:                structure displaying string variables recoded to numeric and numeric assignment (row 1 = value 1)
%           .X:                     surface data
%           .zX:                    z-scored surface data
%           .Y:                     behavioural data
%           .zY:                    z-scored surface data
%           .beh:                   behavioural data labels
%           .opt:                   PLS options (num permutations, num bootstrap samples, etc)
%           .result:                PLS results (see .result.field_descrip)
%           .pct_cov:               Percent covariance explained by each latent variable
%           .nLVs:                  Number latent variables extracted
%           .flip:                  Flip info for each LV (1 = no flip, -1 = flip)
%
% NOTE: PLS will fail if there are any missing data!

mkdir pls
Y = zeros(size(X,1), size(behvars, 2));
for j = 1 : size(behvars, 2)
    varclass = class(glimfile.(behvars{j}));
    switch varclass
        case 'cell'
            [numervar, id] = findgroups(glimfile.(behvars{j}));
            Y(:,j) = numervar;
            p.recode.(behvars{j}).numervar = numervar;
            p.recode.(behvars{j}).id = id;
        case 'double'
            Y(:,j) = glimfile.(behvars{j});
    end
end

% Prepare PLS data
nsubjs = size(X,1);
zX = zscore(X);
datamat{1} = zX;
zY = zscore(Y);
option.method = 3; % behaviour PLS
option.num_perm = 1000;
option.num_boot = 1000;
option.stacked_behavdata = zY;

p.X = X;
p.zX = zX;
p.Y = Y;
p.zY = zY;
p.beh = behdesc;
p.opt = option;
% Run PLS
p.result = pls_analysis(datamat, nsubjs, 1, option);

%% Outputs

% Component p-values
% result.perm_result.sprob

% Percent covariance / p values
p.pct_cov = (p.result.s.^2)/sum(p.result.s.^2);
figure;
scatter(p.result.perm_result.sprob, p.pct_cov(:,1), 'b', 'filled')
set(gca,'FontSize',16)
xlabel('Permutation p-value')
ylabel('Percent Covariance')

comps = 1:size(p.pct_cov,1);
table(comps',p.result.perm_result.sprob, p.pct_cov, 'VariableNames', {'LV', 'PermSig', 'PercCov'})
saveas(gcf, fullfile('pls', 'PermutationPvalues.fig'))
saveas(gcf, fullfile('pls', 'PermutationPvalues.png'))

% Select components
nLVs = inputdlg('Enter number of LVs');
p.nLVs = str2num(nLVs{1});

for i = 1:p.nLVs
    flipval = 1;
    sv = 0;
    plsbar(p.result, i, flipval, behdesc, sv) % behavioural data
    plssurf(info, avsurf, p.result, i, flipval, sv) % brain data
    % flip LV?
    flipyn = questdlg(['Flip LV' num2str(i) '?'], 'Flip', 'Yes', 'No', 'Yes');
    if strcmp(flipyn,'Yes')
        p.flip.(['LV' num2str(i)]) = -1;
    else
        p.flip.(['LV' num2str(i)]) = 1;
    end
    flipval = p.flip.(['LV' num2str(i)]);
    sv = 1;
    % final behavioural
    plsbar(p.result, i, flipval, behdesc, sv)
    % final brain
    plssurf(info, avsurf, p.result, i, flipval, sv)   
end