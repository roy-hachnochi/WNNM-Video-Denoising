function [mY, vNumUngroupedPixels] = WNNVDRefFrame(mX, mPreDenoised, refFrame, vNumUngroupedPixels, sConfig)
% --------------------------------------------------------------------------------------------------------- %
% Weighted Nuclear Norm Video Denoiser based on a single reference frame.
%
% Input:
%   mX -                  3D array of noised video frames. [h, w, f]
%   mPreDenoised -        3D array of pre-denoised video frames. [h, w, f]
%   refFrame -            Reference frame number for key-patches.
%   vNumUngroupedPixels - Number of unprocessed pixels per frame. [1, f]
%   sConfig -             Struct containing all parameters for algorithm.
%
% Output:
%   mY -                  3D array of denoised video frames. [h, w, f]
%   vNumUngroupedPixels - Updated number of unprocessed pixels per frame. [1, f]
% --------------------------------------------------------------------------------------------------------- %

% TODO: fix all sConfig names

[h, w, f] = size(mX);

%% Get reference patch indices:
mRefPatchInds = GetRefPatchInds(h, w, sConfig);

%% Denoise per reference patch:
mY = mX;
for iter = 1:sConfig.nIter
    mY = mY + sConfig.delta*(mX - mY);
    
    % Block matching:
    % We perfrom the block matching based on the pre-denoised video, but extract the patches themselves from
    % the noised version.
    if (mod(iter - 1,sConfig.Innerloop) == 0)
        sConfig.patnum = sConfig.patnum - 10; % TODO: do we need this? from original WNNM code
        [mGroupIndices, vNumNeighbors] = BlockMatching(mPreDenoised, mRefPatchInds, refFrame, sConfig);
    end
    
    % WNNM per group and image aggregation:
    [mY, vNumUngroupedPixels] = DenoisePatches(mY, mGroupIndices, vNumNeighbors);
end

end
