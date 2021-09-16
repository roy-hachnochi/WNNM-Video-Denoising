function sConfig = GetConfig()
% --------------------------------------------------------------------------------------------------------- %
% Defines parameters configuration for using and reproducing WNNVD results.
% --------------------------------------------------------------------------------------------------------- %

%% Input video properties:
sConfig.sVidProperties.maxFrames = 20;   % Maximal number of frames (to reduce runtime)
sConfig.sVidProperties.isGray =    true; % Use grayscale video or RGB

assert(sConfig.sVidProperties.isGray, "TODO: TEMP! implement solution for RGB");

%% Noise types:
sConfig.sNoise.isPoiss = false; % Add Poisson noise or not
sConfig.sNoise.sigma =   20;   	% Gaussian noise STD (in [0,255] scale)
sConfig.sNoise.snp =     0; 	% Salt & pepper noise density

%% Block matching params
sConfig.sBlockMatching.refStride =         2;2;    % Stride between reference pathces
sConfig.sBlockMatching.patchSize =         8;    % Patch size
sConfig.sBlockMatching.maxNeighborsFrame = 20;70;   % Maximal number of nearest neighbors per frame
sConfig.sBlockMatching.maxGroupSize =      150;70;  % Maximal group size (number of patches) per reference patch
sConfig.sBlockMatching.searchWindowNP =    30;   % Non-predictive search window
sConfig.sBlockMatching.searchStrideNP =    2;1;    % Non-predictive stride between search patches
sConfig.sBlockMatching.searchWindowP =     5;    % Predictive search window
sConfig.sBlockMatching.searchStrideP =     1;    % Predictive stride between search patches
sConfig.sBlockMatching.searchWindowT =     4;    % Temporal search window (frames)
sConfig.sBlockMatching.metric =            'l2'; % Metric of distance between blocks ('l1' or 'l2')
sConfig.sBlockMatching.distTh =            30;   % Threshold for maximal distance between grouped patches
sConfig.sBlockMatching.trajectoryFlag =    false; % If True, the BM algorithm replaced by trajectory matching 

assert(sConfig.sBlockMatching.refStride <= sConfig.sBlockMatching.patchSize, ...
    "Stride must by smaller or equal to Patch Size in order to cover the entire image");
if (sConfig.sBlockMatching.maxNeighborsFrame*(sConfig.sBlockMatching.searchWindowT*2 + 1) < ...
        sConfig.sBlockMatching.maxGroupSize)
    warning("maxGroupSize can't be reached with this configuration of searchWindowT and maxNeighborsFrame");
end

%% Other algorithm params:
sConfig.sWNNM.nIter =          8;12;         % Number of WNNM iterations
sConfig.sWNNM.nFrameIter =     50;        % Maximal number of iterations on different reference frame
sConfig.sWNNM.maxUngrouped =   0.5;       % Maximal allowed % of ungrouped pixels per frame to end algorithm
sConfig.sWNNM.delta =          0.1;       % Iterative regularization parameter
sConfig.sWNNM.C =              2*sqrt(2); % Weight constant
sConfig.sWNNM.BMIter =         4; 6;        % Number of iterations between re-block-matching
sConfig.sWNNM.lambda =         0.54;      % Noise estimate parameter
sConfig.sWNNM.minIterForSkip = 8; 12;        % Minimal number of iterations on pixel to consider it as denoised

%% Competability to the extension of the algorithm - trajectory matching
sConfig.sBlockMatching.maxNeighborsFrameP =  sConfig.sBlockMatching.maxNeighborsFrame;   % Maximal number of nearest neighbors per frame for predictive search
sConfig.sBlockMatching.maxNeighborsFrameNP = sConfig.sBlockMatching.maxNeighborsFrame;   % Maximal number of nearest neighbors per frame for predictive search
end
