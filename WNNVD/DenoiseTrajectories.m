function [mY, mGroupedPixels] = DenoiseTrajectories(mX, mNoised, mGroupIndices, mNumNeighbors, sConfig, isWaitbar)
% --------------------------------------------------------------------------------------------------------- %
% Denoise each trajectory block with WNNM and aggregate to form estimated image.
%
% Input:
%   mX -            3D array of noised video frames. [h, w, f]
%   mNoised -       3D array of original noised video frames. [h, w, f]
%   mGroupIndices - 4D array containing upper-left indices of trajectories in group per reference trajectories. [N, K, M, 3]
%   mNumNeighbors - Matrix containing number of effective neighbors per reference trajectories and their length. [N, K, 1]
%   sConfig -       Struct containing all parameters for algorithm.
%   isWaitbar -     (optional) Display waitbar (default: false).
%
% Output:
%   mY -             Denoised image. [h, w, f]
%   mGroupedPixels - 3D boolean array stating which pixles in video have been processed. [h, w, f]
%
% TODO:
%   1) Process only ungrouped patches in order to save runtime?
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
    mCurGroupIndices = reshape(mGroupIndices(iGroup, 1:mNumNeighbors(iGroup,1), 1:mNumNeighbors(iGroup,2), :), [mNumNeighbors(iGroup,1),mNumNeighbors(iGroup,2),3]);
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
%   mGroupIndices - 3D array containing upper-left indices of patches in group. [K, M, 3]
%   p -             Patch size (single dimension).
%   noiseSigma -    Original noise STD of video.
%
% Output:
%   mGroup -        2D array containing vecotrized patches in group. [K, M*p^2]
%   noiseSigmaEst - Estimated noise STD for reference patch.
% --------------------------------------------------------------------------------------------------------- %

[h, w, f] = size(mX);

% top-left indices of each patch in group:
vPatchStartInds = sub2ind([h, w, f], mGroupIndices(:,:,1), mGroupIndices(:,:,2), mGroupIndices(:,:,3)); % [K, 1]

% relative patch indices in frame from top-left corner:
mSinglePatchInds = (0:p-1)' + h*(0:p-1); % [p, p]
mSinglePatchInds = reshape(mSinglePatchInds, [1, 1, size(mSinglePatchInds)]); % [1, p, p]

% extract patches:
mPatches = mX(vPatchStartInds + repmat(mSinglePatchInds, [size(vPatchStartInds,1),size(vPatchStartInds,2),1,1])); % [K, p, p]
mGroup = reshape(mPatches, [size(mGroupIndices,1), size(mGroupIndices,2)*p^2]); % [K, p^2]

% estimate noise based on reference trajectory:
vNoisedPatch = reshape(mNoised(vPatchStartInds(1,:)' + repmat(reshape(mSinglePatchInds,1,p,p),size(mGroupIndices,2),1,1)), [1,size(mGroupIndices,2)*p^2]);
noiseSigmaEst = sqrt(abs(mean((mGroup(1, :) - vNoisedPatch).^2) - noiseSigma^2));

end

%% ==========================================================================================================
function [mY, mCount] = Aggregate(mY, mCount, mGroup, mGroupIndices, p)
% --------------------------------------------------------------------------------------------------------- %
% Extracts group of patches from video.
%
% Input:
%   mY -            3D array of video frames. [h, w, f]
%   mCount -        3D array of counter for grouped video pixels. [h, w, f]
%   mGroup -        2D array containing vecotrized patches in group. [K, M*p^2]
%   mGroupIndices - 2D array containing upper-  left indices of patches in group. [K, M, 3]
%   p -             Patch size (single dimension).
%
% Output:
%   mY -     3D array of updated video frames. [h, w, f]
%   mCount - 3D array of updated counter for grouped video pixels. [h, w, f]
% --------------------------------------------------------------------------------------------------------- %

[h, w, f] = size(mY);

% top-left indices of each patch in group:
vPatchStartInds = sub2ind([h, w, f], mGroupIndices(:,:,1), mGroupIndices(:,:,2), mGroupIndices(:,:,3)); % [K, 1]

% relative patch indices in frame from top-left corner:
mSinglePatchInds = (0:p-1)' + h*(0:p-1); % [p, p]

% reshape the group in order to seperate all the patches
mGroup = double(reshape(mGroup,size(mGroupIndices,1),size(mGroupIndices,2),[]));

for iOffset = 1:numel(mSinglePatchInds)
    offset = mSinglePatchInds(iOffset);
    mY(vPatchStartInds + offset) = mY(vPatchStartInds + offset) + mGroup(:, :, iOffset);
    mCount(vPatchStartInds + offset) = mCount(vPatchStartInds + offset) + 1;
end

end
