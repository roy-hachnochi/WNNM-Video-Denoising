function sConfig = GetConfig()
% --------------------------------------------------------------------------------------------------------- %
% Defines parameters configuration for using and reproducing WNNVD results.
% --------------------------------------------------------------------------------------------------------- %

%% Test video:
sConfig.sInput.videoPath = 'xylophone.mp4';     % Video path for testing
sConfig.sInput.isGray =     true;               % Use grayscale video or RGB

assert(sConfig.sInput.isGray, "TODO: TEMP! implement solution for RGB by working on luminance space");

%% Noise types:
sConfig.sNoise.isPoiss = false;                 % Add Poisson noise or not
sConfig.sNoise.sigma =   20;                    % Gaussian noise STD (in [0,255] scale)
sConfig.sNoise.snp =     0.00;                  % Salt & pepper noise density

%% Block matching params:
% TODO: set params
sConfig.sBlockMatching.refStride =         7;    % stride between reference pathces
sConfig.sBlockMatching.patchSize =         8;    % patch size
sConfig.sBlockMatching.maxNeighborsFrame = 10;   % maximal number of nearest neighbors per frame
sConfig.sBlockMatching.maxGroupSize =      64;   % maximal group size (number of patches) per reference patch
sConfig.sBlockMatching.searchWindowNP =    16;   % non-predictive search window
sConfig.sBlockMatching.searchStrideNP =    2;    % non-predictive stride between search patches
sConfig.sBlockMatching.searchWindowP =     4;    % predictive search window
sConfig.sBlockMatching.searchStrideP =     1;    % predictive stride between search patches
sConfig.sBlockMatching.metric =            'l2'; % metric of distance between blocks ('l1' or 'l2')
sConfig.sBlockMatching.distTh =            10;   % threshold for maximal distance between grouped patches

assert(sConfig.sBlockMatching.refStride < sConfig.sBlockMatching.patchSize, ...
    "Step must by smaller than Patch Size in order to cover the entire image");

%% Other algorithm params:
% TODO: set params
sConfig.sWNNM.nIter =  8;       % number of WNNM iterations
sConfig.sWNNM.delta =  0.1;     % iterative regularization parameter
sConfig.sWNNM.C =      sqrt(2); % weight constant
sConfig.sWNNM.BMIter = 2;       % number of iterations between re-block-matching
sConfig.sWNNM.lambda = 0.54;    % noise estimate parameter

end