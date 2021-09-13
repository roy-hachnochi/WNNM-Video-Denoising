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
    [vNearestDists, vNearestInds] = mink(vSearchPatchDists, K-1);
    mGroupIndices(iRef, 1:min(K,(endFrame - startFrame + 1)*k+1), :) = [vRefPatchInds ;mSearchPatchInds(vNearestInds, :)];
    vNumNeighbors(iRef) = sum(vNearestDists <= sConfig.sBlockMatching.distTh);
    
    if isWaitbar && (mod(iRef - 1, 20) == 0)
        waitbar(iRef/NRefPatches, wb);
    end
end
if isWaitbar
    close(wb);
end

end
