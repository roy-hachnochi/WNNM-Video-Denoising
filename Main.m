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
[mFrames, frameRate] = VideoLoad(sConfig.sTest);
[h, w, ch, f] = size(mFrames);

%% Add noise:
mX = VideoNoise(mFrames, sConfig.sNoise);
mX = squeeze(mX(:,:,1,:)); % TODO: add solution for multi-channel

%% Denoise:
mX = single(mX);
[mY, sLog] = WNNVD(mX, sConfig);

mX = reshape(uint8(mX), [h, w, ch, f]);
mY = reshape(uint8(mY), [h, w, ch, f]);

%% Calculate success metrics:
sLog.psnr = PSNR(mFrames, mY);
sLog.ssim = SSIM(mFrames, mY);
fprintf("\n==== Done! PSNR: %.2f | SSIM: %.2f | Time: %.2f ====\n\n", sLog.psnr, sLog.ssim, sum(sLog.vTime));

%% Save and show results:
VideoSave(mY, frameRate, sConfig.sTest);
