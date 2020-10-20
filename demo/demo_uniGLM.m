%% Demo script for civetsurf - mass univariate GLM
% Author: Katie Lavigne

%% Data Preparation (required as initial setup)
% Prepare CIVET-processed structural MRI data & glimfile for analysis.

help dataprep % view instructions for this step

data = dataprep(); % create data structure
save civetsurf_data.mat % save output

%% Run Mass Univariate GLM
% Run user-defined general linear model.

help runGLM % view instructions for this step

uniGLM_results = runGLM(data, data.Y.smooth20mm, pwd); % run analysis