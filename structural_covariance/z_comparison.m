function [Z, P] = z_comparison(R1, R2, N1, N2)
% Z_COMPARISON Run Fisher's z comparison on two correlation matrices.
% Adapted from Andrew Reid's Matlab Libraries for CIVET
% (http://www.modelgui.org/mgui-neuro-civet-matlab)

n = size(R1,1);
    
R1 = get_top(R1);
R2 = get_top(R2);
R1_Z = atanh(R1);
R2_Z = atanh(R2);

D = R1_Z-R2_Z;
D(isnan(D))=0;
V = (sqrt(1/(N1-3) + 1/(N2-3)));
Z = D/V;
P = 2 * normcdf(-abs(Z));

Z = put_bottom_back_on(Z,n);
P = put_bottom_back_on(P,n);