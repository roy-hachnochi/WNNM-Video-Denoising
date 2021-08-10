function [] = RunTest(sConfig, alg, inPaths, outPaths, logPaths, noiseSig, isNoised, saveLog)
% --------------------------------------------------------------------------------------------------------- %
% Runs a video denoising test on a chosen video/set of videos.
%
% Input:
%   sConfig -     Struct containing all parameters for algorithm (see GetConfig.m).
%   alg -         (optional) Chosen video denoising algorithm ('WNNVD'/'WNNID'/'VBM3D', default: 'WNNVD').
%   inPaths -     (optional) Input video paths (default: use path from sConfig).
%   outPaths -    (optional) Output video paths for saving (default: use path from sConfig).
%   logPaths -    (optional) Log paths for saving (default: use path from sConfig).
%   noiseSig -    (optional) Gaussian noise STD (default: use noiseSig from sConfig).
%   isNoised -    (optional) Is input video noised, if not will add noise inside (default: true).
%   saveLog -     (optional) Save log struct with run statistics (default: true).
% --------------------------------------------------------------------------------------------------------- %

%% Default initializations:
rng(42);

if ~exist('alg', 'var') || isempty(alg)
    alg = 'WNNVD';
end
if ~exist('inPaths', 'var') || isempty(inPaths)
    inPaths = {sConfig.sTest.vidInPath};
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
if ~exist('isNoised', 'var') || isempty(isNoised)
    isNoised = true;
end
if ~exist('saveLog', 'var') || isempty(saveLog)
    saveLog = true;
end

%% Argument checks:
nVids = length(inPaths);
assert(ismember(alg, {'WNNVD', 'VBM3D', 'WNNID'}), 'Illegal alg.');
assert(length(outPaths) == nVids,...
    'Unmatching number of input/output paths.')
assert(sConfig.sNoise.sigma > 0, 'Illegal noise STD.');
if saveLog
    assert(length(logPaths) == nVids, 'Unmatching number of input/log paths.')
end

%% Prepare parameters for algs:
if strcmp(alg, 'WNNID')
    sConfig.sBlockMatching.searchWindowT = 0;
end

%% Run video denoising algorithm on all vids:
for iVid = 1:nVids
    %% Load video:
    [mOrigVid, frameRate] = LoadVideo(inPaths{iVid}, sConfig.sTest);
    [h, w, ch, f] = size(mOrigVid);
    
    vidName = split(inPaths{iVid}, filesep); % split from directory
    vidName = split(vidName{end}, '.'); % split from extension
    vidName = split(vidName{1}, '_'); % split from additions if exist
    vidName = vidName{1};

    %% Add noise:
    if ~isNoised
        mX = VideoNoise(mOrigVid, sConfig.sNoise);
    else
        mX = mOrigVid;
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
        iVid, nVids, sLog.psnr, sLog.ssim, sLog.time/60);

    %% Save results:
    sLog.alg = alg;
    sLog.vidName = vidName;
    sLog.noiseStd = sConfig.sNoise.sigma;
    SaveVideo(mY, frameRate, outPaths{iVid});
    if saveLog
        SaveLog(sLog, logPaths{iVid})
    end
end

end
