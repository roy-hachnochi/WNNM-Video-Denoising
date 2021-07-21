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
% TODO: rename, organize, edit documentation, set, and add more if needed
sConfig.sBlockMatching.SearchWin =   30;                                   % Non-local patch searching window
sConfig.sBlockMatching.delta     =   0.1;                                  % Parameter between each iter
sConfig.sBlockMatching.c         =   sqrt(2);                              % Constant num for the weight vector
sConfig.sBlockMatching.Innerloop =   2;                                    % InnerLoop Num of between re-blockmatching
sConfig.sBlockMatching.ReWeiIter =   3;
sConfig.sBlockMatching.patchSize =   6;                            % Patch size
sConfig.sBlockMatching.patnum        =   70;                           % Initial Non-local Patch number
sConfig.sBlockMatching.Iter          =   8;                            % total iter numbers
sConfig.sBlockMatching.lamada        =   0.54;                         % Noise estimete parameter
sConfig.sBlockMatching.step      =   floor(sConfig.sBlockMatching.patchSize - 1); 

assert(sConfig.sBlockMatching.step < sConfig.sBlockMatching.patchSize, ...
    "Step must by smaller than Patch Size in order to cover the entire image");

%% Other algorithm params:
sConfig.sWNNM.k = 0;

end