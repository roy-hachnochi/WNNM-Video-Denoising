function [mY, sLog] = WNNVD(mX, sConfig)
% --------------------------------------------------------------------------------------------------------- %
% Weighted Nuclear Norm Video Denoiser.
%
% Input:
%   mX -      3D array of noised video frames. [h, w, f]
%   sConfig - Struct containing all parameters for algorithm.
%
% Output:
%   mY -   3D array of denoised video frames. [h, w, f]
%   sLog - (optional) Log struct with run statistics.
% --------------------------------------------------------------------------------------------------------- %

[~, ~, f] = size(mX);
if nargout >= 2
    sLog = InitLog(sConfig, f);
    saveLog = true;
end

%% Pre-denoising for block matching
mPreDenoised = zeros(size(mX));
for frame = 1:f
    mPreDenoised(:,:,frame) = PreprocessFrame(mX(:,:,frame));
end

%% Perform WNNVD for a single reference frame
mY =             mX;
mGroupedPixels = false(size(mX));
processed =      0;
nextRefFrame =   ceil(f/2);
iter =           1;
while (iter <= sConfig.sWNNM.nFrameIter) && ((1 - processed)*100 > sConfig.sWNNM.maxUngrouped)
    % run iteration on single reference frame:
    tStart = tic;
    [mY, mGroupedPixels, vNPatchesPerFrame] = ...
        WNNVDRefFrame(mY, mPreDenoised, mGroupedPixels, nextRefFrame, sConfig);
    itTime = toc(tStart);
    
    % update log:
    processed = mean(mGroupedPixels(:));    
    if saveLog
        sLog = UpdateLog(sLog, nextRefFrame, processed, vNPatchesPerFrame, itTime);
    end
    
    % choose next reference frame based on the one with most ungrouped pixels:
    vNumGrouped = squeeze(sum(mGroupedPixels, [1, 2]));
    [~, nextRefFrame] = min(vNumGrouped);
    
    fprintf("it: %d | Processed: %.2f%% | Time: %.2f\n", iter, processed*100, itTime);
    iter = iter + 1;
end

end
