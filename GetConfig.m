function sConfig = GetConfig()
% --------------------------------------------------------------------------------------------------------- %
% Defines parameters configuration for using and reproducing WNNVD results.
%
% TODO: Set params.
% --------------------------------------------------------------------------------------------------------- %

%% Test video:
sConfig.sTest.vidInPath =     'Videos/gbicycle.avi'; % Video input path for testing
sConfig.sTest.vidOutPath =    'Results/temp.avi'; % Video output path
sConfig.sTest.maxFrames =     20;                              % Maximal number of frames (for runtime)
sConfig.sTest.logPath =       'Results/temp';      % Log output path
sConfig.sTest.isGray =        true;                            % Use grayscale video or RGB

assert(sConfig.sTest.isGray, "TODO: TEMP! implement solution for RGB");

%% Noise types:
sConfig.sNoise.isPoiss = false;                 % Add Poisson noise or not
sConfig.sNoise.sigma =   20;                    % Gaussian noise STD (in [0,255] scale)
sConfig.sNoise.snp =     0.00;                  % Salt & pepper noise density

%% Block matching params:
sConfig.sBlockMatching.refStride =         7;    % Stride between reference pathces
sConfig.sBlockMatching.patchSize =         8;    % Patch size
sConfig.sBlockMatching.maxNeighborsFrame = 70;   % Maximal number of nearest neighbors per frame
sConfig.sBlockMatching.maxGroupSize =      300;  % Maximal group size (number of patches) per reference patch
sConfig.sBlockMatching.searchWindowNP =    30;   % Non-predictive search window
sConfig.sBlockMatching.searchStrideNP =    2;    % Non-predictive stride between search patches
sConfig.sBlockMatching.searchWindowP =     3;    % Predictive search window
sConfig.sBlockMatching.searchStrideP =     3;    % Predictive stride between search patches
sConfig.sBlockMatching.searchWindowT =     10;   % Temporal search window (frames)
sConfig.sBlockMatching.metric =            'l2'; % Metric of distance between blocks ('l1' or 'l2')
sConfig.sBlockMatching.distTh =            30;   % Threshold for maximal distance between grouped patches

assert(sConfig.sBlockMatching.refStride <= sConfig.sBlockMatching.patchSize, ...
    "Stride must by smaller or equal to Patch Size in order to cover the entire image");

%% Other algorithm params:
sConfig.sWNNM.nIter =          8;       % Number of WNNM iterations
sConfig.sWNNM.nFrameIter =     50;      % Maximal number of iterations on different reference frame
sConfig.sWNNM.maxUngrouped =   0.2;     % Maximal allowed percentage of ungrouped pixels to finish algorithm
sConfig.sWNNM.delta =          0.1;     % Iterative regularization parameter
sConfig.sWNNM.C =              sqrt(2); % Weight constant
sConfig.sWNNM.BMIter =         4;       % Number of iterations between re-block-matching
sConfig.sWNNM.lambda =         0.54;    % Noise estimate parameter
sConfig.sWNNM.minIterForSkip = 8;       % Minimal number of iterations on pixel to consider it as denoised

end
