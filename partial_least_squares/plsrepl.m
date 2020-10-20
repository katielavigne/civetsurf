function repdata = plsrepl(newdata, oldres, outdir, behvars, behdesc)
%PLSREPL Apply previous PLS model to new dataset.
%
% description:      applies previous PLS model to new dataset
% external funcs:   plsmd, surfstat (http://www.math.mcgill.ca/keith/surfstat/)
% function:         partial_least_squares/plsrepl.m
% function input:   new data (ROI or vertex), previous PLS result, output directory, behavioural data names, behavioural data descriptions
% online input:     none

repdata.Y = zeros(size(newdata.resid,1), size(behvars, 2));
for j = 1 : size(behvars, 2)
    repdata.Y(:,j) = newdata.glimfile.(behvars{j});
end

repdata.predbrainscores = newdata.resid*oldres.result.u;
repdata.corr = corr(repdata.predbrainscores,repdata.Y);

nLVs = oldres.nLVs;
for i = 1:nLVs
    % Behavioural Data
    repdata.bardata = repdata.corr(:,i)*oldres.flip.(['LV' num2str(i)]);
    % bar graph
    h = figure;
    b = barh(repdata.bardata); hold on
        b.FaceColor = 'flat';
        b.LineStyle = 'none';
        b.CData(:,1) = .65;
        b.CData(:,2) = .84;
        b.CData(:,3) = 1;
    hold off
    % figure properties
    xlabel('Loading')
    set(gca,'TickLabelInterpreter','none', ...
        'Ytick',1:numel(behdesc), ...
        'YTickLabel',behdesc, ...
        'TickDir', 'out', ...
        'FontSize',10, ...
        'FontName', 'Century Schoolbook', ...
        'Box', 'off');
    set(gcf, 'color', 'w')

    saveas(gcf, fullfile(outdir, ['LV' num2str(i) '_CognitionSaliences.fig']))
    saveas(gcf, fullfile(outdir, ['LV' num2str(i) '_CognitionSaliences.png']))

    plssurf(newdata.parc.pinfo, newdata.avsurf, oldres.result, i, 1, 1)
end