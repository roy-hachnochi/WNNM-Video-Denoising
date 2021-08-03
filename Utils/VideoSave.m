function [] = VideoSave(mFrames, frameRate, sTestConfig)
% --------------------------------------------------------------------------------------------------------- %
% Saves video/image to file in AVI/specified format.
%
% Input:
%   mFrames -     4D array of frames. [h, w, ch, f]
%   frameRate -   Frame rate of video.
%   sTestConfig - Struct containing output video parameters.
% --------------------------------------------------------------------------------------------------------- %

warning('off', 'MATLAB:MKDIR:DirectoryExists');

% TODO: check if also works for RGB

[~, ~, ~, f] = size(mFrames);
vidPath = split(sTestConfig.vidOutPath, '.');
vidDir = split(vidPath{1}, '/');
mkdir(join(vidDir{1:end-1}, '/'));

if (f == 1)
    % video is actually an image
    imwrite(mFrames, sTestConfig.vidOutPath);
    return;
end

writer = VideoWriter(vidPath{1});
writer.FrameRate = frameRate;

open(writer)
for ind = 1:f
    writeVideo(writer, mFrames(:,:,:,ind))
end
close(writer)

end
