% ========================================================================================================= %
% Plot an example denoised frames as a single image.
% ========================================================================================================= %

rng(42);

%% Parameters:
vidNames = {fullfile('Results','Clean','gsalesman_WNNVD_10.avi'),...
            fullfile('Results','Clean','gsalesman_WNNVD_20.avi'),...
            fullfile('Results','Clean','gsalesman_WNNVD_30.avi')};
outFolder = fullfile('Analysis','Figures');
refFrame =  32;
b_saveFig = true;

%% Initializations:
sConfig = GetConfig();
sConfig.sVidProperties.maxFrames = refFrame;

%% Run Block Matching:
mIm = [];
for iVid = 1:length(vidNames)
    % Load video
    mX = LoadVideo(vidNames{iVid}, sConfig.sVidProperties);
    mX = squeeze(mX(:,:,1,refFrame));
    
    mIm = [mIm, mX];
end

%% Plot image
figure;
imshow(mIm);

if b_saveFig
    saveas(gcf, fullfile(outFolder,'ResultExample'));
end
