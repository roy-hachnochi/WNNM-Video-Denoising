% ========================================================================================================= %
% Calculates and plots PSNR per frame for multiple videos.
% ========================================================================================================= %

%% Parameters:
origFolder = 'Videos';
vidFolder =  fullfile('Results','Clean');
vidName =    'gsalesman';
noiseStd =   20;
outPath =    fullfile('Analysis','Figures','PSNRPerFrame.png');
b_saveFig =  true;

%% Initializations:
algs = {'VBM3D','WNNID','WNNVD'};
origPath = fullfile(origFolder, [vidName,'.avi']);
sConfig = GetConfig();
sConfig.sVidProperties.maxFrames = inf;
mOrigVid = LoadVideo(origPath, sConfig.sVidProperties);
[~, ~, ~, fOrig] = size(mOrigVid);

%% Calculate and plot PSNRs per video:
figure('units','normalized','outerposition',[0 0 1 1]);
for ind = 1:length(algs)
    vidPath = fullfile(vidFolder, [vidName,'_',algs{ind},'_',num2str(noiseStd),'.avi']);
    mVid = LoadVideo(vidPath, sConfig.sVidProperties);
    [~, ~, ~, f] = size(mVid);
    
    vPsnr = zeros(1, min(f,fOrig));
    for frame = 1:length(vPsnr)
        vPsnr(frame) = PSNR(squeeze(mOrigVid(:,:,1,frame)), squeeze(mVid(:,:,1,frame)));
    end
    
    plot(1:length(vPsnr), vPsnr, '*-', 'LineWidth', 2); hold on;
end

grid on;
xlabel('frame');
ylabel('PSNR');
title(['PSNR Per Frame - ', vidName,', \sigma_n = ',num2str(noiseStd)]);
legend(algs);

if b_saveFig
    saveas(gcf, outPath);
end
