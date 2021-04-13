function repdata = plsrepl(newdata, oldres, behvars, behdesc, LV)
%PLSREPL Apply previous PLS model to new dataset.
%
% description:      applies previous PLS model to new dataset
% external funcs:   plsmd, surfstat (http://www.math.mcgill.ca/keith/surfstat/)
% function:         partial_least_squares/plsrepl.m
% function input:   new data, previous PLS result, behavioural data names, behavioural data descriptions, LV to project to
% online input:     none

mkdir pls
repdata.Y = zeros(size(newdata.resid,1), size(behvars, 2));
for j = 1 : size(behvars, 2)
    varclass = class(newdata.glimfile.(behvars{j}));
    switch varclass
        case 'cell'
            [numervar, id] = findgroups(newdata.glimfile.(behvars{j}));
            repdata.Y(:,j) = numervar;
            p.recode.(behvars{j}).numervar = numervar;
            p.recode.(behvars{j}).id = id;
        case 'double'
            repdata.Y(:,j) = newdata.glimfile.(behvars{j});
    end
end

repdata.predbrainscores = newdata.resid*oldres.result.u(:,LV);
repdata.corr = corr(repdata.predbrainscores,repdata.Y);
tmp.boot_result.compare_u = repdata.predbrainscores;
tmp.lvcorrs = repdata.corr';

mkdir(fullfile('pls', 'flipped'))
flipval = 1;
plsbar(tmp, 1, flipval, behdesc) % behavioural data
plssurf(newdata.parc.pinfo, newdata.mask, newdata.avsurf, tmp, 1, flipval, [.2, .5], 'Correlations') % brain data
% flipped
flipval = -1;
plsbar(tmp, 1, flipval, behdesc) % behavioural data
plssurf(newdata.parc.pinfo, newdata.mask, newdata.avsurf, tmp, 1, flipval, [.2, .5], 'Correlations') % brain data