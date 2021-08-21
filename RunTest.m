function [vPSNR, vSSIM, vTimePerFrame] = ...
    RunTest(sConfig, alg, noisedPaths, origPaths, outPaths, logPaths, noiseSig, saveVid, saveLog)
% --------------------------------------------------------------------------------------------------------- %
% Runs a video denoising test on a chosen video/set of videos.
%
% Input:
%   sConfig -     Struct containing all parameters for algorithm (see GetConfig.m).
%   alg -         (optional) Chosen video denoising algorithm ('WNNVD'/'WNNID'/'VBM3D', default: 'WNNVD').
%   noisedPaths - (optional) Noised video paths (default: if not given, adds noise inside).
%   origPaths -   (optional) Original video paths (default: use path from sConfig).
%   outPaths -    (optional) Output video paths for saving (default: use path from sConfig).
%   logPaths -    (optional) Log paths for saving (default: use path from sConfig).
%   noiseSig -    (optional) Gaussian noise STD (default: use noiseSig from sConfig).
%   saveVid -     (optional) Save output video (default: false).
%   saveLog -     (optional) Save log struct with run statistics (default: false).
%
% Output:
%   vPSNR -         (optional) PSNR per test.
%   vSSIM -         (optional) SSIM per test.
%   vTimePerFrame - (optional) Algorithm runtime per frame per test.
% --------------------------------------------------------------------------------------------------------- %

%% Default initializations:
rng(42);

if ~exist('alg', 'var') || isempty(alg)
    alg = 'WNNVD';
end
if ~exist('origPaths', 'var') || isempty(origPaths)
    origPaths = {sConfig.sTest.vidInPath};
end
if ~exist('outPaths', 'var') || isempty(outPaths)
    outPaths = {sConfig.sTest.vidOutPath};
end
if ~exist('logPaths', 'var') || isempty(logPaths)
    logPaths = {sConfig.sTest.logPath};
end
if exist('noiseSig', 'var') && ~isempty(noiseSig)
    sConfig.sNoise.sigma = noiseSig;
end
if ~exist('saveVid', 'var') || isempty(saveVid)
    saveVid = true;
end
if ~exist('saveLog', 'var') || isempty(saveLog)
    saveLog = false;
end
noisedExists = (exist('noisedPaths', 'var') && ~isempty(noisedPaths));

if noisedExists && (ischar(noisedPaths) || isstring(noisedPaths))
    noisedPaths = {char(noisedPaths)};
end
if ischar(origPaths) || isstring(origPaths)
    origPaths = {char(origPaths)};
end
if ischar(outPaths) || isstring(outPaths)
    outPaths = {char(outPaths)};
end
if ischar(logPaths) || isstring(logPaths)
    logPaths = {char(logPaths)};
end

nVids = length(origPaths);
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
assert(sConfig.sNoise.sigma > 0, 'Illegal noise STD.');
if saveVid
    assert(length(outPaths) == nVids, 'Unmatching number of input/output paths.')
end
if saveLog
    assert(length(logPaths) == nVids, 'Unmatching number of input/log paths.')
end
if noisedExists
    assert(length(noisedPaths) == nVids, 'Unmatching number of input/noised paths.');
end

%% Prepare parameters for algs:
if strcmp(alg, 'WNNID')
    sConfig.sBlockMatching.searchWindowT = 0;
end

%% Run video denoising algorithm on all vids:
for iVid = 1:nVids
    %% Load video:
    [mOrigVid, frameRate] = LoadVideo(origPaths{iVid}, sConfig.sTest);
    [h, w, ch, f] = size(mOrigVid);
    
    vidName = split(origPaths{iVid}, filesep); % split from directory
    vidName = split(vidName{end}, '.'); % split from extension
    vidName = split(vidName{1}, '_'); % split from additions if exist
    vidName = vidName{1};

    %% Add noise:
    if noisedExists
        [mX, frameRate] = LoadVideo(noisedPaths{iVid}, sConfig.sTest);
        assert(all(size(mX) == size(mOrigVid)), 'Noised and original videos must be of same size.');
    else
        mX = VideoNoise(mOrigVid, sConfig.sNoise);
    end

    %% Denoise:
    if strcmp(alg, 'VBM3D')
        mX = squeeze(mX(:,:,1,:));
        tStartAlg = tic;
        [~, mY] = VBM3D(mX, sConfig.sNoise.sigma, sConfig.sTest.maxFrames);
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
    sLog.psnr = PSNR(mOrigVid, mY);
    sLog.ssim = SSIM(mOrigVid, mY);
    fprintf("\n==== Finished %d/%d videos | PSNR: %.2f | SSIM: %.2f | Time: %.2f min ====\n",...
        iVid, nVids, sLog.psnr, sLog.ssim, sLog.timePerFrame*f/60);

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
    
    if nargout >= 1
        vPSNR(iVid) = sLog.psnr;
    end
    if nargout >= 2
        vSSIM(iVid) = sLog.ssim;
    end
    if nargout >= 3
        vTimePerFrame(iVid) = sLog.timePerFrame;
    end
end

end
