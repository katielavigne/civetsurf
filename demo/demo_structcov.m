%% Demo script for civetsurf - structural covariance
% Author: Katie Lavigne

%% Data Preparation (required as initial setup)
% Prepare CIVET-processed structural MRI data & glimfile for analysis.

help dataprep % view instructions for this step

data = dataprep(); % create data structure
save civetsurf_data.mat % save output

%% Parcellation
% Create parcellation for vertex data.

help parcellate % view instructions for this step

[data.parc] = parcellate(data.Y.smooth20mm, data.avsurf, data.mask, 'dkt', pwd); % run parcellation
save civetsurf_parc.mat data % save output

%% Add Variables (optional)
% Append variables to data matrix.

help addSCvars % view instructions for this step

data.gfields % list possible variables to add
vars = {'zVerbMem', 'zVisMem'}; % define variables to add using variable names from data.gfields
data.SCdata = addSCvars(data.parc.ROIs, data.glimfile, vars); % add variables to parcellated data

%% Regress Out Covariates (optional)
% Regress covariates out of data.

help ssregress % view instructions for this step

data.gfields % list possible covariates
covars = {'meanCorticalMeasure20mm'}; % define covariates using variables from data.gfields
[data.residmodel, data.X, data.coef, data.resid] = ssregress(data.SCdata, data.glimfile, covars); % regress out covariates
save civetsurf_resid.mat data % save output

%% Structural Covariance
% Run structural covariance analysis.

help structcov % view instructions for this step

mkdir structcov % create output directory
sc = structcov(data.resid, data, 'Group', fullfile(pwd,'structcov')); % run analysis
save(fullfile(pwd, 'structcov', 'civetsurf_results_structcov.mat')) % save results output

%% Jackknife bias estimation
% Create subject-specific covariance matrices.

help jackknife_bias_est % view instructions for this step

[W] = jackknife_bias_est(sc); % run analysis
save(fullfile(pwd, 'structcov', 'civetsurf_results_jackknife.mat'))
%% Graph Theory
% Generate graph theoretical measures.

help graph_measures % view instructions for this step

gr = graph_measures(W);
save(fullfile(pwd, 'structcov', 'civetsurf_resuts_graphmeasures.mat'))