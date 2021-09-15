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
%
% TODO:
%   1) Implement solution for multi-channel (color) videos.
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
mY =                 mX;
mGroupedPixels =     false(size(mX));
vProcessedPerFrame = zeros(f, 1);
refFrame =           ceil(f/2);
iter =               1;
while (iter <= sConfig.sWNNM.nFrameIter) && any((1 - vProcessedPerFrame)*100 > sConfig.sWNNM.maxUngrouped)
    % run iteration on single reference frame:
    tStart = tic;
    [mY, mGroupedPixels, vNPatchesPerFrame] = ...
        WNNVDRefFrame(mY, mPreDenoised, mGroupedPixels, refFrame, sConfig);
    itTime = toc(tStart);
    
    % update log:
    vProcessedPerFrame = squeeze(mean(mean(mGroupedPixels)));
    processed = mean(vProcessedPerFrame);
    if saveLog
        sLog = UpdateLog(sLog, refFrame, processed, vNPatchesPerFrame, itTime);
    end
    
    % choose next reference frame:
    vNumGrouped = squeeze(sum(mGroupedPixels, [1, 2]));
    refFrame = ChooseNextRefFrame(refFrame, vNumGrouped);
    
    fprintf("it: %d | Processed: %.2f%% | Time: %.2f\n", iter, processed*100, itTime);
    iter = iter + 1;
end

end

%% ==========================================================================================================
function nextRefFrame = ChooseNextRefFrame(refFrame, vNumGrouped)
% --------------------------------------------------------------------------------------------------------- %
% Chooses next reference frame based on the one with most ungrouped pixels and which is furthest from current
% reference frame.
% --------------------------------------------------------------------------------------------------------- %

minNumGrouped = min(vNumGrouped);
nextRefFrameOptions = find(vNumGrouped == minNumGrouped);
[~, nextFrameInd] = max(abs(nextRefFrameOptions - refFrame)); % frame which is furthest from current
nextRefFrame = nextRefFrameOptions(nextFrameInd);

end
