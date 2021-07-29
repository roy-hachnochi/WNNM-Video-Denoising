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

% TODO: temp for test
% mIm = imread('lena.png');
% mFrames = reshape(mIm, [size(mIm, 1), size(mIm, 2), 1, 1]);

%% Add noise:
mX = VideoNoise(mFrames, sConfig.sNoise);
mX = squeeze(mX(:,:,1,:)); % TODO: add solution for multi-channel

% subplot(1,2,1);
% imshow(uint8(mFrames(:,:,10)));
% subplot(1,2,2);
% imshow(uint8(mX(:,:,10)));

%% Denoise:
mX = single(mX);
mY = WNNVD(mX, sConfig);
mY = uint8(mY);

%% Save and show results:

