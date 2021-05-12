function SC = structcov(data, d, Group, dir)
% STRUCTCOV Run structural covariance analysis
%
% description:      runs structural covariance comparing groups
% external funcs:   surfstat (http://www.math.mcgill.ca/keith/surfstat/)
% function:         structural_covariance/structcov.m
% function input:   data (data.resid or data.SCdata or data.parc.ROIs),
%                   data structure, group variable name (from data.gfields), output directory
% online input:     select group comparison (e.g., Control - Patient or Patient - Control)
%
% output:   results figures (.fig & .png)
%       :   BrainNetViewer file outputs (.node & .edge)
%       :   new 'sc' structure
%               .groups:            structure array (number elements depends on
%                                   number of groups), consisting of
%                                   group name and group-specific data,
%                                   correlation matrix and uncorrected P values
%               .comp1 comp2 ...:   number fields depending on number of comparisons
%                                   (group pairs), consisting of comparison name (e.g.,
%                                   Control-Patient) and fisher comparison results

if size(data,2)>10000
    error('WARNING: Structural covariance on a large number of variables (e.g., all vertices) will take a very long time or run out of memory. Parcellate the data first or use a supercomputer.')
end

% Full Sample
SC.data = data;
SC.glimfile = d.glimfile;
[SC.C, SC.P] = corrcoef(data);
SC.CP = SC.C.*double(SC.P<0.05);
SC.C_fdr = SC.CP.*double(fdr_bky(SC.P, 0.05));
plotcovmatrix(SC.C, 'FullSample', d.parc.pscheme, dir, d.parc.pinfo.abbreviation)
plotcovmatrix(SC.CP, 'FullSample_Sig_Uncorrected', d.parc.pscheme, dir, d.parc.pinfo.abbreviation)
plotcovmatrix(SC.C_fdr, 'FullSample_Sig_FDR', d.parc.pscheme, dir, d.parc.pinfo.abbreviation)
make_bnv_files(d, SC.C_fdr, dir, 'BrainNet_FullSample_FDR')

% Group Pairs
if ~isempty(Group)
    Group = term(d.glimfile.(Group));
    groups = char(Group);
    if size(groups,2) > 2
        pairs = nchoosek(groups,2);
    else
        pairs = groups;
    end

    for i = 1:size(pairs,1)
        % Select order
        [Selection, ~] = listdlg('PromptString', [{'Select Contrast'}, {''}],'ListString', {[pairs{i,1} '-' pairs{i,2}], [pairs{i,2} '-' pairs{i,1}]}, 'SelectionMode', 'single');
        if Selection == 2
            pairs(i,:) = flip(pairs(i,:),2);
        end

        idx = zeros(2,1);
        for j = size(pairs,2):-1:1
            % Group-specific CT values
            g.Group = pairs{i,j};
            rows = Group.(pairs{i,j});
            g.data = data(rows == 1, :);
            g.glimfile = d.glimfile(rows ==1,:);
            % Group-specific correlations
            [g.C, g.P] = corrcoef(g.data);
%                 % Remove self-correlations % Don't remember why I did this?
%                 g.C = g.C - diag(diag(g.C));
            % Plot group-specific covariance matrices
            FigTitle = [pairs{i,j} '_Uncorrected'];
            Cplot = g.C.*double(g.P<0.05);
            plotcovmatrix(Cplot, FigTitle, d.parc.pscheme, dir, d.parc.pinfo.abbreviation)
            idx(j,1) = find(not(cellfun('isempty', strfind(groups,g.Group))));
            SC.groups(idx(j,1)) = g;
        end

        % Plot significant differences (uncorrected)
        comp.name = [pairs{i,1} ' - ' pairs{i,2}];
        [comp.Z,comp.P] = z_comparison(SC.groups(idx(1,1)).C, SC.groups(idx(2,1)).C, size(SC.groups(idx(1,1)).data,1), size(SC.groups(idx(2,1)).data,1));
        comp.ZP = comp.Z.*(comp.P<0.05);
        FigTitle = ['SC_' pairs{i,1} '-' pairs{i,2} '_Uncorrected'];
        plotcovmatrix(comp.ZP, FigTitle, d.parc.pscheme, dir, d.parc.pinfo.abbreviation)

        % Threshold pvalues through 2-stage FDR
        P_top = get_top(comp.P);
        fdr_top = fdr_bky(P_top, 0.05, 'yes');
        comp.fdr=put_bottom_back_on(fdr_top,size(g.C,2));
        comp.ZPfdr = comp.ZP.*comp.fdr;
        FigTitle = [pairs{i,1} '-' pairs{i,2} '_FDR'];
        plotcovmatrix(comp.ZPfdr, FigTitle, d.parc.pscheme, dir, d.parc.pinfo.abbreviation)

        % Output significant (corrected) correlations
        if sum(sum(comp.fdr)) > 0
            fid = fopen(fullfile(dir,['Significant_' pairs{i,1} '-' pairs{i,2} '_FDRcorrected.txt']), 'w');
            fprintf(fid,'Region Pair\tZ difference score\tP-value\n');
            for j = 1:length(comp.fdr)
                for k = j+1:length(comp.fdr)
                    if comp.fdr(j,k,:) == 1
                        fprintf(fid, [d.parc.pinfo.description{j} ' - ' d.parc.pinfo.description{k} '\t' num2str(comp.ZP(j,k)) '\t' num2str(comp.P(j,k)) '\n']);
                    end
                end
            end
            make_bnv_files(d, comp.ZPfdr, dir, ['BrainNet_' pairs{i,1} '-' pairs{i,2} '_FDR']);
        end
        SC.(['comp' num2str(i)]) = comp;
    end
end