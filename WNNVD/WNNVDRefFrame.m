function [mY, mGroupedPixels, vNPatchesPerFrame] = ...
    WNNVDRefFrame(mX, mPreDenoised, mGroupedPixels, refFrame, sConfig)
% --------------------------------------------------------------------------------------------------------- %
% Weighted Nuclear Norm Video Denoiser based on a single reference frame.
%
% Input:
%   mX -             3D array of noised video frames. [h, w, f]
%   mPreDenoised -   3D array of pre-denoised video frames. [h, w, f]
%   mGroupedPixels - 3D boolean array stating which pixles in video have been processed. [h, w, f]
%   refFrame -       Reference frame number for key-patches.
%   sConfig -        Struct containing all parameters for algorithm.
%
% Output:
%   mY -                3D array of denoised video frames. [h, w, f]
%   mGroupedPixels -    Updated 3D boolean array stating which pixles in video have been processed. [h, w, f]
%   vNPatchesPerFrame - Number of chosen patches per frame. [1, f]
% --------------------------------------------------------------------------------------------------------- %

[h, w, f] = size(mX);

%% Get reference patch indices:
mRefPatchInds = GetRefPatchInds(h, w, mGroupedPixels(:,:,refFrame), sConfig);

%% Denoise per reference patch:
mY = mX;
mCountIters = zeros(size(mY)); % counts number of iterations each pixel has been grouped

for iter = 1:sConfig.sWNNM.nIter
    
    mY = mY + sConfig.sWNNM.delta*(mX - mY);
    
    % Block matching:
    % We perfrom BM based on the pre-denoised video, but extract the patches from the noised version.
    if (mod(iter - 1, sConfig.sWNNM.BMIter) == 0)
        if (iter == 1)
            mBMInput = mPreDenoised;
        else
            mBMInput = mY;
        end
        [mGroupIndices, vNumNeighbors] = BlockMatching(mBMInput, mRefPatchInds, refFrame, sConfig, false);
        vNPatchesPerFrame = histcounts(mGroupIndices(:,:,3), 1:f+1) / size(mGroupIndices, 1);
        
        % next iterations will have less noise - so use less patches in group:
        sConfig.sBlockMatching.maxGroupSize = max(sConfig.sBlockMatching.maxGroupSize - 10, 40);
    end
    
    % WNNM per group and image aggregation:
    [mY, mGroupedPixelsCur] = DenoisePatches(mY, mX, mGroupIndices, vNumNeighbors, sConfig);
    
    mCountIters = mCountIters + mGroupedPixelsCur;
end

mGroupedPixels = (mGroupedPixels | (mCountIters >= sConfig.sWNNM.minIterForSkip));

end
