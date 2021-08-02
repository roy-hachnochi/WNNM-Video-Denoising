function sConfig = GetConfig()
% --------------------------------------------------------------------------------------------------------- %
% Defines parameters configuration for using and reproducing WNNVD results.
% --------------------------------------------------------------------------------------------------------- %

%% Test video:
sConfig.sInput.videoPath = 'xylophone.mp4';     % Video path for testing
sConfig.sInput.maxFrames = 3;                  % Maximal number of frames (for runtime considerations)
sConfig.sInput.isGray =    true;                % Use grayscale video or RGB

assert(sConfig.sInput.isGray, "TODO: TEMP! implement solution for RGB by working on luminance space");

%% Noise types:
sConfig.sNoise.isPoiss = false;                 % Add Poisson noise or not
sConfig.sNoise.sigma =   20;                    % Gaussian noise STD (in [0,255] scale)
sConfig.sNoise.snp =     0.00;                  % Salt & pepper noise density

%% Block matching params:
% TODO: set params
sConfig.sBlockMatching.refStride =         7;    % Stride between reference pathces
sConfig.sBlockMatching.patchSize =         8;    % Patch size
sConfig.sBlockMatching.maxNeighborsFrame = 70;   % Maximal number of nearest neighbors per frame
sConfig.sBlockMatching.maxGroupSize =      70;   % Maximal group size (number of patches) per reference patch
sConfig.sBlockMatching.searchWindowNP =    30;   % Non-predictive search window
sConfig.sBlockMatching.searchStrideNP =    2;    % Non-predictive stride between search patches
sConfig.sBlockMatching.searchWindowP =     3;    % Predictive search window.
sConfig.sBlockMatching.searchStrideP =     3;    % Predictive stride between search patches
sConfig.sBlockMatching.metric =            'l2'; % Metric of distance between blocks ('l1' or 'l2')
sConfig.sBlockMatching.distTh =            50;   % Threshold for maximal distance between grouped patches

assert(sConfig.sBlockMatching.refStride <= sConfig.sBlockMatching.patchSize, ...
    "Stride must by smaller or equal to Patch Size in order to cover the entire image");

%% Other algorithm params:
% TODO: set params
sConfig.sWNNM.nIter =        4;       % Number of WNNM iterations
sConfig.sWNNM.nFrameIter =   5;       % Maximal number of iterations on different reference frame
sConfig.sWNNM.maxUngrouped = 0.2;     % Maximal allowed percentage of ungrouped pixels to finish algorithm
sConfig.sWNNM.delta =        0.1;     % Iterative regularization parameter
sConfig.sWNNM.C =            sqrt(2); % Weight constant
sConfig.sWNNM.BMIter =       2;       % Number of iterations between re-block-matching
sConfig.sWNNM.lambda =       0.54;    % Noise estimate parameter

%% Debug params
sConfig.sDB.profiler =       true;    % Print timing of selected logics
end