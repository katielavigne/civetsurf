function plssurf(info, avsurf, result, LVnum, flipval, thresh, figlabel)
% PLSSURF Creates cortical surface figures for PLS-derived latent variables.

X = result.boot_result.compare_u(:,LVnum)*flipval;

if isfield(info, 'metrics')
    metrics = size(info.metrics,1);
else
    metrics = 1;
end

cols = size(result.boot_result.compare_u,1)/metrics;

for i = 1:metrics    
    if cols == 81924 % vertex
        output = X;
    else
        tmp = X(1+((i-1)*cols):i*cols);
        atlas = info.ROIverts';
        rois = info.label_number;
        output = roi2data(tmp,atlas, rois);
    end
    
    if metrics > 1
        figlabel2 = [figlabel ' ' info.metrics{i}];
    else
        figlabel2 = figlabel;
    end
    
    % Bootstrap Ratios
    figure;
    [a, cb] = SurfStatView(output, avsurf, figlabel2);
    cb.Limits = [round(cb.Limits(1)) round(cb.Limits(2))];
    set(gca, 'FontSize', 14, 'FontName', 'Times')
    
    if flipval == 1
        saveas(gcf, fullfile('pls', ['LV' num2str(LVnum) strrep(figlabel2, ' ', '') '.fig']))
        saveas(gcf, fullfile('pls', ['LV' num2str(LVnum) strrep(figlabel2, ' ', '') '.png']))
    else
        saveas(gcf, fullfile('pls', 'flipped', ['LV' num2str(LVnum) strrep(figlabel2, ' ', '') '_flipped.fig']))
        saveas(gcf, fullfile('pls', 'flipped', ['LV' num2str(LVnum) strrep(figlabel2, ' ', '') '_flipped.png']))
    end

    %colormap
    valrng = linspace(min(output),max(output),256);
    for j = 1:size(thresh,2)
        bluelen = sum(valrng<=-thresh(j));
        redlen = sum(valrng >= thresh(j));
        graylen = sum(valrng > -thresh(j) & valrng < thresh(j));
        blue = [zeros(bluelen,1),linspace(0,1,bluelen)', ones(bluelen,1)];
        gray=ones(graylen,3)*0.8;
        red = [ones(redlen,1), linspace(1,0,redlen)', zeros(redlen,1)];
        cmap = [blue;gray;red];
        % Bootstrap Ratios
        figure;
        [a, cb] = SurfStatView(output, avsurf, figlabel2);
        colormap(cmap)
        cb.Limits = [round(cb.Limits(1)) round(cb.Limits(2))];
        set(gca, 'FontSize', 14, 'FontName', 'Times')
        if flipval == 1
            saveas(gcf, fullfile('pls', ['LV' num2str(LVnum) '_' num2str(thresh(j)) strrep(figlabel2, ' ', '') '.fig']))
            saveas(gcf, fullfile('pls', ['LV' num2str(LVnum) '_' num2str(thresh(j)) strrep(figlabel2, ' ', '') '.png']))
        else
            saveas(gcf, fullfile('pls', 'flipped', ['LV' num2str(LVnum) '_' num2str(thresh(j)) strrep(figlabel2, ' ', '') '_flipped.fig']))
            saveas(gcf, fullfile('pls', 'flipped', ['LV' num2str(LVnum) '_' num2str(thresh(j)) strrep(figlabel2, ' ', '') '_flipped.png']))
        end
    end
end