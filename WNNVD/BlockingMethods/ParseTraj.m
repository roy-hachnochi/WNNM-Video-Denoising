function mTrajectory = ParseTraj(mX, mSub, sConfig)
% --------------------------------------------------------------------------------------------------------- %
% Reads the trajectory from the full video using mInd
%
% Input:
%   mX -            3D array of video frames. [h, w, f]
%   mSub -          Subscripts(include frame #) of the trajectory. [M, 3]
%   sConfig -       Struct containing all parameters for algorithm.
%
% Output:
%   mTrajectory -   3D array which contains the trajectory. [h, w, f]
% --------------------------------------------------------------------------------------------------------- %

%% Inits
[h, ~, ~] = size(mX);
p = sConfig.sBlockMatching.patchSize;
vInd = sub2ind(size(mX),mSub(:,1),mSub(:,2),mSub(:,3));

%% Supplementary calculations
mSinglePatchInds = (0:p-1)' + h*(0:p-1); % [p, p]
mSinglePatchInds = reshape(mSinglePatchInds, [1, size(mSinglePatchInds)]); % [1, p, p]

%% Parse trajectory
mTrajectory = mX(vInd + repmat(mSinglePatchInds, [length(vInd),1,1]));

end
