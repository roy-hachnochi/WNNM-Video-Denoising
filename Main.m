% ========================================================================================================= %
% Digital Signal Processing
% Final Project: Using WNNM for Video Denoising (WNNVD)
% Roy Hachnochi 311120851
% Uri Kapustin  317598811
% ========================================================================================================= %
clear;
close all;
rng(42);

%% Get parameters config:
sConfig = GetConfig();

%% Load video:
[mFrames, frameRate] = LoadVideo(sConfig.sTest);
[h, w, ch, f] = size(mFrames);

%% Add noise:
mX = VideoNoise(mFrames, sConfig.sNoise);

%% Denoise:
mX = single(squeeze(mX(:,:,1,:)));
[mY, sLog] = WNNVD(mX, sConfig);

mX = reshape(uint8(mX), [h, w, ch, f]);
mY = reshape(uint8(mY), [h, w, ch, f]);

%% Calculate success metrics:
sLog.psnr = PSNR(mFrames, mY);
sLog.ssim = SSIM(mFrames, mY);
fprintf("\n==== Done! PSNR: %.2f | SSIM: %.2f | Time: %.2f min ====\n\n",...
    sLog.psnr, sLog.ssim, sum(sLog.vTime)/60);

%% Save results:
SaveVideo(mY, frameRate, sConfig.sTest.vidOutPath);
SaveVideo(mX, frameRate, sConfig.sTest.vidNoisedPath);
SaveLog(sLog, sConfig.sTest.logPath)
