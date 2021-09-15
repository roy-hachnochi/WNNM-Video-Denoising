function [vPSNR, vSSIM, vTimePerFrame] = ...
    RunDenoising(sConfig, alg, noisedPaths, origPaths, outPaths, logPaths, noiseSig)
% --------------------------------------------------------------------------------------------------------- %
% Runs a video denoising test on a chosen video/set of videos.
%
% Input:
%   sConfig -     Struct containing all parameters for algorithm (see GetConfig.m).
%   alg -         (optional) Chosen video denoising algorithm ('WNNVD'/'WNNID'/'VBM3D', default: 'WNNVD').
%   noisedPaths - (semi-optional) Noised video paths.
%   origPaths -   (semi-optional) Original video paths.
%       - If only noisedPaths is given - doesn't calculate PSNR and SSIM.
%       - If only origPaths is given - adds noise inside and calculates PSNR and SSIM.
%       - If both are given - denoises noised videos and compares to original with PSNR and SSIM.
%   outPaths -    (optional) Output video paths for saving (default: doesn't save output video).
%   logPaths -    (optional) Log paths for saving (default: doesn't save log).
%   noiseSig -    (optional) Gaussian noise STD (default: use noiseSig from sConfig).
%
% Output:
%   vPSNR -         (optional) PSNR per test.
%   vSSIM -         (optional) SSIM per test.
%   vTimePerFrame - (optional) Algorithm runtime per frame per test.
%
% Examples:
%   1. Load a noised video and denoise it using WNNVD:
%           RunDenoising(sConfig, 'WNNVD', './noised.avi')
%   2. Load a video, add noise, denoise it using WNNVD, and compare to original:
%           [vPSNR, vSSIM, vTimePerFrame] = RunDenoising(sConfig, 'WNNVD', [], './orig.avi')
%   3. Load a noised video and the original video, denoise and compaer using VBM3D:
%           [vPSNR, vSSIM, vTimePerFrame] = RunDenoising(sConfig, 'VBM3D', './noised.avi', './orig.avi')
%   4. Load a noised video and denoise it using WNNVD, compare to original, and save log and output videos:
%           RunDenoising(sConfig, 'WNNVD', './noised.avi', './orig.avi', './out.avi', './log.mat')
% --------------------------------------------------------------------------------------------------------- %

%% Default initializations:
rng(42);

if ~exist('alg', 'var') || isempty(alg)
    alg = 'WNNVD';
end
if exist('noiseSig', 'var') && ~isempty(noiseSig)
    sConfig.sNoise.sigma = noiseSig;
end

noisedExists = (exist('noisedPaths', 'var') && ~isempty(noisedPaths));
origExists = (exist('origPaths', 'var') && ~isempty(origPaths));
saveVid = (exist('outPaths', 'var') && ~isempty(outPaths));
saveLog = (exist('logPaths', 'var') && ~isempty(logPaths));

nVids = 1;
if noisedExists
    if (ischar(noisedPaths) || isstring(noisedPaths))
        noisedPaths = {char(noisedPaths)};
    end
    nVids = length(noisedPaths);
end
if origExists
    if (ischar(origPaths) || isstring(origPaths))
        origPaths = {char(origPaths)};
    end
    nVids = length(origPaths);
end
if saveVid && (ischar(outPaths) || isstring(outPaths))
    outPaths = {char(outPaths)};
end
if saveLog && (ischar(logPaths) || isstring(logPaths))
    logPaths = {char(logPaths)};
end

if nargout >= 1
    vPSNR = zeros(1, nVids);
end
if nargout >= 2
    vSSIM = zeros(1, nVids);
end
if nargout >= 3
    vTimePerFrame = zeros(1, nVids);
end

%% Argument checks:
assert(ismember(alg, {'WNNVD', 'VBM3D', 'WNNID'}), 'Illegal alg.');
assert(noisedExists || origExists, 'Either noisedPaths or origPaths must exist.');
assert(sConfig.sNoise.sigma > 0, 'Illegal noise STD.');

if noisedExists && origExists
    assert(length(noisedPaths) == length(origPaths), 'Unmatching number of input/noised paths.');
end
if saveVid
    assert(length(outPaths) == nVids, 'Unmatching number of input/output paths.')
end
if saveLog
    assert(length(logPaths) == nVids, 'Unmatching number of input/log paths.')
end

%% Prepare parameters for algs:
if strcmp(alg, 'WNNID')
    sConfig.sBlockMatching.searchWindowT = 0; % BM on one frame at a time
end

%% Run video denoising algorithm on all vids:
for iVid = 1:nVids
    %% Load video:
    if origExists
        [mOrigVid, frameRate] = LoadVideo(origPaths{iVid}, sConfig.sVidProperties);
        [h, w, ch, f] = size(mOrigVid);
        vidName = GetVidName(origPaths{iVid});
    end

    %% Add noise:
    if noisedExists
        [mX, frameRate] = LoadVideo(noisedPaths{iVid}, sConfig.sVidProperties);
        [h, w, ch, f] = size(mX);
        vidName = GetVidName(noisedPaths{iVid});
    else
        mX = VideoNoise(mOrigVid, sConfig.sNoise);
    end
    
    if origExists
        assert(all(size(mX) == size(mOrigVid)), 'Noised and original videos must be of same size.');
    end
    
    if (f == 1) || (sConfig.sBlockMatching.searchWindowT == 0) % allow more patches for better denoising
        sConfig.sBlockMatching.maxNeighborsFrame = 70;
    end

    %% Denoise:
    if strcmp(alg, 'VBM3D')
        mX = squeeze(mX(:,:,1,:));
        tStartAlg = tic;
        [~, mY] = VBM3D(mX, sConfig.sNoise.sigma, sConfig.sVidProperties.maxFrames);
        sLog.timePerFrame = toc(tStartAlg)/f;
        mY = reshape(uint8(mY*255), [h, w, ch, f]);
    else % WNNVD/WNNID differ only by parameter change
        mX = single(squeeze(mX(:,:,1,:)));
        tStartAlg = tic;
        [mY, sLog] = WNNVD(mX, sConfig);
        sLog.timePerFrame = toc(tStartAlg)/f;
        mY = reshape(uint8(mY), [h, w, ch, f]);
    end

    %% Calculate success metrics:
    if origExists
        sLog.psnr = PSNR(mOrigVid, mY);
        sLog.ssim = SSIM(mOrigVid, mY);
        fprintf("\n==== Finished %d/%d videos | PSNR: %.2f | SSIM: %.2f | Time: %.2f min ====\n",...
            iVid, nVids, sLog.psnr, sLog.ssim, sLog.timePerFrame*f/60);
    else
        fprintf("\n==== Finished %d/%d videos | Time: %.2f min ====\n", iVid, nVids, sLog.timePerFrame*f/60);
    end
    
    %% Save results:
    sLog.alg = alg;
    sLog.vidName = vidName;
    sLog.noiseStd = sConfig.sNoise.sigma;
    if saveVid
        SaveVideo(mY, frameRate, outPaths{iVid});
    end
    if saveLog
        SaveLog(sLog, logPaths{iVid})
    end
    
    if origExists && (nargout >= 1)
        vPSNR(iVid) = sLog.psnr;
    end
    if origExists && (nargout >= 2)
        vSSIM(iVid) = sLog.ssim;
    end
    if origExists && (nargout >= 3)
        vTimePerFrame(iVid) = sLog.timePerFrame;
    end
end

end

%% ==========================================================================================================
function vidName = GetVidName(vidStr)

vidName = split(vidStr, filesep); % split from directory
vidName = split(vidName{end}, '.'); % split from extension
vidName = split(vidName{1}, '_'); % split from additions if exist
vidName = vidName{1};

end
