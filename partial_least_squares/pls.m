function p = pls(X, data, behvars, behdesc)
% PLS Runs behavioural PLS on dataprep'd data.
%
% description:      runs behavioural partial least squares analysis using
%                   scripts from Randy McIntosh, Bratislav Misic & Mallar Chakravarty's labs
%                   (https://github.com/CoBrALab/documentation/wiki/Running-PLS-in-MATLAB-with-cross-sectional-data)
% external funcs:   plsmd, surfstat (http://www.math.mcgill.ca/keith/surfstat/)
% function:         partial_least_squares/pls.m
% function input:   data (ROI or vertex), data structure (from dataprep), behavioural data names and descriptions
%
% NOTE: Group PLS requires imaging data in stacked cell arrays (see demo_pls.m)
%
% output: 
%       (1) pls folder with results
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
mask = data.mask;
avsurf = data.avsurf;
glimfile = data.glimfile;

% Check parc
if isfield(data, 'parc')
    info = data.parc.pinfo;
else
    error('Parcellation required for region-based outputs. Please run parcellate.m.')
end %if parc

% Group PLS
if iscell(X) && isfield(data, 'gnames')
    group = 1;
    ngroups = size(data.gnames,1);
elseif iscell(X) || isfield(data, 'gnames')
    error(sprintf('You must define groups for stacked data, e.g: \n data.group = categorical(data.glimfile.Group); \n data.gnames = categories(data.group);'))
else
    group = 0;
    ngroups = 1;
    data.gnames = {};
end %if group

% Vertex PLS - mask out non-brain
vertex = 0;
if group == 1
    if size(X{1},2) == size(mask,2)
        vertex = 1;
        for g = 1:ngroups
            X{g} = X{g}(:,mask);
        end %for
    end %if
elseif group == 0 
    if size(X,2) == size(mask,2)
        vertex = 1;
        X = X(:,mask);
    end %if vertex
end %if group

% Define behavioural data
Y = zeros(size(glimfile,1), size(behvars, 2));
for j = 1 : size(behvars, 2)
    try varclass = class(glimfile.(behvars{j})); catch warning([behvars{j} ' issue']); end %try
    switch varclass
        case 'cell'
            [numervar, id] = findgroups(glimfile.(behvars{j}));
            Y(:,j) = numervar;
            p.recode.(behvars{j}).numervar = numervar;
            p.recode.(behvars{j}).id = id;
        case 'double'
            Y(:,j) = glimfile.(behvars{j});
    end %switch
end %for vars

% Prepare PLS data
switch group
    case 0
        nsubjs = size(X,1);
        zX = zscore(X);
        datamat{1} = zX;
    case 1
        nsubjs = {};
        for g = 1:ngroups
            nsubjs{g,1} = size(X{g},1);
            zX{g,1} = zscore(X{g});
            datamat{g,1} = zX{g,1};
        end %for groups
end %switch

option.method = 3; % behaviour PLS
option.num_perm = 1000;
option.num_boot = 1000;
zY = zscore(Y);
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
p.pct_cov = ((p.result.s.^2)/sum(p.result.s.^2))*100;
f = figure;
movegui(f, 'center')
scatter(p.result.perm_result.sprob, p.pct_cov(:,1), 'b', 'filled')
set(gca,'FontSize',16)
xlabel('Permutation p-value')
ylabel('Percent Covariance')
saveas(gcf, fullfile('pls', 'PermutationPvalues.fig'))
saveas(gcf, fullfile('pls', 'PermutationPvalues.png'))

% Text output
% LV permutations
LVs = 1:size(p.pct_cov,1);
T = table(LVs',p.result.perm_result.sprob, p.pct_cov, 'VariableNames', {'LatentVariable', 'PermutationSignificant', 'PercentVariance'});
writetable(T, fullfile('pls', 'LV_variance_permutation_results.csv'))

% Behavioural Loadings
mkdir(fullfile('pls', 'flipped'))

if ngroups == 1
    T = table(behdesc', 'VariableNames', {'BehaviouralVariables'});
    Tf = T;
else
    grouprep = repmat(data.gnames',size(behdesc,2),1);
    T = table(grouprep(:), repmat(behdesc',ngroups,1), 'VariableNames', {'Group','BehaviouralVariables'});
    Tf = T;
end % if ngroups

for j = 1:size(LVs,2)
    T = [T table(p.result.lvcorrs(:,j), 'VariableNames', {['LV' num2str(j)]})];
    Tf = [Tf table(p.result.lvcorrs(:,j)*-1, 'VariableNames', {['LV' num2str(j)]})]; %flipped
end %for LVs

writetable(T, fullfile('pls', 'BehaviouralLoadings.csv'))
writetable(Tf, fullfile('pls', 'flipped', 'BehaviouralLoadings_flipped.csv'))

% Boot Ratios
tboot = {};
n = 1;
if vertex == 1
    tmpverts = info.ROIverts(mask);
    for j = 1:size(tmpverts,2)
        roi = tmpverts(j);
        tboot{n,1} = n;
        if roi == 0
            [tboot{n,2},tboot{n,3}] = deal('');
        else
            tboot{n,2} = info.abbreviation{info.number == tmpverts(j)};
            tboot{n,3} = info.description{info.number == tmpverts(j)};
        end
        n = n + 1;
    end
else % assuming non-vertex data will be parcellated with parcellate.m
    for j = 1:size(info.abbreviation, 1)
        tboot{n,1} = n;
        tboot{n,2} = info.abbreviation{j};
        tboot{n,3} = info.description{j};
        n = n + 1;
    end
end %if vertex

tboot = cell2table(tboot, 'VariableNames', {'BrainVariable', [info.name 'abbreviation'], [info.name 'description']});
Tb = tboot;
Tbf = tboot;

for k = 1:size(LVs,2)
    Tb = [Tb table(p.result.boot_result.compare_u(:,k), 'VariableNames', {['LV' num2str(k)]})];
    Tbf = [Tbf table(p.result.boot_result.compare_u(:,k)*-1, 'VariableNames', {['LV' num2str(k)]})]; % flipped
end

writetable(Tb, fullfile('pls', 'BootRatios.csv'))
writetable(Tbf, fullfile('pls', 'flipped', 'BootRatios_flipped.csv'))

% Extract LVs
for i = 1:size(p.pct_cov,1)
    if p.result.perm_result.sprob(i) <= 0.05
        flipval = 1;
        plsbar(p.result, i, flipval, behdesc, data.gnames) % behavioural data
        plssurf(info, mask, avsurf, p.result, i, flipval, [1.96, 2.58], 'Bootstrap Ratios') % brain data
        % flipped
        flipval = -1;
        plsbar(p.result, i, flipval, behdesc, data.gnames) % behavioural data
        plssurf(info, mask, avsurf, p.result, i, flipval, [1.96, 2.58], 'Bootstrap Ratios') % brain data
    end
end