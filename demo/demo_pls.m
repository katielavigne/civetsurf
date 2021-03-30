%% Demo script for civetsurf - PLS
% Author: Katie Lavigne

%% Data Preparation (required as initial setup)
% Prepare CIVET-processed structural MRI data & glimfile for analysis.

help dataprep % view instructions for this step

data = dataprep(); % create data structure
save civetsurf_data.mat % save output

%% Parcellation (optional, order with other optional sections varies by study)
% Create parcellation for vertex data.

help parcellate % view instructions for this step

[data.parc] = parcellate(data.Y.smooth20mm, data.avsurf, data.mask, 'dkt', pwd); % parcellate
save civetsurf_parc.mat data % save output

%% Add Variables (optional, order with other optional sections varies by study)
% Append variables to data matrix.

help addglimvars % view instructions for this step

data.gfields % list possible variables to add
vars = {'var1'; 'var2'}; % define variables to add using variable names from data.gfields
data = addglimvars(data.parc.ROIs, data.parc.pinfo, data.glimfile, vars, 'Hippo'); % add variables to parcellated data

%% Regress Out Covariates (optional, order with other optional sections varies by study)
% Regress covariates out of data.

help ssregress % view instructions for this step

covars = {'meanCorticalMeasure20mm'}; % define covariates using variables from data.gfields
[data.residmodel, ~, ~, data.resid] = ssregress(data.ROIs_Hippo, data.glimfile, covars); % regress out covariates
save civetsurf_resid.mat data % save output

%% Partial Least Squares
% Run partial least squares behaviour analysis.

help pls % view instructions for this step

% Define behavioural variables (behvars) and descriptions for plotting (behdesc) using variable names from data.gfields
behvars = {'var1', 'var2' 'var3', 'var4'};
behdesc = {'var1name', 'var2name', 'var3name', 'var4name'};

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