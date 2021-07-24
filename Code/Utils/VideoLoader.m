function mFrames = VideoLoader(sInputConfig)
% --------------------------------------------------------------------------------------------------------- %
% Loads video frames and converts to single format.
%
% Input:
%   sInputConfig - Struct containing:
%       path -   video path to load.
%       isGray - convert to grayscale.
%
% Output:
%   mFrames - 4D array of frames. [h, w, ch, f]
% --------------------------------------------------------------------------------------------------------- %

vidObj = VideoReader(sInputConfig.videoPath);
mOrigFrames = read(vidObj);
[h, w, ch, f] = size(mOrigFrames);
if sInputConfig.isGray
    ch = 1;
end

mFrames = zeros([h, w, ch, f], 'single');
for ind = 1:min(f, sInputConfig.maxFrames)
    if sInputConfig.isGray
        mFrames(:,:,1,ind) = single(rgb2gray(mOrigFrames(:,:,:,ind)))/255;
    else
        mFrames(:,:,:,ind) = im2single(mOrigFrames(:,:,:,ind));
    end
end

end
