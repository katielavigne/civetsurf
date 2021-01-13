function gr = graph_measures(W, Ci)
% GRAPH_MEASURES Generate graph theoretical measures on weighted undirected networks.
%
% description:      produces several graph metrics describing covariance matrices
% external funcs:   Brain Connectivity Toolbox (https://sites.google.com/site/bctnet)
% function:         graph_measures.m
% function input:   adjacency matrix (3d for multiple subjects/groups), defined modules (optional)
% online input:     none
%
% output: gr structure
%           .W:                             roi x roi x subject 3D matrix of adjacency matrices
%           .global_strength:               mean sum of connected weights per node
%           .global efficiency:             average inverse shortest path length
%           .strength:                      sum of connected weights per node
%           .modularity:                    structure defining network
%                                           subdivisions (Ci), modularity statistic (Q), 
%                                           and within-module degree z-score (Z)
%           .participation_coefficient:     strength of node's connections within its community
%           .local_efficiency:              gobal efficiency calculated on node neighbours
%           .betweenness_centrality:        fraction of all shortest paths containing a given node

gr.W = W;
nsubjs = size(W,3);
nrois = size(W,1);

if exist('Ci', 'var')
    Ci = repelem(Ci,nsubjs,1);
end

disp('Calculating graph measures...')
for n = 1:nsubjs
    disp([num2str(n) '/' num2str(nsubjs) '...'])
    % Autofix & Normalize
    W(:,:,n) = weight_conversion(W(:,:,n), 'autofix');
    
    % Strength
    gr.strength(n,1:nrois) = strengths_und(W(:,:,n));
    
    % Clustering Coefficient
    Wnorm = weight_conversion(W(:,:,n), 'normalize'); % not necessary if jackknife, which is already normalized (but won't change matrix)
    gr.clustcoef(n,1:nrois) = clustering_coef_wu(Wnorm);
    
    % Characteristic Path Length
    L = weight_conversion(W(:,:,n), 'lengths');
    D = distance_wei(L);
    gr.charpath(n,1) = charpath(D);
    
    % Modularity
    if ~exist('Ci', 'var')
        [gr.modularity_Ci(n,:),gr.modularity_Q(n,1)] = modularity_und(W(:,:,n));
    else
        gr.modularity_Ci = Ci;
    end
    gr.modularity_Z(n,:) = module_degree_zscore(W(:,:,n),gr.modularity_Ci(n,:)');
    gr.participation_coefficient(n,:) = participation_coef(W(:,:,n),gr.modularity_Ci(n,:));
    
    % Efficiency
    gr.global_efficiency(n,1) = efficiency_wei(W(:,:,n));
%     gr.local_efficiency(n,:) = efficiency_wei(W(:,:,n),2)'; % can take some time
    
    % Betweenness Centrality
    gr.betweenness_centrality(n,:) = betweenness_wei(L);
    gr.betweenness_centrality(n,:) = gr.betweenness_centrality(n,:)/[(nrois-1)*(nrois-2)];
end

gr.meanstrength = mean(gr.strength,2);
gr.meanclustcoef = mean(gr.clustcoef,2);
gr.meanPC = mean(gr.participation_coefficient,2);
gr.meanBC = mean(gr.betweenness_centrality,2);