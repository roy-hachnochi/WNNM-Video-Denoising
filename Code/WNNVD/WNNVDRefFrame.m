function [mY, mGroupedPixels] = WNNVDRefFrame(mX, mPreDenoised, refFrame, sConfig)
% --------------------------------------------------------------------------------------------------------- %
% Weighted Nuclear Norm Video Denoiser based on a single reference frame.
%
% Input:
%   mX -                  3D array of noised video frames. [h, w, f]
%   mPreDenoised -        3D array of pre-denoised video frames. [h, w, f]
%   refFrame -            Reference frame number for key-patches.
%   sConfig -             Struct containing all parameters for algorithm.
%
% Output:
%   mY -             3D array of denoised video frames. [h, w, f]
%   mGroupedPixels - 3D boolean array stating which pixles in video have been processed. [h, w, f]
% --------------------------------------------------------------------------------------------------------- %

% TODO: add waitbar (here or inside functions)
% TODO: add PSNR (and other metrics) printing for each iteration?
% TODO: save log with intermediate results for research (PSNR per it, amount of matched patches from each
% frame, ...)?

[h, w, ~] = size(mX);

%% Get reference patch indices:
mRefPatchInds = GetRefPatchInds(h, w, sConfig);

%% Denoise per reference patch:
mY = mX;
for iter = 1:sConfig.sWNNM.nIter
    mY = mY + sConfig.sWNNM.delta*(mX - mY); % TODO: in the paper they do this differently
    
    % Block matching:
    % We perfrom the block matching based on the pre-denoised video, but extract the patches themselves from
    % the noised version.
    if (mod(iter - 1, sConfig.sWNNM.BMIter) == 0)
        sConfig.sBlockMatching.maxGroupSize = sConfig.sBlockMatching.maxGroupSize - 10; % TODO: do we need this? from original WNNM code
        if (iter == 1)
            mBMInput = mPreDenoised;
        else
            mBMInput = mY;
        end
        [mGroupIndices, vNumNeighbors] = BlockMatching(mBMInput, mRefPatchInds, refFrame, sConfig);
    end
    
    % WNNM per group and image aggregation:
    [mY, mGroupedPixels] = DenoisePatches(mY, mGroupIndices, vNumNeighbors, sConfig);
end

end
