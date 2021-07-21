function mY = WNNVD(mX, sConfig)
% --------------------------------------------------------------------------------------------------------- %
% Weighted Nuclear Norm Video Denoiser.
%
% Input:
%   mX -      4D array of noised video frames. [h, w, f]
%   sConfig - Struct containing all parameters for algorithm.
%
% Output:
%   mY - 4D array of denoised video frames. [h, w, f]
% --------------------------------------------------------------------------------------------------------- %

% TODO: for patch extraction, decide between the following options:
% 1) Extract patches in advance. Pros: everything is prepared, much more convinient, less calculations,
%                                      allows us to perform block matching not every iteration.
%                                Cons: space consuming - saving many overlapping segments of video.
% 2) Extract patches during alg. Pros: no memory required.
%                                Cons: Less convinient to handle, many repeating calculations (runtime).

% TODO: decide if we want to process frame-by-frame (high computational cost) or make it smarter and process
% patches based on a single frame, hold an array telling us which pixels have been processed, and then
% process again based on patches containing the pixels which weren't processed...

% TODO: how can we save time by performing block matching not every iteration, but every X iterations?

end