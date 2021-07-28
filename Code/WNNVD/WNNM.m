function mB = WNNM(mA, sConfig)
% --------------------------------------------------------------------------------------------------------- %
% Performs Weighted Nuclear Norm Minimization.
% Weights are calculated inside the function and are based on singular values.
%
% Input:
%   mA -      Input matrix. [m, n]
%   sConfig - Struct containing all parameters for algorithm.
%
% Output:
%   mB - Output array after WNNM (soft-weight-thresholding). [m, n]
% --------------------------------------------------------------------------------------------------------- %

mMean =        repmat(mean(mA, 2), [1, size(mA, 2)]);
[mU, mS, mV] = svd(mA - mMean, 'econ');
vSingVals =    diag(mS);
vW =           CalcWeights(vSingVals, sConfig);
vSingValsB =   max(vSingVals - vW,0);
vNonZeroInds = (vSingValsB > 0);
mB =           mU(:,vNonZeroInds) * diag(vSingValsB(vNonZeroInds)) * mV(:,vNonZeroInds)';
mB =           mB + mMean;

end

%% ==========================================================================================================
function vW = CalcWeights(vSingVals, sConfig)
% --------------------------------------------------------------------------------------------------------- %
% Calculates weights for WNN based on singular values and noise level.
%
% Input:
%   vSingVals - Singular values of input matrix. [k, 1]
%   sConfig -   Struct containing all parameters for algorithm.
%
% Output:
%   vW - Calculated weights. [k, 1]
% --------------------------------------------------------------------------------------------------------- %

C = sConfig.sWNNM.C;
k = length(vSingVals);
noiseSigma = sConfig.sNoise.sigma/255; % TODO: we need to estimate std for each iteration (only on first it's this)
vW = C*sqrt(k)./(sqrt(max(vSingVals.^2 - k*noiseSigma^2, 0)) + 1e-16);

end
