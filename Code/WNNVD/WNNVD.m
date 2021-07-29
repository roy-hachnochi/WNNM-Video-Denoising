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

[~, ~, f] = size(mX);

%% Pre-denoising for block matching
mPreDenoised = zeros(size(mX));
for frame = 1:f
    mPreDenoised(:,:,frame) = PreprocessFrame(mX(:,:,frame));
end

%% Perform WNNVD for a single reference frame
mY =             mX;
mGroupedPixels = false(size(mX));
nextRefFrame =   ceil(f/2);
iter =           1;
while (iter <= sConfig.sWNNM.nFrameIter) && (mean(~mGroupedPixels(:))*100 > sConfig.sWNNM.maxUngrouped)
    [mY, mGroupedPixels] = WNNVDRefFrame(mY, mPreDenoised, mGroupedPixels, nextRefFrame, sConfig);
    
    % choose next reference frame based on the one with most ungrouped pixels:
    vNumGrouped = squeeze(sum(mGroupedPixels, [1, 2]));
    [~, nextRefFrame] = min(vNumGrouped);
    
    % TODO: print mean(mGroupedPixels(:))*100 and nextRefFrame for each iteration?
end

end