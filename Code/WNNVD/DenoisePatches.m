function [mY, mGroupedPixels] = DenoisePatches(mX, mNoised, mGroupIndices, vNumNeighbors, sConfig, isWaitbar)
% --------------------------------------------------------------------------------------------------------- %
% Denoise each patch with WNNM and aggregate to form estimated image.
%
% Input:
%   mX -            3D array of noised video frames. [h, w, f]
%   mNoised -       3D array of original noised video frames. [h, w, f]
%   mGroupIndices - 3D array containing upper-left indices of patches in group per reference patch. [N, K, 3]
%   vNumNeighbors - Array containing number of effective neighbors per reference patch. [N, 1]
%   sConfig -       Struct containing all parameters for algorithm.
%   isWaitbar -     (optional) Display waitbar (default: false).
%
% Output:
%   mY -             Denoised image. [h, w, f]
%   mGroupedPixels - 3D boolean array stating which pixles in video have been processed. [h, w, f]
% --------------------------------------------------------------------------------------------------------- %

if ~exist('isWaitbar', 'var') || isempty(isWaitbar)
    isWaitbar = false;
end

p = sConfig.sBlockMatching.patchSize;
noiseSigma = sConfig.sNoise.sigma; % TODO: also take in consideration S&P and Poisson noises

mPreAgg =     zeros(size(mX)); % sum of all (possibly overlapping) denoised patches, for aggregation.
mPixelCount = zeros(size(mX)); % counter for number of times each pixel was part of a group, for aggregation

if isWaitbar
    wb = waitbar(0, 'Denoising Patches');
end
for iGroup = 1:size(mGroupIndices, 1)
    % Extract current patch group:
    mCurGroupIndices = reshape(mGroupIndices(iGroup, 1:vNumNeighbors(iGroup), :), [vNumNeighbors(iGroup),3]);
    [mGroup, noiseSigmaEst] = ExtractGroup(mX, mNoised, mCurGroupIndices, p, noiseSigma);
    
    % Denoise using WNNM:
    mGroupDenoised = WNNM(mGroup, noiseSigmaEst, sConfig);
    
    % Aggregate:
    [mPreAgg, mPixelCount] = Aggregate(mPreAgg, mPixelCount, mGroupDenoised, mCurGroupIndices, p);
    
    if isWaitbar && (mod(iGroup - 1, 20) == 0)
        waitbar(iGroup/size(mGroupIndices, 1), wb);
    end
end
if isWaitbar
    close(wb);
end

mGroupedPixels = (mPixelCount > 0);
mY = mX;
mY(mGroupedPixels) = mPreAgg(mGroupedPixels)./mPixelCount(mGroupedPixels);

end

%% ==========================================================================================================
function [mGroup, noiseSigmaEst] = ExtractGroup(mX, mNoised, mGroupIndices, p, noiseSigma)
% --------------------------------------------------------------------------------------------------------- %
% Extracts group of patches from video.
%
% Input:
%   mX -            3D array of video frames. [h, w, f]
%   mNoised -       3D array of original noised video frames. [h, w, f]
%   mGroupIndices - 2D array containing upper-left indices of patches in group. [K, 3]
%   p -             Patch size (single dimension).
%   noiseSigma -    Original noise STD of video.
%
% Output:
%   mGroup -        2D array containing vecotrized patches in group. [K, p^2]
%   noiseSigmaEst - Estimated noise STD for reference patch.
% --------------------------------------------------------------------------------------------------------- %

K = size(mGroupIndices, 1);
mGroup = zeros(K, p^2);
for iPatch = 1:K
    row =   mGroupIndices(iPatch, 1);
    col =   mGroupIndices(iPatch, 2);
    frame = mGroupIndices(iPatch, 3);
    mGroup(iPatch, :) = reshape(mX(row + (0:(p-1)), col + (0:(p-1)), frame), [1, p^2]);
    
    % estimate noise based on first (reference) patch:
    if (iPatch == 1)
        vNoisedPatch = reshape(mNoised(row + (0:(p-1)), col + (0:(p-1)), frame), [1, p^2]);
        noiseSigmaEst = sqrt(abs(mean((mGroup(1, :) - vNoisedPatch).^2) - noiseSigma^2));
    end
end

end

%% ==========================================================================================================
function [mY, mCount] = Aggregate(mY, mCount, mGroup, mGroupIndices, p)
% --------------------------------------------------------------------------------------------------------- %
% Extracts group of patches from video.
%
% Input:
%   mY -            3D array of video frames. [h, w, f]
%   mCount -        3D array of counter for grouped video pixels. [h, w, f]
%   mGroup -        2D array containing vecotrized patches in group. [K, p^2]
%   mGroupIndices - 2D array containing upper-left indices of patches in group. [K, 3]
%   p -             Patch size (single dimension).
%
% Output:
%   mY -     3D array of updated video frames. [h, w, f]
%   mCount - 3D array of updated counter for grouped video pixels. [h, w, f]
% --------------------------------------------------------------------------------------------------------- %

K = size(mGroupIndices, 1);
for iPatch = 1:K
    row =   mGroupIndices(iPatch, 1);
    col =   mGroupIndices(iPatch, 2);
    frame = mGroupIndices(iPatch, 3);
    mY(row + (0:(p-1)), col + (0:(p-1)), frame) = mY(row + (0:(p-1)), col + (0:(p-1)), frame) + ...
        reshape(mGroup(iPatch, :), [p, p]);
    mCount(row + (0:(p-1)), col + (0:(p-1)), frame) = mCount(row + (0:(p-1)), col + (0:(p-1)), frame) + 1;
end

end
