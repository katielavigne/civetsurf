function plsbar(result, LVnum, flipval, behdesc, gnames)
% PLSBAR Creates bar graphs for PLS-derived latent variables.

bardata = result.lvcorrs(:,LVnum)*flipval;

% Define colours (up to 5 groups: blue, red, green, purple, yellow)
barcolours = [0.3010, 0.7450, 0.9330; ...
    0.6350, 0.0780, 0.1840; ...
    0.4660, 0.6740, 0.1880; ...
    0.4940, 0.1840, 0.5560; ...
    0.9290, 0.6940, 0.1250];
    
%Define groups
ngroups = size(gnames,1);
if ngroups > 0
    grnums = 1:ngroups;
    grouprep = repmat(grnums,1,size(behdesc,2))';
    % Reorganize data for group plotting
    tmp = zeros(size(bardata,1)+size(behdesc,2),1);
    for g = 1:ngroups
        tmp(g:ngroups+1:end) = bardata(g:ngroups:end);
    end
    bardata = tmp;
else
    grouprep(1:size(behdesc,2),1) = 1;
end % if group

f = figure;
f.Position(3:4) = [700 700];
movegui(f,'center')

b = barh(bardata); hold on
    b.FaceColor = 'flat';
    b.LineStyle = 'none';
if isfield(result.boot_result, 'ulcorr')
    upper = result.boot_result.ulcorr(:,LVnum)- result.lvcorrs(:,LVnum);
    upper = upper*flipval;
    lower = result.lvcorrs(:,LVnum) - result.boot_result.llcorr(:,LVnum);
    lower = lower*flipval;
    % Reorganize error bars for group plotting
    if ngroups > 1
        uppertmp = zeros(size(bardata,1),1);
        lowertmp = zeros(size(bardata,1),1);
        for g = 1:ngroups
            uppertmp(g:ngroups+1:end) = upper(g:ngroups:end);
            lowertmp(g:ngroups+1:end) = lower(g:ngroups:end);
        end % for groups
        upper = uppertmp;
        lower = lowertmp;
    end % if group
    if flipval == 1
        er = errorbar(bardata, 1:size(bardata,1), lower, upper, 'k', 'horizontal');
            er.LineStyle = 'none';
            er.Marker = 'none';
    elseif flipval == -1
        er = errorbar(bardata, 1:size(bardata,1), upper, lower, 'k', 'horizontal');
            er.LineStyle = 'none';
            er.Marker = 'none';
    end % if flip
    
    k = 1;
    for j = 1:size(bardata,1)
        if lower(j) ~= 0 % skip blanks
            if sign(bardata(j) + upper(j)) == sign(bardata(j) - lower(j))
                b.CData(j,:) = barcolours(grouprep(k),:);
            else
                b.CData(j,:) = [.8, .8, .8];
            end % if significant
            k = k + 1;
        end % if blank
    end % for vars
else
    for j = 1:size(bardata,1)
        b.CData(j,:) = [0.3010, 0.7450, 0.9330];
    end % for vars
end

if ngroups > 1
    for g = ngroups:-1:1
        p(g) = plot(NaN,NaN, ...
            'DisplayName', gnames{g}, ...
            'color', barcolours(g,:), ...
            'LineWidth', 8);
    end % for groups
    b.Annotation.LegendInformation.IconDisplayStyle = 'off';
    er.Annotation.LegendInformation.IconDisplayStyle = 'off';
    legend('Location', 'best')
end % if groups

hold off

% figure properties
xlabel('Loading')
if ngroups > 1
    set(gca, 'Ytick', (ngroups+1)/2:ngroups+1:size(bardata,1));
else
    set(gca, 'Ytick',1:numel(behdesc));
end % if groups
set(gca,'TickLabelInterpreter','none', ...
    'YTickLabel',behdesc, ...
    'TickDir', 'out', ...
    'FontSize',14, ...
    'FontName', 'Century Schoolbook', ...
    'Box', 'off');
set(gcf, 'color', 'w')


if flipval == 1
    saveas(gcf, fullfile('pls', ['LV' num2str(LVnum) '_BehaviouralLoadings.fig']))
    saveas(gcf, fullfile('pls', ['LV' num2str(LVnum) '_BehaviouralLoadings.png']))
else
    saveas(gcf, fullfile('pls', 'flipped', ['LV' num2str(LVnum) '_BehaviouralLoadings_flipped.fig']))
    saveas(gcf, fullfile('pls', 'flipped', ['LV' num2str(LVnum) '_BehaviouralLoadings_flipped.png']))
end % if flip
