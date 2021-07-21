function [mY, vNumUngroupedPixels] = DenoisePatches(mX, mGroupIndices, vNumNeighbors)
% --------------------------------------------------------------------------------------------------------- %
% Denoise each patch with WNNM and aggregate to form estimated image.
%
% Input:
%   mX -            3D array of noised video frames. [h, w, f]
%   mGroupIndices - 3D array containing upper-left indices of patches in group per reference patch. [N, K, 3]
%   vNumNeighbors - Array containing number of effective neighbors per reference patch. [N, 1]
%
% Output:
%   mY -                  Denoised image. [h, w, f]
%   vNumUngroupedPixels - Number of unprocessed pixels per frame. [1, f]
% --------------------------------------------------------------------------------------------------------- %

end
