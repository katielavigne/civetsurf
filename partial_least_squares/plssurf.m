function plssurf(info, avsurf, result, LVnum, flipval)
% PLSSURF Creates cortical surface figures for PLS-derived latent variables.

X = result.boot_result.compare_u(:,LVnum)*flipval;

if size(result.u,1)>1000
    output = X;
else
    atlas = info.ROIverts';
    rois = info.label_number;
    output = roi2data(X,atlas, rois);
end
% Bootstrap Ratios
figure;
SurfStatView(output, avsurf, 'Bootstrap Ratios');
if flipval == 1
    saveas(gcf, fullfile('pls', ['LV' num2str(LVnum) '_BootRatios.fig']))
    saveas(gcf, fullfile('pls', ['LV' num2str(LVnum) '_BootRatios.png']))
else
    saveas(gcf, fullfile('pls', 'flipped', ['LV' num2str(LVnum) '_BootRatios_flipped.fig']))
    saveas(gcf, fullfile('pls', 'flipped', ['LV' num2str(LVnum) '_BootRatios_flipped.png']))
end
%colormap
thresh = [1.96, 2.58]; % 0.05, 0.01
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
    SurfStatView(output, avsurf, 'Bootstrap Ratios');
    colormap(cmap)
    if flipval == 1
        saveas(gcf, fullfile('pls', ['LV' num2str(LVnum) '_' num2str(thresh(j)) '_BootRatios.fig']))
        saveas(gcf, fullfile('pls', ['LV' num2str(LVnum) '_' num2str(thresh(j)) '_BootRatios.png']))
    else
        saveas(gcf, fullfile('pls', 'flipped', ['LV' num2str(LVnum) '_' num2str(thresh(j)) '_BootRatios_flipped.fig']))
        saveas(gcf, fullfile('pls', 'flipped', ['LV' num2str(LVnum) '_' num2str(thresh(j)) '_BootRatios_flipped.png']))
    end
end