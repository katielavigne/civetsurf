function plsbar(result, LVnum, flipval, behdesc)
% PLSBAR Creates bar graphs for PLS-derived latent variables.

figure;
bardata = result.lvcorrs(:,LVnum)*flipval;
b = barh(bardata); hold on
    b.FaceColor = 'flat';
    b.LineStyle = 'none';
if isfield(result.boot_result, 'ulcorr')
    upper = result.boot_result.ulcorr(:,LVnum)- result.lvcorrs(:,LVnum);
    upper = upper*flipval;
    lower = result.lvcorrs(:,LVnum) - result.boot_result.llcorr(:,LVnum);
    lower = lower*flipval;
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
else
    for j = 1:size(bardata,1)
        b.CData(j,:) = [.65, .84, 1];
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

if flipval == 1
    saveas(gcf, fullfile('pls', ['LV' num2str(LVnum) '_BehaviouralLoadings.fig']))
    saveas(gcf, fullfile('pls', ['LV' num2str(LVnum) '_BehaviouralLoadings.png']))
else
    saveas(gcf, fullfile('pls', 'flipped', ['LV' num2str(LVnum) '_BehaviouralLoadings_flipped.fig']))
    saveas(gcf, fullfile('pls', 'flipped', ['LV' num2str(LVnum) '_BehaviouralLoadings_flipped.png']))
end
