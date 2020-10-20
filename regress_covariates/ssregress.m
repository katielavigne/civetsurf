function [model, X, coef, Yresid] = ssregress(Y, glimfile, predvars)
% SSREGRESS SurfStat-based regression for regressing out nuisance
% variables.
%
% description:      regresses out nuisance variables from data
% external funcs:   surfstat (http://www.math.mcgill.ca/keith/surfstat/)
% function:         regress_covariates/ssregress.m
% function input:   ROI or vertex data (data.SCdata or data.parc.ROIs), glimfile, covariate names (from data.gfields)
% online input:     none
%
% output: adds two fields to data structure
%           .residmodel:            string showing GLM model used to get residuals
%           .resid:                 residualized ROI surface data

X = [];
for j = 1 : size(predvars, 2)
    X{j}= glimfile.(predvars{j});
end

M = 1;
model = '1 + ';
for i = 1:size(X,2)
    M = M + term(X{i});
    model = [model predvars{i}];
    if i ~= size(X,2)
        model = [model ' + '];
    end
end
slm = SurfStatLinMod(Y,M);
X = slm.X;
coef = slm.coef;
Yresid = Y - X*coef;