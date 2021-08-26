function [mGroupIndices, vNumNeighbors] = BlockMatching(mX, mRefPatchInds, refFrame, sConfig, isWaitbar)
% --------------------------------------------------------------------------------------------------------- %
% Performs block matching per reference patch - find nearest (most similar) patches to each reference patches
% in entire video.
%
% Input:
%   mX -            3D array of video frames. [h, w, f]
%   mRefPatchInds - 2D array containing upper-left indices of reference patches. [N, 2]
%   refFrame -      Reference frame number for key-patches.
%   sConfig -       Struct containing all parameters for algorithm.
%   isWaitbar -     (optional) Display waitbar (default: false).
%
% Output:
%   mGroupIndices - 3D array containing upper-left indices of patches in group per reference patch. [N, K, 3]
%   vNumNeighbors - Array containing number of effective neighbors per reference patch. [N, 1]
% --------------------------------------------------------------------------------------------------------- %

if ~exist('isWaitbar', 'var') || isempty(isWaitbar)
    isWaitbar = false;
end

[~, ~, f] = size(mX);

k = sConfig.sBlockMatching.maxNeighborsFrame;
K = sConfig.sBlockMatching.maxGroupSize;

NRefPatches =   size(mRefPatchInds, 1);
mGroupIndices = zeros(NRefPatches, K, 3);
vNumNeighbors = zeros(NRefPatches, 1);

if isWaitbar
    wb = waitbar(0, 'Performing Block-Matching');
end
for iRef = 1:NRefPatches
    %% Find nearest patches per frame
    startFrame = max(refFrame - sConfig.sBlockMatching.searchWindowT, 1);
    endFrame =   min(refFrame + sConfig.sBlockMatching.searchWindowT, f);
    mSearchPatchInds =  zeros((endFrame - startFrame + 1)*k, 3); % indices of most similar patches per frame
    vSearchPatchDists = zeros((endFrame - startFrame + 1)*k, 1); % distances of most similar patches per frame
    
    vRefPatchInds = [mRefPatchInds(iRef, :), refFrame]; % include frame
    ind = 0;
      
    % Non-predictive (exhaustive) block matching for first frame:
    [mFirstInds, vFirstDists] = FindBlocks(mX, vRefPatchInds, vRefPatchInds, refFrame, sConfig, false);
    mSearchPatchInds(ind*k + (1:k), :) = mFirstInds;
    vSearchPatchDists(ind*k + (1:k)) =   vFirstDists;
 
    % Forward predictive block matching:
    mCurPatchInds = mFirstInds;
    for iFrame = refFrame+1:endFrame
        ind = ind + 1;
        [mCurPatchInds, vCurPatchDists] = FindBlocks(mX, vRefPatchInds, mCurPatchInds, iFrame, sConfig, true);
        mSearchPatchInds(ind*k + (1:k), :) = mCurPatchInds;
        vSearchPatchDists(ind*k + (1:k)) =   vCurPatchDists;
    end
    
    % Backward predictive block matching:
    mCurPatchInds = mFirstInds;
    for iFrame = refFrame-1:-1:startFrame
        ind = ind + 1;
        [mCurPatchInds, vCurPatchDists] = FindBlocks(mX, vRefPatchInds, mCurPatchInds, iFrame, sConfig, true);
        mSearchPatchInds(ind*k + (1:k), :) = mCurPatchInds;
        vSearchPatchDists(ind*k + (1:k)) =   vCurPatchDists;
    end
    
    %% Find nearest patches from entire patch array:
    [vNearestDists, vNearestInds] = mink(vSearchPatchDists, K);
    mGroupIndices(iRef, 1:min(K,(endFrame - startFrame + 1)*k), :) = mSearchPatchInds(vNearestInds, :);
    vNumNeighbors(iRef) = sum(vNearestDists <= sConfig.sBlockMatching.distTh);
    
    if isWaitbar && (mod(iRef - 1, 20) == 0)
        waitbar(iRef/NRefPatches, wb);
    end
end
if isWaitbar
    close(wb);
end

end

%% ==========================================================================================================
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
K = sConfig.sBlockMatching.maxNeighborsFrame;
p = sConfig.sBlockMatching.patchSize;
if isPred
    m = sConfig.sBlockMatching.searchWindowP;
    s = sConfig.sBlockMatching.searchStrideP;
else
    m = sConfig.sBlockMatching.searchWindowNP;
    s = sConfig.sBlockMatching.searchStrideNP;
end

% extract reference patch:
refRow =   vRefPatchInds(1);
refCol =   vRefPatchInds(2);
refFrame = vRefPatchInds(3);
refIdx = sub2ind([h, w], refRow, refCol);

% calculate search windows:
vRelativeInds = [flip(0:-s:-m), s:s:m]; % [1, n]
[mRelativeCols, mRelativeRows] = meshgrid(vRelativeInds, vRelativeInds); % [n, n]
mPatchStartRows = reshape(mSearchInds(:, 1), [1, 1, k]) + repmat(mRelativeRows, [1, 1, k]); % [n, n, k]
mPatchStartCols = reshape(mSearchInds(:, 2), [1, 1, k]) + repmat(mRelativeCols, [1, 1, k]); % [n, n, k]

% handle out-of-boundary cases of the search window by masking patches that are out of frame:
mMaskRow = (mPatchStartRows >= 1) & (mPatchStartRows <= h - p + 1); % [n, n, k]
mMaskCol = (mPatchStartCols >= 1) & (mPatchStartCols <= w - p + 1); % [n, n, k]
mMask = mMaskRow & mMaskCol; % [n, n, k]
vPatchStartRows = mPatchStartRows(mMask(:));
vPatchStartCols = mPatchStartCols(mMask(:));
vPatchStartInds = sub2ind([h, w], vPatchStartRows, vPatchStartCols);
vPatchStartInds = unique(vPatchStartInds); % [N, 1] unique because patches from different windows may repeat

% relative patch indices in frame from top-left corner:
mSinglePatchInds = (0:p-1)' + h*(0:p-1); % [p, p]
mSinglePatchInds = reshape(mSinglePatchInds, [1, size(mSinglePatchInds)]); % [1, p, p]

% find dists:
mRefPatch = mX(refIdx + mSinglePatchInds + (refFrame-1)*h*w); % [1, p, p]
mPatches = mX(vPatchStartInds + repmat(mSinglePatchInds, [length(vPatchStartInds),1,1]) + (iFrame-1)*h*w);
mDiffPatches = mPatches - mRefPatch; % [N, p, p]
vDists = PatchesNorm(mDiffPatches, sConfig); % [N, 1]

% get nearest patches:
[vNearestDists, vNearestInds] = mink(vDists, K);
[vRows, vCols] = ind2sub([h, w], vPatchStartInds(vNearestInds));
mNearestInds = [vRows, vCols, repmat(iFrame, [K, 1])];

end

%% ==========================================================================================================
function d = PatchesNorm(mDiffPatches, sConfig)
% Calculates norm of all patches.
% Assuming input is of shape [k, p, p]:
%   k - number of patches.
%   p - size of the patches.

switch sConfig.sBlockMatching.metric
    case 'l1'
        d = mean(abs(mDiffPatches), [2, 3]);
    case 'l2'
        d = sqrt(mean(abs(mDiffPatches).^2, [2, 3]));
    otherwise
        error('Metric not defined');
end

end
