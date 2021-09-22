% ========================================================================================================= %
% Plot an example of denoised frames as a single image.
% ========================================================================================================= %

rng(42);

%% Parameters:
noisedVidNames = {fullfile('Videos','Noised','gbicycle_10.avi'),...
                  fullfile('Videos','Noised','gbicycle_20.avi'),...
                  fullfile('Videos','Noised','gbicycle_30.avi')};
vidNames = {fullfile('Results','Clean','gbicycle_WNNVD_10.avi'),...
            fullfile('Results','Clean','gbicycle_WNNVD_20.avi'),...
            fullfile('Results','Clean','gbicycle_WNNVD_30.avi')};
outFolder = fullfile('Analysis','Figures');
refFrame =  20;
b_saveFig = true;

assert(length(noisedVidNames) == length(vidNames));

%% Initializations:
sConfig = GetConfig();
sConfig.sVidProperties.maxFrames = refFrame;

%% Run Block Matching:
mIm = [];
for iVid = 1:length(vidNames)
    % Load videos
    mX = LoadVideo(vidNames{iVid}, sConfig.sVidProperties);
    mX = squeeze(mX(:,:,1,refFrame));
    mXNoised = LoadVideo(noisedVidNames{iVid}, sConfig.sVidProperties);
    mXNoised = squeeze(mXNoised(:,:,1,refFrame));
    
    mIm = [mIm, [mXNoised; mX]]; %#ok
end

%% Plot image
figure;
imshow(mIm);

if b_saveFig
    saveas(gcf, fullfile(outFolder,'ResultExample'));
end
