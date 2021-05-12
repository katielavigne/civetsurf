function [p] = parcellate(d, avsurf, mask, pscheme, dir)
% PARCELLATE Create parcellation for vertex data.
%
% description:      parcellates data into ROIs based on atlas templates
% external funcs:   none
% function:         parcellation/parcellate.m
% function input:   data, CIVET average surface, CIVET mask, parcellation ('aal', 'dkt'), output directory
% online input:     none
%
% output: 
%   (1) saves parcellation figure in current working directory
%   (2) data.parc sub-structure
%           .pscheme:               parcellation scheme ('DKT' or 'AAL')
%           .pinfo:                 pre-defined parcellation info (labels, vertex assignments, etc)
%           .ROIverts:              identical to data.parc.pinfo.ROIverts
%           .ROIs:                  parcellated surface data

p.pscheme = upper(pscheme);
load([p.pscheme 'info.mat'], 'info')
p.pinfo = info;
nROIs = size(p.pinfo.description,1);
p.ROIverts = p.pinfo.ROIverts;
switch p.pscheme
    case 'DKT'
        p.ROIverts(p.ROIverts==6) = 0;
        p.ROIverts(p.ROIverts==106) = 0;
end
[nscans, ~] = size(d);

% show parcellation
h = figure(1);
FigTitle = [p.pscheme ' Parcellation'];
SurfStatView(p.pinfo.ROIverts.*mask, avsurf, FigTitle);
saveas(h, fullfile(dir, [FigTitle '.png']))

% parcellate
p.ROIs = zeros(nscans, nROIs);
for i = 1:nscans
    for j = 1:nROIs
        dummy_ROIs = p.ROIverts==p.pinfo.label_number(j);
        p.ROIs(i,j) = sum(d(i,:).*dummy_ROIs)/sum(dummy_ROIs);
    end
end