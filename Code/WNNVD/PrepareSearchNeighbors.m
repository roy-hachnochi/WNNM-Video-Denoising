function [mPatchDict, mKeyNeighbors] = PrepareSearchNeighbors(mX, sConfig)
% --------------------------------------------------------------------------------------------------------- %
% Prepares patch indices and calculates neighboring patches per key patch.
%
% Input:
%   mX -      4D array of noised video frames. [h, w, f]
%   sConfig - Struct containing all parameters for algorithm.
%
% Output:
%   mPatchDict -    2D array containing patch indices. [# patches, 3]
%                   Each row marks the upper-left index of the patch by (row, col, frame).
%   mKeyNeighbors - 2D sparse boolean array marking 1 for neighboring patches and 0 otherwise.
%                   [# key patches, # patches]
% --------------------------------------------------------------------------------------------------------- %


end
