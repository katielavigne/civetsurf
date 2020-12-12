function d = dataprep()
% DATAPREP Prepare CIVET-processed structural MRI data & glimfile for analysis.
%
% description:      loads behavioural (tabular) and CIVET surface (.txt files)
%                   data for analysis; includes data filtering and smoothing
% prerequisites:    (1) process surface data with CIVET (http://www.bic.mni.mcgill.ca/ServicesSoftware/CIVET-2-1-0-Introduction)
%                   (2) create tabular (subject x variable) file with desired
%                   behavioural data (surface QC, demographics, clinical,
%                   cognitive)
% external funcs:   surfstat (http://www.math.mcgill.ca/keith/surfstat/)
% function:         data_preparation/dataprep.m
% function input:   none
% online input:     (1) select glimfile
%                   (2) select filter variable(s) & input parameter(s) (optional)
%                       e.g., .Patient for Group, ~=0 for SurfaceQC, isnan
%                       to exclude missing numeric data, isempty to exclude
%                       missing string data
%                   (3) select surface metric (e.g., cortical thickness)
%                   (4) select data directory with CIVET output text files
%
% output: outputs data structure
%           .prefilter.glimfile:    user-defined glimfile
%           .id_variable:           first unique ID variable in glimfile
%           .filter:                filter information and filtered glimfile
%           .glimfile:              filtered glimfile
%           .gfields:               filtered glimfile field names
%           .avsurf:                CIVET-defined average surface
%           .mask:                  CIVET-defined mask
%           .measure:               user-selected cortical measure
%           .Y.smooth(k)mm:         surface data, smoothed at k mm (e.g., 0, 10, 20)
%           .missing:               list of subjects in glimfile missing surface data
%           .datadir:               path to user-defined data directory

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TO DO                                 
%       - Add qT1                       
%       - Add mid/white curvature       
%       - Add cortical contrast         
%       - Add multiple selection option 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[d.prefilter.glimfile, gfields, d.id_variable] = read_glimfile(); % read glimfile
[d.filter.name, d.filter.glimfile] = filter_data(d.prefilter.glimfile, gfields); % filter data

d.glimfile = d.filter.glimfile;
d.gfields = fieldnames(d.glimfile);
load('CIVETavsurf.mat', 'avsurf');
d.avsurf = avsurf;
load('CIVETmask.mat', 'mask');
d.mask = mask;

% Load data matching glimfile
measures = {'cortical thickness','surface area', 'volume', 'curvature', 'qT1'}; %, 'contrast'};
[Selection, OK] = listdlg('PromptString', 'Select surface measure:', 'ListString', measures, 'SelectionMode', 'single');
if OK == 1
    d.measure = measures{Selection};
else
    error('You must select a measure. Please re-run dataprep.')
end
[d.Y, d.glimfile, d.missingdata, d.datadir] = read_data(d);

% Smooth
d.Y = smooth_data(d.Y, d.avsurf, d.mask, 10); % Equal to 20mm

% Mean Cortical Measure
yfields = numel(fieldnames(d.Y));
yfieldnames = fieldnames(d.Y);
for i = 1:yfields
    d.glimfile.(['meanCorticalMeasure' yfieldnames{i}(7:end)]) = mean(double(d.Y.(yfieldnames{i})(:,d.mask)),2);
    d.gfields = fieldnames(d.glimfile);    
end

% Total Cortical Measure
yfields = numel(fieldnames(d.Y));
yfieldnames = fieldnames(d.Y);
for i = 1:yfields
    d.glimfile.(['totalCorticalMeasure' yfieldnames{i}(7:end)]) = sum(double(d.Y.(yfieldnames{i})(:,d.mask)),2);
    d.gfields = fieldnames(d.glimfile);    
end
