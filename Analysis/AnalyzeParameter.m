% ========================================================================================================= %
% Run multiple tests while varying a single parameter in order to choose the best option.
% ========================================================================================================= %

%% Parameters:
vidInPath =        'Videos/gbicycle.avi';
parameterToCheck = 'maxNeighborsFrame';
vParamValues =     [1, 10, 20, 30, 50, 70, 100, 125, 150];
% parameterToCheck = 'maxGroupSize'; % we allow to check only params from sBlockMatching, see GetConfig()
% vParamValues =     [20, 50, 80, 100, 150, 200, 300, 400, 500];
% parameterToCheck = 'distTh';
% vParamValues =     [5,10,15,17,20,22,25,27,30];
noiseSig =         20; 
maxFrames =        5;

%% Initializations:
sConfig = GetConfig();
sConfig.sNoise.sigma =    noiseSig;
sConfig.sTest.vidInPath = vidInPath;
sConfig.sTest.maxFrames = maxFrames;
nTests = length(vParamValues);

%% Run tests:
vPSNR =         zeros(1, nTests);
vSSIM =         zeros(1, nTests);
vTimePerFrame = zeros(1, nTests);
for iTest = 1:nTests
    sConfig.sBlockMatching.(parameterToCheck) = vParamValues(iTest);
    [vPSNR(iTest), vSSIM(iTest), vTimePerFrame(iTest)] = RunTest(sConfig, 'WNNVD');
    fprintf('Finished %d/%d tests.\n', iTest, nTests);
end

%% Plot results:
figure;

% PSNR + SSIM:
subplot(2,1,1);
yyaxis left
plot(vParamValues, vPSNR, '-.');
ylabel('PSNR');
yyaxis right
plot(vParamValues, vSSIM, '-.');
ylabel('SSIM');
xlabel(parameterToCheck);
grid on;
title(['\sigma_n = ',num2str(noiseSig),', Varying Parameter: ',parameterToCheck,newline,newline,...
       'PSNR & SSIM vs. Varying Parameter']);

% Runtime:
subplot(2,1,2);
plot(vParamValues, vTimePerFrame, '-.');
ylabel('t [sec]');
xlabel(parameterToCheck);
grid on;
title('Runtime Per Frame vs. Varying Parameter');
