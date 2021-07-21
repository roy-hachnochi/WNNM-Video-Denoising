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

[h, w, f] = size(mX);

NRefPatches = size(mRefPatchInds, 1);
mGroupIndices = zeros(NRefPatches, sConfig.maxGroupSize, 3);
vNumNeighbors = zeros(NRefPatches, 1);

for iRef = 1:NRefPatches
    %% Find nearest patches per frame
    mSearchPatchInds = zeros(f*sConfig.maxNeighborsFrame, 3); % indices of most similar patches per frame
    vSearchPatchDists = zeros(f*sConfig.maxNeighborsFrame, 1); % distances of most similar patches per frame
    vRefPatchInds = [mRefPatchInds(iRef, :); refFrame];
    ind = 0;
    
    % Non-predictive (exhaustive) block matching for first frame:
    [mCurPatchInds, vCurPatchDists] = BlockMatchingNonPred(mX, vRefPatchInds, sConfig);
    mSearchPatchInds(ind*sConfig.maxNeighborsFrame + (1:sConfig.maxNeighborsFrame), :) = mCurPatchInds;
    vSearchPatchDists(ind*sConfig.maxNeighborsFrame + (1:sConfig.maxNeighborsFrame)) = vCurPatchDists;
    
    % Forward predictive bloack matching:
    for iFrame = refFrame+1:f
        ind = ind + 1;
        [mCurPatchInds, vCurPatchDists] = BlockMatchingPred(mX, vRefPatchInds, mCurPatchInds, iFrame, sConfig);
        mSearchPatchInds(ind*sConfig.maxNeighborsFrame + (1:sConfig.maxNeighborsFrame), :) = mCurPatchInds;
        vSearchPatchDists(ind*sConfig.maxNeighborsFrame + (1:sConfig.maxNeighborsFrame)) = vCurPatchDists;
    end
    
    % Backward predictive bloack matching:
    for iFrame = refFrame-1:-1:1
        ind = ind + 1;
        [mCurPatchInds, vCurPatchDists] = BlockMatchingPred(mX, vRefPatchInds, mCurPatchInds, iFrame, sConfig);
        mSearchPatchInds(ind*sConfig.maxNeighborsFrame + (1:sConfig.maxNeighborsFrame), :) = mCurPatchInds;
        vSearchPatchDists(ind*sConfig.maxNeighborsFrame + (1:sConfig.maxNeighborsFrame)) = vCurPatchDists;
    end
    
    %% Find Nearest patches from entire patch array:
    % TODO...
    
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
%   mNearestInds -  2D array containing upper-left indices of nearest patches. [K, 3]
%   vNearestDists - Array distances of nearest patches from reference patch. [K, 1]
% --------------------------------------------------------------------------------------------------------- %

end

%% ==========================================================================================================
function [mNearestInds, vNearestDists] = BlockMatchingPred(mX, vRefPatchInds, mPrevNearestInds, iFrame, sConfig)
% --------------------------------------------------------------------------------------------------------- %
% Performs predictive block matching in a single frame. Finds nearest patches to reference patch.
%
% Input:
%   mX -               3D array of video frames. [h, w, f]
%   vRefPatchInds -    Array containing upper-left indices of reference patch. [3, 1]
%   mPrevNearestInds - 2D array containing upper-left indices of previous frame's nearest patches. [K, 3]
%   iFrame -           Current frame for search.
%   sConfig -          Struct containing all parameters for algorithm.
%
% Output:
%   mNearestInds -  2D array containing upper-left indices of nearest patches. [K, 3]
%   vNearestDists - Array distances of nearest patches from reference patch. [K, 1]
% --------------------------------------------------------------------------------------------------------- %

end


