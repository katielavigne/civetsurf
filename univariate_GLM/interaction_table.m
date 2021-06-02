function interaction_table(RFT, avsurf, cname, outdir, ctype)
% INTERACTION_OUTPUT Create tables and figures for significant clusters and peaks

    load DKTinfo.mat

    n = 1;
    m = 1;
    %clusters
    clus = find(RFT.clus.P<0.05);
    for j = 1:size(clus,1)
        verts = RFT.peak.vertid(RFT.peak.clusid==j);
        for k = 1:size(verts,1)
            vlabel = info.description(info.label_number==info.ROIverts(verts(k)));
            if k == 1
                tclus.cluster(n,1) = j;
                tclus.nverts(n,1) = RFT.clus.nverts(j);
                tclus.region(n,1) = vlabel;
                tclus.mni(n,1:3) = SurfStatInd2Coord(verts(k), avsurf)';
                n = n + 1;
            else
                if isempty(vlabel)
                    continue
                end
                if strcmp(tclus.region(tclus.cluster==j:end),vlabel)==0
                    tclus.cluster(n,1) = j;
                    tclus.nverts(n,1) = RFT.clus.nverts(j);
                    tclus.region(n,1) = vlabel;
                    tclus.mni(n,1:3) = SurfStatInd2Coord(verts(k), avsurf)';
                    n = n + 1;
                end
            end
        end
    end
    %peaks
    peak = find(RFT.peak.P<0.05);
    verts = RFT.peak.vertid(peak);
    for k = 1:size(verts,1)
        vlabel = info.description(info.label_number==info.ROIverts(verts(k)));
        if isempty(vlabel)
            vlabel = {'N/A'};
        end
        tvert.vertnum(m,1) = verts(k);
        tvert.region(m,1) = vlabel;
        tvert.mni(m,1:3) = SurfStatInd2Coord(verts(k), avsurf)';
        m = m + 1;
    end
    
    if exist('tclus', 'var')
        tclus = struct2table(tclus);
        writetable(tclus, fullfile(outdir,['Cluster Locations ' ctype ' ' cname '.xlsx']))
    end

    if exist('tvert', 'var')
        tvert = struct2table(tvert);
        writetable(tvert, fullfile(outdir,['Vertex Locations ' ctype ' ' cname '.xlsx']))
    end

end