function plotcovmatrix(C, figtitle, pscheme, savedir, atlaslabels)
% PLOTCOVMATRIX Create and save covariance matrix figure.

h = figure();
imagesc(C), colorbar
if length(C) < 500
    L = get(gca,'XLim');
    set(gca,'XTick',linspace(L(1),L(2),size(C,2)));
    O = get(gca,'YLim');
    set(gca,'YTick',linspace(O(1),O(2),size(C,2)));
    set(gca,'XTickLabel',atlaslabels);
    set(gca,'YTickLabel',atlaslabels);rotateXLabels(gca,90);
    title(figtitle, 'Interpreter', 'None');
else
    set(gca,'xticklabel',{[]})
    set(gca,'yticklabel',{[]})
end
colormap(jet)
set(gcf, 'Position', [80.20 78.60 892.80 674.40]);
set(gca, 'FontSize', 8)
saveas(h, fullfile(savedir, [figtitle '_' pscheme '.fig']))
saveas(h, fullfile(savedir, [figtitle '_' pscheme '.png']))