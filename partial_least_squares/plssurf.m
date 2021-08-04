function plssurf(info, mask, avsurf, result, LVnum, flipval, thresh, figlabel)
% PLSSURF Creates cortical surface figures for PLS-derived latent variables.

X = result.boot_result.compare_u(:,LVnum)*flipval;

if size(X,1) == sum(mask==1) % vertex
    output(mask==1) = X;
else
    atlas = info.ROIverts';
    rois = info.label_number;
    output = roi2data(X,atlas, rois);
end

% Bootstrap Ratios
f = figure;
movegui(f, 'center')
[a, cb] = SurfStatView(output, avsurf, figlabel);
cb.Limits = [round(cb.Limits(1)) round(cb.Limits(2))];
set(gca, 'FontSize', 14, 'FontName', 'Times')

if flipval == 1
    saveas(gcf, fullfile('pls', ['LV' num2str(LVnum) strrep(figlabel, ' ', '') '.fig']))
    saveas(gcf, fullfile('pls', ['LV' num2str(LVnum) strrep(figlabel, ' ', '') '.png']))
else
    saveas(gcf, fullfile('pls', 'flipped', ['LV' num2str(LVnum) strrep(figlabel, ' ', '') '_flipped.fig']))
    saveas(gcf, fullfile('pls', 'flipped', ['LV' num2str(LVnum) strrep(figlabel, ' ', '') '_flipped.png']))
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
    [a, cb] = SurfStatView(output, avsurf, figlabel);
    colormap(cmap)
    cb.Limits = [round(cb.Limits(1)) round(cb.Limits(2))];
    set(gca, 'FontSize', 14, 'FontName', 'Times')
    if flipval == 1
        saveas(gcf, fullfile('pls', ['LV' num2str(LVnum) '_' num2str(thresh(j)) strrep(figlabel, ' ', '') '.fig']))
        saveas(gcf, fullfile('pls', ['LV' num2str(LVnum) '_' num2str(thresh(j)) strrep(figlabel, ' ', '') '.png']))
    else
        saveas(gcf, fullfile('pls', 'flipped', ['LV' num2str(LVnum) '_' num2str(thresh(j)) strrep(figlabel, ' ', '') '_flipped.fig']))
        saveas(gcf, fullfile('pls', 'flipped', ['LV' num2str(LVnum) '_' num2str(thresh(j)) strrep(figlabel, ' ', '') '_flipped.png']))
    end
end