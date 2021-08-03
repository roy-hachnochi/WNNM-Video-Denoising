function mRefPatchInds = GetRefPatchInds(h, w, mSkip, sConfig)
% --------------------------------------------------------------------------------------------------------- %
% Get reference patch indices.
%
% Input:
%   h -       Frame height.
%   w -       Frame width.
%   mSkip -   2D boolean array stating which pixels in reference frame don't need to be processed. [h, w]
%   sConfig - Struct containing all parameters for algorithm.
%
% Output:
%   mRefPatchInds - 2D array containing upper-left indices of reference patches. [N, 2]
% --------------------------------------------------------------------------------------------------------- %

s = sConfig.sBlockMatching.refStride;
p = sConfig.sBlockMatching.patchSize;

% enforce last patch to start at maximal indices, and don't allow patches that exceed this:
vRefRows = [1:s:(h-p), h - p + 1];
vRefCols = [1:s:(w-p), w - p + 1];

[mRefRows, mRefCols] = meshgrid(vRefRows, vRefCols);
mRefPatchInds = zeros(length(vRefRows)*length(vRefCols), 2);
mRefPatchInds(:, 1) = mRefRows(:);
mRefPatchInds(:, 2) = mRefCols(:);

% erase patches for which all pixels are to be skipped:
N = size(mRefPatchInds, 1);
vErase = false([N, 1]);
for iRef = 1:N
    mPatch = mSkip(mRefPatchInds(iRef, 1) + (0:p-1), mRefPatchInds(iRef, 2) + (0:p-1));
    vErase(iRef) = all(mPatch(:));
end
mRefPatchInds = mRefPatchInds(~vErase, :);

end
