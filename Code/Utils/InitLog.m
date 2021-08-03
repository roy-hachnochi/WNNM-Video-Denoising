function [sLog] = InitLog(sConfig, nFrames)
% --------------------------------------------------------------------------------------------------------- %
% Initializes log struct with run statistics.
%
% Input:
%   sConfig - Struct containing all parameters for algorithm.
%   nFrames - Number of frames in the video.
%
% Output:
%   sLog - Log struct with run statistics.
% --------------------------------------------------------------------------------------------------------- %

maxIt = sConfig.sWNNM.nIter;

sLog.nIt =               0;                         % Actual number of iterations
sLog.vChosenFrames =     zeros([maxIt, 1]);         % Chosen reference frame per iteration
sLog.vProcessed =        zeros([maxIt, 1]);         % Proportion of done pixels in video per iteration
sLog.vTime =             zeros([maxIt, 1]);         % Runtime per iteration
sLog.mNPatchesPerFrame = zeros([maxIt, nFrames]);   % Number of chosen patches per frame per iteration
sLog.psnr =              0;                         % Final PSNR
sLog.ssim =              0;                         % Final SSIM
sLog.sConfig =           sConfig;                   % Algorithm parameters

end
