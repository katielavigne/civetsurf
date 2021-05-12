function [normW] = jackknife_bias_est(sc)
% JACKKNIFE_BIAS_EST Create subject-specific covariance matrices.
% description:      generates individual correlation matrices using a
%                   leave-one-out procedure
% function:         jackknife_bias_est.m
% function input:   sc structure from structural covariance above
% online input:     none
%
% output:           normW       subject-specific adjacency matrices (3-dimensional 
%                               region x region x subjects array based on overall 
%                               covariance matrix

n = size(sc.data,1);
normW = zeros(size(sc.data,2),size(sc.data,2),n);
% if isfield(sc, 'groups')
%     for gr = 1:size(sc.groups,2)
%         corrmtrix = sc.groups(gr).C;
%         for grsubj = 1:size(sc.groups(gr).glimfile,1)
%             LOO = sc.groups(gr).data;
%             LOO(grsubj,:) = [];
%             corrLOO = corrcoef(LOO);
%             W = corrmtrix-corrLOO;
%             tmp = W - min(W(:));
%             if gr == 1
%                 normW(:,:,grsubj) = tmp./max(tmp(:));
%             else
%                 normW(:,:,grsubj+size(sc.groups(1).data,1)) = tmp./max(tmp(:));
%             end
%             normW(1:size(normW,1)+1:end) = 1;
%         end
%     end
% else
    corrmtrix = sc.C;
    for subj = 1:size(sc.glimfile,1)
        LOO = sc.data;
        LOO(subj,:) = [];
        corrLOO = corrcoef(LOO);
        W = (n*corrmtrix)-((n-1)*corrLOO);
        % Normalize between 0 and 1
        tmp = W - min(W(:));
        normW(:,:,subj) = tmp./max(tmp(:));
        normW(1:size(normW,1)+1:end) = 1;
    end
% end