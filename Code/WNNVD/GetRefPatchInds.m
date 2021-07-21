function mRefPatchInds = GetRefPatchInds(h, w, sConfig)
% --------------------------------------------------------------------------------------------------------- %
% Get reference patch indices.
%
% Input:
%   h -       Frame height.
%   w -       Frame width.
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

end
