function mDenoised = PreprocessFrame(mNoised)
% --------------------------------------------------------------------------------------------------------- %
% Simple denoiser a single image by median filtering -> gaussian filtering.
%
% Input:
%   mNoised - Noised image. [h, w]
%
% Output:
%   mDenoised - Denoised image. [h, w]
% --------------------------------------------------------------------------------------------------------- %

mDenoised = imgaussfilt(medfilt2(mNoised));

end
