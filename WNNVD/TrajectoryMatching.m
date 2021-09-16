function [mGroupIndices, mNumNeighbors] = TrajectoryMatching(mX, mRefPatchInds, refFrame, sConfig, isWaitbar)
% --------------------------------------------------------------------------------------------------------- %
% Performs trajectory matching per reference trajectory - find nearest
% (most similar) trajectories to each reference trajectory in the same frame span.
%
% Input:
%   mX -            3D array of video frames. [h, w, f]
%   mRefPatchInds - 2D array containing upper-left indices of reference patches. [N, 2]
%   refFrame -      Reference frame number for key-patches.
%   sConfig -       Struct containing all parameters for algorithm.
%   isWaitbar -     (optional) Display waitbar (default: false).
%
% Output:
%   mGroupIndices - 4D array containing upper-left indices of trajectories in group per reference trajectories. [N, K, M, 3]
%   mNumNeighbors - Matrix containing number of effective neighbors per reference trajectories(1) and their length(2). [N, 2]
% --------------------------------------------------------------------------------------------------------- %

if ~exist('isWaitbar', 'var') || isempty(isWaitbar)
    isWaitbar = false;
end

K = sConfig.sBlockMatching.maxGroupSize;
M = 2*sConfig.sBlockMatching.searchWindowT + 1;

NRefPatches =   size(mRefPatchInds, 1);
mGroupIndices = zeros(NRefPatches, K, M, 3);
mNumNeighbors = zeros(NRefPatches, 2);

if isWaitbar
    wb = waitbar(0, 'Performing Block-Matching');
end

for iRef = 1:NRefPatches
    vRefPatchInds = [mRefPatchInds(iRef, :), refFrame]; % include frame
  
    % Create trajectory using predictive matching
    [mRefTrajInd, trajLengthRef] = CollectTrajectory(mX, vRefPatchInds, sConfig);

    mRefBuffer = zeros(K,trajLengthRef,3);
    vDists = zeros(K,1);
    k = 0;
    % Search for similar trajectories which centred on the referece frame
    [mInds, ~] = FindBlocks(mX, vRefPatchInds, vRefPatchInds, refFrame, sConfig, false);
    for iPatch = 1:size(mInds,1)
        vCurrPatch = mInds(iPatch,:);
        [mTrajInd, trajLength] = CollectTrajectory(mX, vCurrPatch, sConfig);
        if trajLength < trajLengthRef % if the related trajectory smaller than the reference - its not relevant
            continue
        end
        vDiffTraj = ParseTraj(mX, mTrajInd(1:trajLengthRef,:), sConfig) - ParseTraj(mX, mRefTrajInd, sConfig);
        vDists(iPatch) = TrajNorm(vDiffTraj(:), sConfig);
        mRefBuffer(iPatch, :, :) = mTrajInd(1:trajLengthRef,:);
        k = k + 1;
    end

    %% Find nearest trajectories from entire patch array:
    [vNearestDists, vNearestInds] = mink(vDists(1:k), K);
    mGroupIndices(iRef, 1:length(vNearestInds) , 1:trajLengthRef, :) = mRefBuffer(vNearestInds, :, :);
    mNumNeighbors(iRef,1) = sum(vNearestDists <= sConfig.sBlockMatching.distTh);
    mNumNeighbors(iRef,2) = trajLengthRef;
    
    if isWaitbar && (mod(iRef - 1, 20) == 0)
        waitbar(iRef/NRefPatches, wb);
    end
end
if isWaitbar
    close(wb);
end

end