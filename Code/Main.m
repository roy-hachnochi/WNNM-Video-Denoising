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
mFrames = VideoLoader(sConfig.sInput);

%% Add noise:
mX = VideoNoise(mFrames, sConfig.sNoise);
mX = mX(:,:,1,:); % TODO: add solution for multi-channel

subplot(1,2,1);
imshow(mFrames(:,:,:,10));
subplot(1,2,2);
imshow(mX(:,:,:,10));

%% Denoise:
mY = WNNVD(mX, sConfig);

%% Save and show results:

