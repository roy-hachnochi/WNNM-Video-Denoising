function mY = WNNVD(mX, sConfig)
% --------------------------------------------------------------------------------------------------------- %
% Weighted Nuclear Norm Video Denoiser.
%
% Input:
%   mX -      3D array of noised video frames. [h, w, f]
%   sConfig - Struct containing all parameters for algorithm.
%
% Output:
%   mY - 3D array of denoised video frames. [h, w, f]
% --------------------------------------------------------------------------------------------------------- %

[h, w, f] = size(mX);

%% Pre-denoising for block matching
mPreDenoised = zeros(size(mX));
for frame = 1:f
    mPreDenoised(:,:,frame) = PreProcessFrame(mX(:,:,frame));
end

%% Perform WNNVD for a single reference frame
mY = mX;
for it = 1:1
    % TODO: wrap with while/for - for different refernce frames...
    % TODO: add frame selector
    [mY, mUngroupedPixels] = WNNVDRefFrame(mY, mPreDenoised, ceil(f/2), sConfig);
end

end