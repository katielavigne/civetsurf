%% Demo script for civetsurf - PLS
% Author: Katie Lavigne

%% Data Preparation (required as initial setup)
% Prepare CIVET-processed structural MRI data & glimfile for analysis.

help dataprep % view instructions for this step

data = dataprep(); % create data structure
save civetsurf_data.mat % save output

%% Parcellation (optional)
% Create parcellation for vertex data.

help parcellate % view instructions for this step

[data.parc] = parcellate(data.Y.smooth20mm, data.avsurf, data.mask, 'dkt', pwd); % parcellate
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

covars = {'meanCorticalMeasure20mm'}; % define covariates using variables from data.gfields
[data.residmodel, ~, ~, data.resid] = ssregress(data.parc.ROIs, data.glimfile, covars); % regress out covariates
save civetsurf_resid.mat data % save output

%% Partial Least Squares
% Run partial least squares behaviour analysis.

help pls % view instructions for this step

% Define behavioural variables (behvars) and descriptions for plotting (behdesc) using variable names from data.gfields
behvars = {'zVerbMem', 'zVisMem', 'zWorkMem', 'zProcSpeed', 'zExecFunc', 'zAtt', 'Gender', 'Age', 'Years_of_Education', 'Battery', 'SAPS_Total', 'SANS_Total', 'Antipsychotic_yn', 'meanCorticalMeasure20mm'};
behdesc = {'Verbal Memory', 'Visual Memory', 'Working Memory', 'Processing Speed', 'Executive Function', 'Attention', 'Gender', 'Age', 'Years_of_Education', 'Battery', 'SAPS_Total', 'SANS_Total', 'Antipsychotic use', 'mean CT'};

PLS = pls(data.resid, data.parc.pinfo, data.avsurf, data.glimfile, behvars, behdesc); % run pls
save(fullfile('pls', 'civetsurf_pls.mat')) % save results output
close all

%% PLS Replication
% Apply previous PLS model to new dataset.

help plsrepl % view instructions for this step

load civetsurf_pls.mat % load previous pls results
prevPLS = PLS;
clear PLS
newdata = dataprep(); % create new data structure

% OPTIONAL (should be same processing as previous pls analysis)
[newdata.parc] = parcellate(newdata.Y.smooth20mm, newdata.avsurf, newdata.mask, 'dkt', pwd); % parcellate
covars = {'meanCorticalMeasure20mm'}; % define covariates using variables from data.gfields
[newdata.residmodel, ~, ~, newdata.resid] = ssregress(newdata.parc.ROIs, newdata.glimfile, covars); % regress out covariates
% OPTIONAL END

PLSrepl = plsrepl(newdata, prevPLS, behvars, behdesc, 1); % run pls replication projecting to LV1
save(fullfile('PLSreplication', 'civetsurf_plsrepl.mat')) % save results output
close all