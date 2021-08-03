function [mFrames, frameRate] = VideoLoad(sTestConfig)
% --------------------------------------------------------------------------------------------------------- %
% Loads video frames.
%
% Input:
%   sTestConfig - Struct containing input video parameters.
%
% Output:
%   mFrames -   4D array of frames (UINT8). [h, w, ch, f]
%   frameRate - Frame rate of video.
% --------------------------------------------------------------------------------------------------------- %

strArr = split(sTestConfig.vidInPath, '.');
if strcmpi(strArr{end}, 'png') || strcmpi(strArr{end}, 'jpg') || strcmpi(strArr{end}, 'jpeg')
    % video is actually an image
    mOrigFrames = imread(sTestConfig.vidInPath);
    frameRate = 1;
else
    vidObj = VideoReader(sTestConfig.vidInPath);
    mOrigFrames = read(vidObj);
    frameRate = vidObj.FrameRate;
end

[h, w, chOrig, f] = size(mOrigFrames);
if sTestConfig.isGray
    ch = 1;
end

mFrames = zeros([h, w, ch, min(f, sTestConfig.maxFrames)], 'uint8');
for ind = 1:min(f, sTestConfig.maxFrames)
    if sTestConfig.isGray && chOrig ~= 1
        mFrames(:,:,1,ind) = rgb2gray(mOrigFrames(:,:,:,ind));
    else
        mFrames(:,:,:,ind) = mOrigFrames(:,:,:,ind);
    end
end

end
