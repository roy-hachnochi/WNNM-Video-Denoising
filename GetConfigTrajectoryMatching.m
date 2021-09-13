function sConfig = GetConfigTrajectoryMatching()
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

%% Block matching params:
sConfig.sBlockMatching.refStride =           1;    % Stride between reference pathces
sConfig.sBlockMatching.patchSize =           5;    % Patch size

% Used for block matching:
sConfig.sBlockMatching.maxNeighborsFrameP =  1;   % Maximal number of nearest neighbors per frame for predictive search
sConfig.sBlockMatching.maxNeighborsFrameNP = 120;   % Maximal number of nearest neighbors per frame for predictive search
sConfig.sBlockMatching.maxGroupSize =        120;  % Maximal group size (number of patches) per reference patch
sConfig.sBlockMatching.searchWindowNP =      18;   % Non-predictive search window
sConfig.sBlockMatching.searchStrideNP =      1;    % Non-predictive stride between search patches
sConfig.sBlockMatching.searchWindowP =       5;    % Predictive search window
sConfig.sBlockMatching.searchStrideP =       1;    % Predictive stride between search patches
sConfig.sBlockMatching.searchWindowT =       3;   % Temporal search window (frames)
sConfig.sBlockMatching.metric =              'l2'; % Metric of distance between blocks ('l1' or 'l2')
sConfig.sBlockMatching.distTh =              35;   % Threshold for maximal distance between grouped patches
sConfig.sBlockMatching.trajectoryFlag =      true; % If True, the BM algorithm replaced by trajectory matching 

% assert(sConfig.sBlockMatching.refStride <= sConfig.sBlockMatching.patchSize, ...
%     "Stride must by smaller or equal to Patch Size in order to cover the entire image");

%% Other algorithm params:
sConfig.sWNNM.nIter =          8;         % Number of WNNM iterations
sConfig.sWNNM.nFrameIter =     50;        % Maximal number of iterations on different reference frame
sConfig.sWNNM.maxUngrouped =   0.2;       % Maximal allowed percentage of ungrouped pixels to end algorithm
sConfig.sWNNM.delta =          0.1;       % Iterative regularization parameter
sConfig.sWNNM.C =              2*sqrt(2); % Weight constant
sConfig.sWNNM.BMIter =         4;        % Number of iterations between re-block-matching
sConfig.sWNNM.lambda =         0.54;      % Noise estimate parameter
sConfig.sWNNM.minIterForSkip = 8;         % Minimal number of iterations on pixel to consider it as denoised

%% Competability with Original implementation
sConfig.sBlockMatching.maxNeighborsFrame =   sConfig.sBlockMatching.maxNeighborsFrameNP;   % Maximal number of nearest neighbors per frame for predictive search% Used for trajectory matching:

end
