function [mNearestInds, vNearestDists] = FindBlocks(mX, vRefPatchInds, mSearchInds, iFrame, sConfig, isPred)
% --------------------------------------------------------------------------------------------------------- %
% Performs block matching in a single frame. Finds nearest patches to reference patch.
%
% Input:
%   mX -               3D array of video frames. [h, w, f]
%   vRefPatchInds -    Array containing upper-left indices of reference patch. [1, 3]
%   mSearchInds -      2D array containing upper-left indices to open searching window around. [k, 3]
%   iFrame -           Current frame for search.
%   sConfig -          Struct containing all parameters for algorithm.
%   isPred -           Take config parameters for predictive BM (true/false).
%
% Output:
%   mNearestInds -  2D array containing upper-left indices of nearest patches. [K, 3]
%   vNearestDists - Array distances of nearest patches from reference patch. [K, 1]
% --------------------------------------------------------------------------------------------------------- %

[h, w, ~] = size(mX);

k = size(mSearchInds, 1);
p = sConfig.sBlockMatching.patchSize;

if isPred
    m = sConfig.sBlockMatching.searchWindowP;
    s = sConfig.sBlockMatching.searchStrideP;
else
    m = sConfig.sBlockMatching.searchWindowNP;
    s = sConfig.sBlockMatching.searchStrideNP;
end

if sConfig.sTrajectoryMatching.b_apply
    if isPred
        K = sConfig.sTrajectoryMatching.maxNeighborsFrameP;
    else
        K = sConfig.sTrajectoryMatching.maxNeighborsFrameNP;
    end
else
    K = sConfig.sBlockMatching.maxNeighborsFrame;
end

%% extract reference patch:
refRow =   vRefPatchInds(1);
refCol =   vRefPatchInds(2);
refFrame = vRefPatchInds(3);
refIdx = sub2ind([h, w], refRow, refCol);

%% calculate search windows:
vRelativeInds = [flip(0:-s:-m), s:s:m]; % [1, n]
[mRelativeCols, mRelativeRows] = meshgrid(vRelativeInds, vRelativeInds); % [n, n]
mPatchStartRows = reshape(mSearchInds(:, 1), [1, 1, k]) + repmat(mRelativeRows, [1, 1, k]); % [n, n, k]
mPatchStartCols = reshape(mSearchInds(:, 2), [1, 1, k]) + repmat(mRelativeCols, [1, 1, k]); % [n, n, k]

%% handle out-of-boundary cases of the search window by masking patches that are out of frame:
mMaskRow = (mPatchStartRows >= 1) & (mPatchStartRows <= h - p + 1); % [n, n, k]
mMaskCol = (mPatchStartCols >= 1) & (mPatchStartCols <= w - p + 1); % [n, n, k]
mMask = mMaskRow & mMaskCol; % [n, n, k]
vPatchStartRows = mPatchStartRows(mMask(:));
vPatchStartCols = mPatchStartCols(mMask(:));
vPatchStartInds = sub2ind([h, w], vPatchStartRows, vPatchStartCols);
vPatchStartInds = unique(vPatchStartInds); % [N, 1] unique because patches from different windows may repeat

%% relative patch indices in frame from top-left corner:
mSinglePatchInds = (0:p-1)' + h*(0:p-1); % [p, p]
mSinglePatchInds = reshape(mSinglePatchInds, [1, size(mSinglePatchInds)]); % [1, p, p]

%% find dists:
mRefPatch = mX(refIdx + mSinglePatchInds + (refFrame-1)*h*w); % [1, p, p]
mPatches = mX(vPatchStartInds + repmat(mSinglePatchInds, [length(vPatchStartInds),1,1]) + (iFrame-1)*h*w);
mDiffPatches = mPatches - mRefPatch; % [N, p, p]
vDists = PatchesNorm(mDiffPatches, sConfig); % [N, 1]

%% get nearest patches:
[vNearestDists, vNearestInds] = mink(vDists, K);
[vRows, vCols] = ind2sub([h, w], vPatchStartInds(vNearestInds));
mNearestInds = [vRows, vCols, repmat(iFrame, [K, 1])];

end
