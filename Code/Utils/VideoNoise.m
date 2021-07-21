function mNoised = VideoNoise(mFrames, sNoiseConfig)
% --------------------------------------------------------------------------------------------------------- %
% Adds noise to video.
% Available noise types are: Gaussian, Poisson, Salt & Pepper.
%
% Input:
%   mFrames -      4D array of frames. [h, w, ch, f]
%   sNoiseConfig - Noise configuration parameters.
%
% Output:
%   mNoised - 4D array of noised frames. [h, w, ch, f]
% --------------------------------------------------------------------------------------------------------- %

if sNoiseConfig.isPoiss
    mFrames = min(1, max(0, poissrnd(round(mFrames*255))/255));
end
mNoised = imnoise(mFrames, 'gaussian', 0, (sNoiseConfig.sigma/255)^2);
mNoised = imnoise(mNoised, 'salt & pepper', sNoiseConfig.snp);

end