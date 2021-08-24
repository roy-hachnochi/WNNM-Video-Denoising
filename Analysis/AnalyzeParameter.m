% ========================================================================================================= %
% Run multiple tests while varying a single parameter in order to choose the best option.
% ========================================================================================================= %

%% Parameters:
vidInPaths = {fullfile('Videos','gbicycle.avi'),...
              fullfile('Videos','gflower.avi'),...
              fullfile('Videos','gmissa.avi'),...
              fullfile('Videos','gsalesman.avi'),...
              fullfile('Videos','gstennis.avi'),...
              fullfile('Videos','lena.png')};
parameterToCheck = 'maxNeighborsFrame'; % we allow to check only params from sBlockMatching, see GetConfig()
vParamValues =     [1, 10, 20, 30, 50, 70, 100, 125, 150];
% parameterToCheck = 'maxGroupSize';
% vParamValues =     [20, 50, 80, 100, 150, 200, 300, 400, 500];
% parameterToCheck = 'distTh';
% vParamValues =     [10, 15, 17, 20, 22, 25, 27, 30, 33];
noiseSig =         20; 
maxFrames =        5;

%% Initializations:
sConfig = GetConfig();
sConfig.sNoise.sigma =    noiseSig;
sConfig.sVidProperties.maxFrames = maxFrames;
nTests = length(vParamValues);

%% Run tests:
mPSNR =         zeros(nTests, length(vidInPaths));
mSSIM =         zeros(nTests, length(vidInPaths));
mTimePerFrame = zeros(nTests, length(vidInPaths));
for iTest = 1:nTests
    sConfig.sBlockMatching.(parameterToCheck) = vParamValues(iTest);
    [mPSNR(iTest, :), mSSIM(iTest, :), mTimePerFrame(iTest, :)] = ...
        RunDenoising(sConfig, 'WNNVD', [], vidInPaths);
    fprintf('Finished %d/%d tests.\n', iTest, nTests);
end

%% Plot results:
mParamValues = repmat(vParamValues.', [1 length(vidInPaths)]);
figure;

% PSNR:
subplot(2,2,1);
plot(mParamValues, mPSNR, '.-');
ylabel('PSNR');
xlabel(parameterToCheck);
grid on;
title('PSNR vs. Varying Parameter');

% PSNR:
subplot(2,2,2);
plot(mParamValues, mSSIM, '.-');
ylabel('SSIM');
xlabel(parameterToCheck);
grid on;
title('SSIM vs. Varying Parameter');

% Runtime:
subplot(2,1,2);
plot(mParamValues, mTimePerFrame, '.-');
ylabel('t [sec]');
xlabel(parameterToCheck);
grid on;
title('Runtime Per Frame vs. Varying Parameter');

sgtitle(['\sigma_n = ',num2str(noiseSig),', Varying Parameter: ',parameterToCheck]);

%% Plot average results:
figure;

% PSNR + SSIM:
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
       'PSNR & SSIM vs. Varying Parameter']);

% Runtime:
subplot(2,1,2);
plot(vParamValues, mean(mTimePerFrame, 2), '*-', 'LineWidth', 2);
ylabel('t [sec]');
xlabel(parameterToCheck);
grid on;
title('Runtime Per Frame vs. Varying Parameter - Average Results');
