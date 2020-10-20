function plsbar(result, compnum, flipval, behdesc, sv)
% PLSBAR Creates bar graphs for PLS-derived latent variables.

figure;
bardata = result.lvcorrs(:,compnum)*flipval;
upper = result.boot_result.ulcorr(:,compnum)- result.lvcorrs(:,compnum);
upper = upper*flipval;
lower = result.lvcorrs(:,compnum) - result.boot_result.llcorr(:,compnum);
lower = lower*flipval;

b = barh(bardata); hold on
    b.FaceColor = 'flat';
    b.LineStyle = 'none';
if flipval == 1
    er = errorbar(bardata, 1:size(bardata,1), lower, upper, 'k', 'horizontal');
        er.LineStyle = 'none';
        er.Marker = 'none';
elseif flipval == -1
    er = errorbar(bardata, 1:size(bardata,1), upper, lower, 'k', 'horizontal');
        er.LineStyle = 'none';
        er.Marker = 'none';
end
for j = 1:size(bardata,1)
    if sign(bardata(j) + upper(j)) == sign(bardata(j) - lower(j))
        b.CData(j,:) = [.65, .84, 1];
    else
        b.CData(j,:) = [.8, .8, .8];
    end
end
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
if sv == 1
    saveas(gcf, fullfile('pls', ['LV' num2str(compnum) '_CognitionSaliences.fig']))
    saveas(gcf, fullfile('pls', ['LV' num2str(compnum) '_CognitionSaliences.png']))
end