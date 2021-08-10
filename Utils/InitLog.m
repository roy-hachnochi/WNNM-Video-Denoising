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

maxIt = min(sConfig.sWNNM.nIter, nFrames);

sLog.nIt =               0;                         % Actual number of iterations
sLog.vChosenFrames =     zeros([maxIt, 1]);         % Chosen reference frame per iteration
sLog.vProcessed =        zeros([maxIt, 1]);         % Proportion of done pixels in video per iteration
sLog.vTime =             zeros([maxIt, 1]);         % Runtime per iteration
sLog.mNPatchesPerFrame = zeros([maxIt, nFrames]);   % Number of chosen patches per frame per iteration
sLog.psnr =              0;                         % Final PSNR
sLog.ssim =              0;                         % Final SSIM
sLog.time =              0;                         % Total runtime [sec]
sLog.alg =               'WNNVD';                   % Algorithm used for denoising
sLog.vidName =           '';                        % Name of denoised video
sLog.noiseStd =          sConfig.sNoise.sigma;      % Noise STD of input video
sLog.sConfig =           sConfig;                   % Algorithm parameters

end
