function [mGroupIndices, vNumNeighbors] = BlockMatching(mX, mRefPatchInds, refFrame, sConfig)
% --------------------------------------------------------------------------------------------------------- %
% Performs block matching per reference patch - find nearest (most similar) patches to each reference patches
% in entire video.
%
% Input:
%   mX -            3D array of video frames. [h, w, f]
%   mRefPatchInds - 2D array containing upper-left indices of reference patches. [N, 2]
%   refFrame -      Reference frame number for key-patches.
%   sConfig -       Struct containing all parameters for algorithm.
%
% Output:
%   mGroupIndices - 3D array containing upper-left indices of patches in group per reference patch. [N, K, 3]
%   vNumNeighbors - Array containing number of effective neighbors per reference patch. [N, 1]
% --------------------------------------------------------------------------------------------------------- %

[~, ~, f] = size(mX);

k = sConfig.sBlockMatching.maxNeighborsFrame;
K = sConfig.sBlockMatching.maxGroupSize;

NRefPatches =   size(mRefPatchInds, 1);
mGroupIndices = zeros(NRefPatches, K, 3);
vNumNeighbors = zeros(NRefPatches, 1);

for iRef = 1:NRefPatches
    %% Find nearest patches per frame
    mSearchPatchInds =  zeros(f*k, 3); % indices of most similar patches per frame
    vSearchPatchDists = zeros(f*k, 1); % distances of most similar patches per frame
    
    vRefPatchInds = [mRefPatchInds(iRef, :), refFrame]; % include frame
    ind = 0;
    
    % Non-predictive (exhaustive) block matching for first frame:
    [mFirstInds, vFirstDists] = BlockMatchingNonPred(mX, vRefPatchInds, sConfig);
    mSearchPatchInds(ind*k + (1:k), :) = mFirstInds;
    vSearchPatchDists(ind*k + (1:k)) =   vFirstDists;
    
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
    
    %% Find nearest patches from entire patch array:
    [vNearestDists, vNearestInds] = mink(vSearchPatchDists, K);
    mGroupIndices(iRef, 1:K, :) = mSearchPatchInds(vNearestInds, :);
    vNumNeighbors(iRef) =         sum(vNearestDists <= sConfig.sBlockMatching.distTh);
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

% extract reference patch:
refRow =   vRefPatchInds(1);
refCol =   vRefPatchInds(2);
refFrame = vRefPatchInds(3);

mRefPatch = mX(refRow + (0:p-1), refCol + (0:p-1), refFrame);

% calculate search window:
vSearchRows = unique(max(1, min(refRow + [flip(0:-s:-m), s:s:m], h - p + 1)));
vSearchCols = unique(max(1, min(refCol + [flip(0:-s:-m), s:s:m], w - p + 1)));
[mSearchRows, mSearchCols] = meshgrid(vSearchRows, vSearchCols);
mSearchInds = zeros(length(vSearchRows)*length(vSearchCols), 2);
mSearchInds(:, 1) = mSearchRows(:);
mSearchInds(:, 2) = mSearchCols(:);

% find dists:
vDists = zeros(size(mSearchInds, 1), 1);
for ind = 1:size(mSearchInds, 1)
    mPatch = mX(mSearchInds(ind, 1) + (0:p-1), mSearchInds(ind, 2) + (0:p-1), refFrame);
    vDists(ind) = PatchDist(mRefPatch, mPatch, sConfig);
end

% get nearest patches:
[vNearestDists, vNearestInds] = mink(vDists, k);
mNearestInds = [mSearchInds(vNearestInds, :), repmat(refFrame, [k, 1])];

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

mRefPatch = mX(refRow + (0:p-1), refCol + (0:p-1), refFrame);

% calculate search windows:
mSearchInds = [];
for windNum = 1:size(mPrevNearestInds, 1)
    vSearchRows = unique(max(1, min(mPrevNearestInds(1) + [flip(0:-s:-m), s:s:m], h - p + 1)));
    vSearchCols = unique(max(1, min(mPrevNearestInds(2) + [flip(0:-s:-m), s:s:m], w - p + 1)));
    [mSearchRows, mSearchCols] = meshgrid(vSearchRows, vSearchCols);
    mCurSearchInds = zeros(length(vSearchRows)*length(vSearchCols), 2);
    mCurSearchInds(:, 1) = mSearchRows(:);
    mCurSearchInds(:, 2) = mSearchCols(:);
    mSearchInds = [mSearchInds; mCurSearchInds]; %#ok
end

% find dists:
vDists = zeros(size(mSearchInds, 1), 1);
for ind = 1:size(mSearchInds, 1)
    mPatch = mX(mSearchInds(ind, 1) + (0:p-1), mSearchInds(ind, 2) + (0:p-1), iFrame);
    vDists(ind) = PatchDist(mRefPatch, mPatch, sConfig);
end

% get nearest patches:
[vNearestDists, vNearestInds] = mink(vDists, k);
mNearestInds = [mSearchInds(vNearestInds, :), repmat(iFrame, [k, 1])];

end

%% ==========================================================================================================
function d = PatchDist(mP1, mP2, sConfig)
% Finds distance between two patches, defined by some metric

switch sConfig.sBlockMatching.metric
    case 'l1'
        d = sum(abs(mP1(:) - mP2(:)));
    case 'l2'
        d = sum(abs(mP1(:) - mP2(:)).^2);
    otherwise
        error('Metric not defined');
end

end
