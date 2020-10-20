function [ whole ] = put_bottom_back_on (top, N)
% PUT_BOTTOM_BACK_ON Convert vector representing half of correlation matrix back to full matrix.
% Adapted from Andrew Reid's Matlab Libraries for CIVET
% (http://www.modelgui.org/mgui-neuro-civet-matlab)

S = size (top,2);
whole = zeros(N,N,S);

k = 1;
for i = 1:N
    for j=i+1:N
        whole(i,j,:) = top(k,:);
        whole(j,i,:) = top(k,:);
        k = k + 1;
    end
end
