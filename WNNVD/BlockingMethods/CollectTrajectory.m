function [mTrajPatchInds, trajLength] = CollectTrajectory(mX, vRefPatchInds, sConfig)
% --------------------------------------------------------------------------------------------------------- %
% Collect trajectory indices for some reference patch
%
% Input:
%   mX -               3D array of video frames. [h, w, f]
%   vRefPatchInds -    Array containing upper-left indices of reference patch. [1, 3]
%   sConfig -          Struct containing all parameters for algorithm.
%   isPred -           Take config parameters for predictive BM (true/false).
%
% Output:
%   mTrajPatchInds -  2D array containing upper-left indices of the trajectory patches. [M, 3]
%   trajLength -      The effective length, frame-wise, of the trajectory (less or equal to M)   
% --------------------------------------------------------------------------------------------------------- %
refFrame = vRefPatchInds(3);
[~, ~, f] = size(mX);

startFrame = max(refFrame - sConfig.sBlockMatching.searchWindowT, 1);
endFrame =   min(refFrame + sConfig.sBlockMatching.searchWindowT, f);
mTrajPatchInds =  zeros((endFrame - startFrame), 3); % indices of most similar patches per frame

    
% Save reference patch
mTrajPatchInds(1,:) = vRefPatchInds;
trajLength = 1;

% Forward predictive block matching:
mCurPatchInds = vRefPatchInds;
for iFrame = refFrame+1:endFrame
    [mCurPatchInds, ~] = FindBlocks(mX, vRefPatchInds, mCurPatchInds, iFrame, sConfig, true);
    if isempty(mCurPatchInds)
        break
    end    
    mTrajPatchInds(trajLength + 1, :) = mCurPatchInds;
    trajLength = trajLength + 1;
end

% Backward predictive block matching:
mCurPatchInds = vRefPatchInds;
nCircShift = sConfig.sBlockMatching.searchWindowT;
for iFrame = refFrame-1:-1:startFrame
    [mCurPatchInds, ~] = FindBlocks(mX, vRefPatchInds, mCurPatchInds, iFrame, sConfig, true);
    if isempty(mCurPatchInds)
        nCircShift = iFrame - refFrame;
        break
    end
    mTrajPatchInds(trajLength + 1, :) = mCurPatchInds;
    trajLength = trajLength + 1;  
end

% Shift the indices to match the "natural" order of the frames
mTrajPatchInds(1:trajLength,:) = circshift(mTrajPatchInds(1:trajLength,:), nCircShift, 1);
mTrajPatchInds(1:nCircShift,:) = flip(mTrajPatchInds(1:nCircShift,:), 1); % fix the order of the "past" frames

end
