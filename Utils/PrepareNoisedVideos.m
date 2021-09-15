% ========================================================================================================= %
% A script for creating noised videos.
% ========================================================================================================= %

rng(42);

inPath =     'Videos';
outPath =    fullfile('Videos','Noised');
vidNames =   {'gbicycle', 'gflower', 'gmissa', 'gsalesman', 'gstennis'};
imNames =    {'lena'};
vNoiseSigs = [10, 20, 30];
sConfig =    GetConfig();
sConfig.sVidProperties.maxFrames = inf;

for noiseSig = vNoiseSigs
    sConfig.sNoise.sigma = noiseSig;
    
    for iVid = 1:length(vidNames)
        vidInPath = fullfile(inPath,[vidNames{iVid},'.avi']);
        vidOutPath = fullfile(outPath,[vidNames{iVid},'_',num2str(noiseSig),'.avi']);
        
        [mOrigVid, frameRate] = LoadVideo(vidInPath, sConfig.sVidProperties);
        mXNoised = VideoNoise(mOrigVid, sConfig.sNoise);
        SaveVideo(mXNoised, frameRate, vidOutPath);
    end
    
    for iIm = 1:length(imNames)
        imInPath = fullfile(inPath,[imNames{iIm},'.png']);
        imOutPath = fullfile(outPath,[imNames{iIm},'_',num2str(noiseSig),'.png']);
        
        [mOrigVid, frameRate] = LoadVideo(imInPath, sConfig.sVidProperties);
        mXNoised = VideoNoise(mOrigVid, sConfig.sNoise);
        SaveVideo(mXNoised, frameRate, imOutPath);
    end
end
