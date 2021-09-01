% ========================================================================================================= %
% Run multiple tests while varying a single parameter in order to choose the best option.
% ========================================================================================================= %

%% Parameters:
vidInPaths = {fullfile('Videos','gbicycle.avi'),...
              fullfile('Videos','gflower.avi'),...
              fullfile('Videos','gmissa.avi'),...
              fullfile('Videos','gsalesman.avi'),...
              fullfile('Videos','gstennis.avi')};
outFolder = fullfile('Analysis','Figures');
noiseSig =  20;
maxFrames = 40;
b_saveFig = true;
plotType =  3; % 1 - PSNR+SSIM, 2 - Time per frame, 3 - PSNR+SSIM+Time

parameterToCheck = 'maxNeighborsFrame'; % we allow to check only params from sBlockMatching, see GetConfig()
vParamValues =     [1, 5, 10, 15, 20, 25, 30, 40, 50, 70];
% parameterToCheck = 'maxGroupSize';
% vParamValues =     [10, 20, 50, 80, 100, 125, 150, 200, 250, 300];
% parameterToCheck = 'searchWindowT';
% vParamValues =     [0, 1, 2, 3, 5, 7, 10, 12, 15, 20];
% parameterToCheck = 'distTh';
% vParamValues =     [10, 15, 17, 20, 22, 25, 27, 30, 33]?

%% Initializations:
sConfig = GetConfig();
sConfig.sNoise.sigma = noiseSig;
sConfig.sVidProperties.maxFrames = maxFrames;
nTests = length(vParamValues);

%% Run tests:
mPSNR =         zeros(nTests, length(vidInPaths));
mSSIM =         zeros(nTests, length(vidInPaths));
mTimePerFrame = zeros(nTests, length(vidInPaths));
for iTest = 1:nTests
    sConfig.sBlockMatching.(parameterToCheck) = vParamValues(iTest);
    [mPSNR(iTest,:), mSSIM(iTest,:), mTimePerFrame(iTest,:)] = RunDenoising(sConfig, 'WNNVD', [], vidInPaths);
    fprintf('Finished %d/%d tests.\n', iTest, nTests);
end

%% Plot results:
mParamValues = repmat(vParamValues.', [1 length(vidInPaths)]);
figure('units','normalized','outerposition',[0 0 1 1]);

if plotType == 1
    % PSNR:
    subplot(2,2,1);
    plot(mParamValues, mPSNR, '.-', 'LineWidth', 1.5);
    ylabel('PSNR');
    xlabel(parameterToCheck);
    grid on;
    title('PSNR vs. Varying Parameter');

    % SSIM:
    subplot(2,2,2);
    plot(mParamValues, mSSIM, '.-', 'LineWidth', 1.5);
    ylabel('SSIM');
    xlabel(parameterToCheck);
    grid on;
    title('SSIM vs. Varying Parameter');

    % Average:
    subplot(2,1,2);
    yyaxis left
    plot(vParamValues, mean(mPSNR, 2), '*-', 'LineWidth', 2);
    ylabel('PSNR');
    yyaxis right
    plot(vParamValues, mean(mSSIM, 2), '*-', 'LineWidth', 2);
    ylabel('SSIM');
    xlabel(parameterToCheck);
    grid on;
    title('PSNR & SSIM Averages');

    sgtitle(['\sigma_n = ',num2str(noiseSig),', Varying Parameter: ',parameterToCheck]);
    
elseif plotType == 2
    % Runtime:
    subplot(2,1,2);
    plot(mParamValues, mTimePerFrame, '.-', 'LineWidth', 1.5);
    ylabel('t [sec]');
    xlabel(parameterToCheck);
    grid on;
    title(['\sigma_n = ',num2str(noiseSig),', Varying Parameter: ',parameterToCheck,newline,newline,...
       'Runtime Per Frame vs. Varying Parameter']);
    
    % Average:
    subplot(2,1,2);
    plot(vParamValues, mean(mTimePerFrame, 2), '*-', 'LineWidth', 2);
    ylabel('t [sec]');
    xlabel(parameterToCheck);
    grid on;
    title('Runtime Per Frame Average');
    
elseif plotType == 3
    % PSNR + SSIM Average:
    subplot(2,1,1);
    yyaxis left
    plot(vParamValues, mean(mPSNR, 2), '*-', 'LineWidth', 2);
    ylabel('PSNR');
    yyaxis right
    plot(vParamValues, mean(mSSIM, 2), '*-', 'LineWidth', 2);
    ylabel('SSIM');
    xlabel(parameterToCheck);
    grid on;
    title(['\sigma_n = ',num2str(noiseSig),', Varying Parameter: ',parameterToCheck,newline,newline,...
       'PSNR & SSIM Averages']);
    
    % Runtime Average:
    subplot(2,1,2);
    plot(vParamValues, mean(mTimePerFrame, 2), '*-', 'LineWidth', 2);
    ylabel('t [sec]');
    xlabel(parameterToCheck);
    grid on;
    title('Runtime Per Frame Average');
end

if b_saveFig
    savefig(fullfile(outFolder,['Analyze_',parameterToCheck,'_',num2str(plotType)]));
end
