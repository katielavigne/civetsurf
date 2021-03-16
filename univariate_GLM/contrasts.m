function results = contrasts(uniGLM, contrast, ctype, predname)
% CONTRASTS Compare GLM contrasts based on user-defined general linear model.

cname = strrep(contrast.name,'*', 'X');
% Run analysis
results.slm = SurfStatT(uniGLM.slm,contrast.value); % t-statistics
try % RFT threshold (change P value if error!) % TO DO - output cluster-defining threshold used!
    [results.RFT.pval,results.RFT.peak,results.RFT.clus,results.RFT.clusid]=SurfStatP(results.slm,uniGLM.mask,0.005);
catch
    try
        [results.RFT.pval,results.RFT.peak,results.RFT.clus,results.RFT.clusid]=SurfStatP(results.slm,uniGLM.mask,0.001);
    catch
        [results.RFT.pval,results.RFT.peak,results.RFT.clus,results.RFT.clusid]=SurfStatP(results.slm,uniGLM.mask,0.05);
    end
end
results.FDR.qval = SurfStatQ(results.slm, uniGLM.mask); % FDR threshold

% View/Save results
% % T-statistics
f1=figure(); set(f1,'OuterPosition',[100 100 800 700]);
title1=['T-statistic Map of ' ctype ' ' predname '_' cname ' (df=' num2str(results.slm.df) ')'];
set(f1, 'NumberTitle', 'off', 'Name', title1);
SurfStatView(results.slm.t.*uniGLM.mask,uniGLM.avsurf,'T-statistic'); SurfStatColLim([-4.5 4.5]);
saveas(f1, fullfile(uniGLM.outdir, [title1 '.png']));

% RFT corrected
f2=figure(); set( f2,'OuterPosition',[100 100 800 700]);
title2=['RFT-Corrected Vector of ' ctype ' ' predname '_' cname ' (df=' num2str(results.slm.df) ')'];
set(f2, 'NumberTitle', 'off', 'Name', title2);
SurfStatView(results.RFT.pval,uniGLM.avsurf,'RFT-corrected'); 
saveas(f2, fullfile(uniGLM.outdir, [title2 '.png']));

if ~isempty(results.RFT.peak)
    % Output RFT Results
    diary(fullfile(uniGLM.outdir,[cname '_RFT_output.txt']))
    term(results.RFT.clus) 
    term(results.RFT.peak) + term(SurfStatInd2Coord(results.RFT.peak.vertid, uniGLM.avsurf)', {'x','y','z'})   %#ok<NOPRT>
    diary off
end

% FDR-corrected
f3=figure(); set( f3,'OuterPosition',[100 100 800 700]);
title3=['FDR-Corrected Vector of ' ctype ' ' predname '_' cname ' (df=' num2str(results.slm.df) ')'];
set(f3, 'NumberTitle', 'off', 'Name', title3);
SurfStatView(results.FDR.qval, uniGLM.avsurf, 'FDR-corrected');
saveas(f3, fullfile(uniGLM.outdir, [title3 '.png']));