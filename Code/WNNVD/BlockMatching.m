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
    mSearchPatchInds =  zeros(f*k, 3); % indices of most similar patches per frame
    vSearchPatchDists = zeros(f*k, 1); % distances of most similar patches per frame
    
    vRefPatchInds = [mRefPatchInds(iRef, :), refFrame]; % include frame
    ind = 0;
    
%     if iRef == 1 || iRef == NRefPatches % Profiler
%         npStamp = ProfilerStartRecord(sConfig);
%     end   
    % Non-predictive (exhaustive) block matching for first frame:
    [mFirstInds, vFirstDists] = BlockMatchingNonPred(mX, vRefPatchInds, sConfig);
    mSearchPatchInds(ind*k + (1:k), :) = mFirstInds;
    vSearchPatchDists(ind*k + (1:k)) =   vFirstDists;
%     if iRef == 1 || iRef == NRefPatches % Profiler
%         ProfilerEndRecord(npStamp, "Non-Predictive-Search", iRef, sConfig);
%     end

%     if iRef == 1 || iRef == NRefPatches % Profiler
%         pStamp = ProfilerStartRecord(sConfig);
%     end   
    % Forward predictive block matching:
    mCurPatchInds = mFirstInds;
    for iFrame = refFrame+1:f
        ind = ind + 1;
        [mCurPatchInds, vCurPatchDists] = BlockMatchingPred(mX, vRefPatchInds, mCurPatchInds, iFrame, sConfig);
        mSearchPatchInds(ind*k + (1:k), :) = mCurPatchInds;
        vSearchPatchDists(ind*k + (1:k)) =   vCurPatchDists;
    end
    
    % Backward predictive block matching:
    mCurPatchInds = mFirstInds;
    for iFrame = refFrame-1:-1:1
        ind = ind + 1;
        [mCurPatchInds, vCurPatchDists] = BlockMatchingPred(mX, vRefPatchInds, mCurPatchInds, iFrame, sConfig);
        mSearchPatchInds(ind*k + (1:k), :) = mCurPatchInds;
        vSearchPatchDists(ind*k + (1:k)) =   vCurPatchDists;
    end
%     if iRef == 1 || iRef == NRefPatches % Profiler
%         ProfilerEndRecord(pStamp, "Predictive-Search", iRef, sConfig);
%     end    
    %% Find nearest patches from entire patch array:
    [vNearestDists, vNearestInds] = mink(vSearchPatchDists, K);
    mGroupIndices(iRef, 1:min(K,f*k), :) = mSearchPatchInds(vNearestInds, :);
    vNumNeighbors(iRef) =         sum(vNearestDists <= sConfig.sBlockMatching.distTh);
    
    if isWaitbar && (mod(iRef - 1, 20) == 0)
        waitbar(iRef/NRefPatches, wb);
    end
end
if isWaitbar
    close(wb);
end

end

%% ==========================================================================================================
function [mNearestInds, vNearestDists] = BlockMatchingNonPred(mX, vRefPatchInds, sConfig)
% --------------------------------------------------------------------------------------------------------- %
% Performs non-predictive (exhaustive) block matching in a single frame. Finds nearest patches to reference
% patch.
%
% Input:
%   mX -            3D array of video frames. [h, w, f]
%   vRefPatchInds - Array containing upper-left indices of reference patch. [3, 1]
%   sConfig -       Struct containing all parameters for algorithm.
%
% Output:
%   mNearestInds -  2D array containing upper-left indices of nearest patches. [k, 3]
%   vNearestDists - Array distances of nearest patches from reference patch. [k, 1]
% --------------------------------------------------------------------------------------------------------- %

[h, w, ~] = size(mX);

k = sConfig.sBlockMatching.maxNeighborsFrame;
m = sConfig.sBlockMatching.searchWindowNP;
s = sConfig.sBlockMatching.searchStrideNP;
p = sConfig.sBlockMatching.patchSize;

% extract reference inds:
refRow =   vRefPatchInds(1);
refCol =   vRefPatchInds(2);
refFrame = vRefPatchInds(3);
refIdx = sub2ind([h, w], refRow, refCol);

% calculate search window:
vStrideR = [flip(0:-s:-m), s:s:m]; % [1, n]
vStrideC = h*[flip(0:-s:-m), s:s:m]; % [1, n]
mWinOffsets = vStrideR' + vStrideC; % [n, n] index offset for each of the patches in the search window
mPatchStartInds = refIdx + mWinOffsets; % [n, n]

% handle out-of-boundary cases of the search window by masking patches that are out of frame:
[mPatchStartRows, mPatchStartCols] = ind2sub([h, w], mPatchStartInds); % [n, n]
vMaskRow = (mPatchStartRows >= 1) & (mPatchStartRows <= h - p + 1); % [n, n]
vMaskCol = (mPatchStartCols >= 1) & (mPatchStartCols <= w - p + 1); % [n, n]
mMask = vMaskRow & vMaskCol; % [n, n]
vPatchStartInds = mPatchStartInds(mMask(:)); % [N, 1]

% relative patch indices in frame from top-left corner:
mSinglePatchInds = (0:p-1)' + h*(0:p-1); % [p, p]
mSinglePatchInds = reshape(mSinglePatchInds, [1, size(mSinglePatchInds)]); % [1, p, p]

% find dists:
mRefPatch = mX(refIdx + mSinglePatchInds + (refFrame-1)*h*w); % [1, p, p]
mPatches = mX(vPatchStartInds + repmat(mSinglePatchInds, [length(vPatchStartInds),1,1]) + (refFrame-1)*h*w);
mDiffPatches = mPatches - mRefPatch; % [N, p, p]
vDists = PatchesNorm(mDiffPatches, sConfig); % [N, 1]

% get nearest patches:
[vNearestDists, vNearestInds] = mink(vDists, k);
[vRows, vCols] = ind2sub([h, w], vPatchStartInds(vNearestInds));
mNearestInds = [vRows, vCols, repmat(refFrame, [k, 1])];

end

%% ==========================================================================================================
function [mNearestInds, vNearestDists] = BlockMatchingPred(mX, vRefPatchInds, mPrevNearestInds, iFrame, sConfig)
% --------------------------------------------------------------------------------------------------------- %
% Performs predictive block matching in a single frame. Finds nearest patches to reference patch.
%
% Input:
%   mX -               3D array of video frames. [h, w, f]
%   vRefPatchInds -    Array containing upper-left indices of reference patch. [3, 1]
%   mPrevNearestInds - 2D array containing upper-left indices of previous frame's nearest patches. [k, 3]
%   iFrame -           Current frame for search.
%   sConfig -          Struct containing all parameters for algorithm.
%
% Output:
%   mNearestInds -  2D array containing upper-left indices of nearest patches. [k, 3]
%   vNearestDists - Array distances of nearest patches from reference patch. [k, 1]
% --------------------------------------------------------------------------------------------------------- %

[h, w, ~] = size(mX);

k = sConfig.sBlockMatching.maxNeighborsFrame;
m = sConfig.sBlockMatching.searchWindowP;
s = sConfig.sBlockMatching.searchStrideP;
p = sConfig.sBlockMatching.patchSize;

% extract reference patch:
refRow =   vRefPatchInds(1);
refCol =   vRefPatchInds(2);
refFrame = vRefPatchInds(3);
refIdx = sub2ind([h, w], refRow, refCol);

% calculate search windows:
vStrideR = [flip(0:-s:-m), s:s:m]; % [1, n]
vStrideC = h*[flip(0:-s:-m), s:s:m]; % [1, n]
mWinOffsets = vStrideR' + vStrideC; % [n, n] index offset for each patch in the search window
mWinOffsets = repmat(mWinOffsets, [1, 1, size(mPrevNearestInds, 1)]); % we add this to each prev nearest ind

vPrevNearestInds = sub2ind([h, w], mPrevNearestInds(:, 1), mPrevNearestInds(:, 2)); % [k, 1]
vPrevNearestInds = reshape(vPrevNearestInds, [1, 1, size(mPrevNearestInds, 1)]); % [1, 1, k]
mPatchStartInds = vPrevNearestInds + mWinOffsets; % [n, n, k]

% handle out-of-boundary cases of the search window by masking patches that are out of frame:
[mPatchStartRows, mPatchStartCols] = ind2sub([h, w], mPatchStartInds); % [n, n, k]
vMaskRow = (mPatchStartRows >= 1) & (mPatchStartRows <= h - p + 1); % [n, n, k]
vMaskCol = (mPatchStartCols >= 1) & (mPatchStartCols <= w - p + 1); % [n, n, k]
mMask = vMaskRow & vMaskCol; % [n, n, k]
vPatchStartInds = unique(mPatchStartInds(mMask(:))); % [N, 1] patches from different windows may be repeat

% relative patch indices in frame from top-left corner:
mSinglePatchInds = (0:p-1)' + h*(0:p-1); % [p, p]
mSinglePatchInds = reshape(mSinglePatchInds, [1, size(mSinglePatchInds)]); % [1, p, p]

% find dists:
mRefPatch = mX(refIdx + mSinglePatchInds + (refFrame-1)*h*w); % [1, p, p]
mPatches = mX(vPatchStartInds + repmat(mSinglePatchInds, [length(vPatchStartInds),1,1]) + (iFrame-1)*h*w);
mDiffPatches = mPatches - mRefPatch; % [N, p, p]
vDists = PatchesNorm(mDiffPatches, sConfig); % [N, 1]

% get nearest patches:
[vNearestDists, vNearestInds] = mink(vDists, k);
[vRows, vCols] = ind2sub([h, w], vPatchStartInds(vNearestInds));
mNearestInds = [vRows, vCols, repmat(iFrame, [k, 1])];

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
