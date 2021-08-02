function [mY, mGroupedPixels] = WNNVDRefFrame(mX, mPreDenoised, mGroupedPixels, refFrame, sConfig)
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
%   mY -             3D array of denoised video frames. [h, w, f]
%   mGroupedPixels - Updated 3D boolean array stating which pixles in video have been processed. [h, w, f]
% --------------------------------------------------------------------------------------------------------- %

% TODO: add PSNR (and other metrics) printing for each iteration?
% TODO: save log with intermediate results for research (PSNR per it, amount of matched patches from each
% frame, number of times we enter this function, ...)?
% TODO: erase all unnecassary profiler lines

[h, w, ~] = size(mX);

%% Get reference patch indices:
% refStamp = ProfilerStartRecord(sConfig); % Profiler
mRefPatchInds = GetRefPatchInds(h, w, mGroupedPixels(:,:,refFrame), sConfig);
% ProfilerEndRecord(refStamp, "Get-Ref-Patch-Inds", sConfig); % Profiler

%% Denoise per reference patch:
mY = mX;
mCountIters = zeros(size(mY)); % counts number of iterations each pixel has been grouped

% iterStamp = ProfilerStartRecord(sConfig); % Profiler
for iter = 1:sConfig.sWNNM.nIter
    
    mY = mY + sConfig.sWNNM.delta*(mX - mY); % TODO: in the paper they do this differently ; URI : are you sure?
    
    % Block matching:
    % We perfrom the block matching based on the pre-denoised video, but extract the patches themselves from
    % the noised version.
    if (mod(iter - 1, sConfig.sWNNM.BMIter) == 0)
        if (iter == 1)
            mBMInput = mPreDenoised;
        else
            mBMInput = mY;
        end
%         bmStamp = ProfilerStartRecord(sConfig); % Profiler
        [mGroupIndices, vNumNeighbors] = BlockMatching(mBMInput, mRefPatchInds, refFrame, sConfig, false);
%         ProfilerEndRecord(bmStamp, "Block-Matching", iter, sConfig); % Profiler
        
        % next iterations will have less noise - so use less patches in group:
        sConfig.sBlockMatching.maxGroupSize = sConfig.sBlockMatching.maxGroupSize - 10; % TODO: do we need this? from original WNNM code
    end
    
    % WNNM per group and image aggregation:
%     deStamp = ProfilerStartRecord(sConfig); % Profiler
    [mY, mGroupedPixelsCur] = DenoisePatches(mY, mX, mGroupIndices, vNumNeighbors, sConfig);
%     ProfilerEndRecord(deStamp, "Denoise-Patches", iter, sConfig); % Profiler
    
    mCountIters = mCountIters + mGroupedPixelsCur;
end
% ProfilerEndRecord(iterStamp, "Per Frame Denoise", sConfig); % Profiler #TODO : not working if tic-toc called in the middle

mGroupedPixels = (mGroupedPixels | (mCountIters >= sConfig.sWNNM.minIterForSkip));

end
