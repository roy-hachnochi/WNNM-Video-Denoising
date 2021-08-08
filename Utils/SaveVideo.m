function [] = SaveVideo(mFrames, frameRate, vidPath)
% --------------------------------------------------------------------------------------------------------- %
% Saves video/image to file in AVI/specified format.
%
% Input:
%   mFrames -   4D array of frames. [h, w, ch, f]
%   frameRate - Frame rate of video.
%   vidPath -   Video output path.
%
% TODO:
%   1) Make sure that function works also for RGB videos/images.
% --------------------------------------------------------------------------------------------------------- %

warning('off', 'MATLAB:MKDIR:DirectoryExists');

[~, ~, ~, f] = size(mFrames);
vidName = split(vidPath, '.');
vidDir = split(vidName{1}, filesep);
vidDir = join(vidDir(1:end-1), filesep);
mkdir(vidDir{1});

if (f == 1)
    % video is actually an image
    imwrite(mFrames, vidPath);
    return;
end

writer = VideoWriter(vidName{1});
writer.FrameRate = frameRate;

open(writer)
for ind = 1:f
    writeVideo(writer, mFrames(:,:,:,ind))
end
close(writer)

end
