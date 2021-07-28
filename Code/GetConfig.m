function sConfig = GetConfig()
% --------------------------------------------------------------------------------------------------------- %
% Defines parameters configuration for using and reproducing WNNVD results.
% --------------------------------------------------------------------------------------------------------- %

%% Test video:
sConfig.sInput.videoPath = 'xylophone.mp4';     % Video path for testing
sConfig.sInput.maxFrames = 10;                  % Maximal number of frames (for runtime considerations)
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
sConfig.sBlockMatching.maxNeighborsFrame = 10;   % Maximal number of nearest neighbors per frame
sConfig.sBlockMatching.maxGroupSize =      64;   % Maximal group size (number of patches) per reference patch
sConfig.sBlockMatching.searchWindowNP =    16;   % Non-predictive search window
sConfig.sBlockMatching.searchStrideNP =    2;    % Non-predictive stride between search patches
sConfig.sBlockMatching.searchWindowP =     4;    % Predictive search window
sConfig.sBlockMatching.searchStrideP =     1;    % Predictive stride between search patches
sConfig.sBlockMatching.metric =            'l2'; % Metric of distance between blocks ('l1' or 'l2')
sConfig.sBlockMatching.distTh =            10;   % Threshold for maximal distance between grouped patches

assert(sConfig.sBlockMatching.refStride < sConfig.sBlockMatching.patchSize, ...
    "Step must by smaller than Patch Size in order to cover the entire image");

%% Other algorithm params:
% TODO: set params
sConfig.sWNNM.nIter =  8;       % Number of WNNM iterations
sConfig.sWNNM.delta =  0.1;     % Iterative regularization parameter
sConfig.sWNNM.C =      sqrt(2); % Weight constant
sConfig.sWNNM.BMIter = 2;       % Number of iterations between re-block-matching
sConfig.sWNNM.lambda = 0.54;    % Noise estimate parameter

end