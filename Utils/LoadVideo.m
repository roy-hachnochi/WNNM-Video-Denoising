function [mFrames, frameRate] = LoadVideo(vidPath, sVidProperties)
% --------------------------------------------------------------------------------------------------------- %
% Loads video frames.
%
% Input:
%   vidPath -        Video input path.
%   sVidProperties - Struct containing input video properties.
%
% Output:
%   mFrames -   4D array of frames (UINT8). [h, w, ch, f]
%   frameRate - Frame rate of video.
% --------------------------------------------------------------------------------------------------------- %

strArr = split(vidPath, '.');
if strcmpi(strArr{end}, 'png') || strcmpi(strArr{end}, 'jpg') || strcmpi(strArr{end}, 'jpeg')
    % video is actually an image
    mOrigFrames = imread(vidPath);
    frameRate = 1;
else
    vidObj = VideoReader(vidPath);
    mOrigFrames = read(vidObj);
    frameRate = vidObj.FrameRate;
end

[h, w, chOrig, f] = size(mOrigFrames);
if sVidProperties.isGray
    ch = 1;
end

mFrames = zeros([h, w, ch, min(f, sVidProperties.maxFrames)], 'uint8');
for ind = 1:min(f, sVidProperties.maxFrames)
    if sVidProperties.isGray && chOrig ~= 1
        mFrames(:,:,1,ind) = rgb2gray(mOrigFrames(:,:,:,ind));
    else
        mFrames(:,:,:,ind) = mOrigFrames(:,:,:,ind);
    end
end

end
