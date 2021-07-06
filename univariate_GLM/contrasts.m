function c = contrasts(uniGLM, u, ctype, predname)
% CONTRASTS Compare GLM contrasts based on user-defined general linear model.

cdir = [ctype '_' predname];
mkdir(fullfile(uniGLM.outdir,cdir))

for i = 1:size(u.selected_contrast_names,2)
    c(i).name = strrep(u.selected_contrast_names{i},'*', 'X');
    c(i).value = u.selected_contrast_values{i};
    
    % Run analysis
    r.slm = SurfStatT(uniGLM.slm,c(i).value); % t-statistics
    try % RFT threshold (change P value if error!)
        [RFT.pval,RFT.peak,RFT.clus,RFT.clusid]=SurfStatP(r.slm,uniGLM.mask,0.005);
        RFT.cluster_threshold = 0.005;
    catch
        try
            [RFT.pval,RFT.peak,RFT.clus,RFT.clusid]=SurfStatP(r.slm,uniGLM.mask,0.001);
            RFT.cluster_threshold = 0.001;
        catch
            [RFT.pval,RFT.peak,RFT.clus,RFT.clusid]=SurfStatP(r.slm,uniGLM.mask,0.05);
            RFT.cluster_threshold = 0.05;
        end
    end
    r.RFT = RFT;
    r.FDR.qval = SurfStatQ(r.slm, uniGLM.mask); % FDR threshold
    c(i).results = r;

    % View/Save results
    % % T-statistics
    f1=figure(); set(f1,'OuterPosition',[100 100 800 700]);
    title1=['T-statistic Map of ' ctype ' ' predname '_' c(i).name ' (df=' num2str(r.slm.df) ')'];
    set(f1, 'NumberTitle', 'off', 'Name', title1);
    SurfStatView(r.slm.t.*uniGLM.mask,uniGLM.avsurf,'T-statistic'); SurfStatColLim([-4.5 4.5]);
    saveas(f1, fullfile(uniGLM.outdir, cdir, [title1 '.png']));

    % RFT corrected
    f2=figure(); set( f2,'OuterPosition',[100 100 800 700]);
    title2=['RFT-Corrected Vector of ' ctype ' ' predname '_' c(i).name ' (df=' num2str(r.slm.df) ')'];
    set(f2, 'NumberTitle', 'off', 'Name', title2);
    SurfStatView(RFT.pval,uniGLM.avsurf,'RFT-corrected');
    saveas(f2, fullfile(uniGLM.outdir, cdir, [title2 '.png']));

    if ~isempty(RFT.peak)
        % Output RFT Results
        diary(fullfile(uniGLM.outdir, cdir, [c(i).name '_RFT_output.txt']))
        term(RFT.clus)
        term(RFT.peak) + term(SurfStatInd2Coord(RFT.peak.vertid, uniGLM.avsurf)', {'x','y','z'})   %#ok<NOPRT>
        diary off
        interaction_table(RFT, uniGLM.avsurf, c(i).name, fullfile(uniGLM.outdir, cdir), ctype);
    end

    % FDR-corrected
    f3=figure(); set( f3,'OuterPosition',[100 100 800 700]);
    title3=['FDR-Corrected Vector of ' ctype ' ' predname '_' c(i).name ' (df=' num2str(r.slm.df) ')'];
    set(f3, 'NumberTitle', 'off', 'Name', title3);
    SurfStatView(r.FDR.qval, uniGLM.avsurf, 'FDR-corrected');
    saveas(f3, fullfile(uniGLM.outdir, cdir, [title3 '.png']));

    close all
end