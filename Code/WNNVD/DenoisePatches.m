function [mY, mGroupedPixels] = DenoisePatches(mX, mGroupIndices, vNumNeighbors, sConfig)
% --------------------------------------------------------------------------------------------------------- %
% Denoise each patch with WNNM and aggregate to form estimated image.
%
% Input:
%   mX -            3D array of noised video frames. [h, w, f]
%   mGroupIndices - 3D array containing upper-left indices of patches in group per reference patch. [N, K, 3]
%   vNumNeighbors - Array containing number of effective neighbors per reference patch. [N, 1]
%   sConfig -       Struct containing all parameters for algorithm.
%
% Output:
%   mY -             Denoised image. [h, w, f]
%   mGroupedPixels - 3D boolean array stating which pixles in video have been processed. [h, w, f]
% --------------------------------------------------------------------------------------------------------- %

p = sConfig.sBlockMatching.patchSize;

mPreAgg =     zeros(size(mX)); % sum of all (possibly overlapping) denoised patches, for aggregation.
mPixelCount = zeros(size(mX)); % counter for number of times each pixel was part of a group, for aggregation

for iGroup = 1:size(mGroupIndices, 1)
    % Extract current patch group:
    mCurGroupIndices = mGroupIndices(iGroup, 1:vNumNeighbors(iGroup), :);
    mGroup = ExtractGroup(mX, mCurGroupIndices, p);
    
    % Denoise using WNNM:
    mGroupDenoised = WNNM(mGroup, sConfig);
    
    % Aggregate:
    [mPreAgg, mPixelCount] = Aggregate(mPreAgg, mPixelCount, mGroupDenoised, mCurGroupIndices, p);
end

mGroupedPixels = (mPixelCount > 0);
mY = mPreAgg(mGroupedPixels)./mPixelCount(mGroupedPixels);

end

%% ==========================================================================================================
function mGroup = ExtractGroup(mX, mGroupIndices, p)
% --------------------------------------------------------------------------------------------------------- %
% Extracts group of patches from video.
%
% Input:
%   mX -            3D array of video frames. [h, w, f]
%   mGroupIndices - 2D array containing upper-left indices of patches in group. [K, 3]
%   p -             Patch size (single dimension).
%
% Output:
%   mGroup - 2D array containing vecotrized patches in group. [K, p^2]
% --------------------------------------------------------------------------------------------------------- %

K = size(mGroupIndices, 1);
mGroup = zeros(K, p^2);
for iPatch = 1:K
    row =   mGroupIndices(1);
    col =   mGroupIndices(2);
    frame = mGroupIndices(3);
    mGroup(iPatch, :) = reshape(mX(row + (0:(p-1)), col + (0:(p-1)), frame), [1, p^2]);
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
    row =   mGroupIndices(1);
    col =   mGroupIndices(2);
    frame = mGroupIndices(3);
    mY(row + (0:(p-1)), col + (0:(p-1)), frame) = mY(row + (0:(p-1)), col + (0:(p-1)), frame) + ...
        reshape(mGroup(iPatch, :), [p, p]);
    mCount(row + (0:(p-1)), col + (0:(p-1)), frame) = mCount(row + (0:(p-1)), col + (0:(p-1)), frame) + 1;
end

end
