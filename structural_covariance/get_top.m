function [ top ] = get_top (matrix)
% GET_TOP Generate top half of correlation matrix
% Adapted from Andrew Reid's Matlab Libraries for CIVET
% (http://www.modelgui.org/mgui-neuro-civet-matlab)

N = size (matrix,1);
S = size (matrix,3);
M = (N * (N - 1)) / 2;
top = zeros(M,S);

k = 1;
for i = 1:N
    for j=i+1:N
        top(k,:) = matrix(i,j,:);
        k = k + 1;
    end
end