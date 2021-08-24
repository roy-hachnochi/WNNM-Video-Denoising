% ========================================================================================================= %
% Plot an example of Block Matching between neighboring frames
% ========================================================================================================= %

%% Parameters:
vidInPath =       'Videos/gstennis.avi';
refFrame =        3;
refPatchTestInd = 327;
FACE_ALPHA =      0.3;
nPatchesToPlot =  7;
nFramesToPlot =   4;
noiseSigma =      20;

%% Initializations:
sConfig = GetConfig();
sConfig.sVidProperties.maxFrames = refFrame + nFramesToPlot;
sConfig.sNoise.sigma = noiseSigma;
mX = LoadVideo(vidInPath, sConfig.sVidProperties);
mX = VideoNoise(mX, sConfig.sNoise);
mX = single(squeeze(mX(:,:,1,:)));
[h, w, ~] = size(mX);

mP =  sConfig.sBlockMatching.searchWindowP;
mNP = sConfig.sBlockMatching.searchWindowNP;
p =   sConfig.sBlockMatching.patchSize;

%% Run Block Matching:
mXorig = mX;
mPreDenoised = zeros(size(mX));
for frame = 1:sConfig.sVidProperties.maxFrames
    mX(:,:,frame) = PreprocessFrame(mX(:,:,frame));
end
mSkip = false([h, w]);
mRefPatchInds = GetRefPatchInds(h, w, mSkip, sConfig);
[mGroupIndices, vNumNeighbors] = BlockMatching(mX, mRefPatchInds(refPatchTestInd, :), refFrame, sConfig);

%% Plot results:
% Display matched patches for same reference frame, and show histogram of patches per frames:
figure;
subplot(1,nFramesToPlot,1);
imshow(uint8(mX(:,:,refFrame)));   hold on;
% plot search window:
rectangle('Position', [mRefPatchInds(refPatchTestInd, 2) - mNP, mRefPatchInds(refPatchTestInd, 1) - mNP,...
                 p + 2*mNP, p + 2*mNP], 'EdgeColor', 'g', 'FaceColor', [0, 1, 0, FACE_ALPHA]);
% plot matched patches:
for iPatch = 2:vNumNeighbors(1)
    if (mGroupIndices(1, iPatch, 3) == refFrame) % display only current frame's patches
        rectangle('Position', [mGroupIndices(1, iPatch, 2), mGroupIndices(1, iPatch, 1), p, p],...
                 'EdgeColor', 'c', 'FaceColor', [0, 1, 1, FACE_ALPHA]);
    end
end
% plot reference patch:
rectangle('Position', [mRefPatchInds(refPatchTestInd, 2), mRefPatchInds(refPatchTestInd, 1), p, p],...
                 'EdgeColor', 'r', 'FaceColor', [1, 0, 0, FACE_ALPHA]);
title(['Frame #',num2str(refFrame)]);

for iframe = 1:(nFramesToPlot-1)
    curFrame = refFrame + iframe;
    subplot(1,nFramesToPlot,iframe+1);
    imshow(uint8(mX(:,:,curFrame)));   hold on;
    
    % plot previous matched patches and search windows:
    for iPatch = 1:vNumNeighbors(1)
        if (mGroupIndices(1, iPatch, 3) == curFrame-1)
            rectangle('Position', [mGroupIndices(1, iPatch, 2) - mP, mGroupIndices(1, iPatch, 1) - mP,...
                 p + 2*mP, p + 2*mP], 'EdgeColor', 'g', 'FaceColor', [0, 1, 0, FACE_ALPHA]);
            plot(mGroupIndices(1, iPatch, 2) + round(p/2), mGroupIndices(1, iPatch, 1) + round(p/2), 'r*');
        end
    end
    
    % plot matched patches:
    for iPatch = 1:vNumNeighbors(1)
        if (mGroupIndices(1, iPatch, 3) == curFrame)
            rectangle('Position', [mGroupIndices(1, iPatch, 2), mGroupIndices(1, iPatch, 1), p, p],...
                     'EdgeColor', 'c', 'FaceColor', [0, 1, 1, FACE_ALPHA]);
        end
    end
    
    title(['Frame #',num2str(curFrame)]);
end
sgtitle(["# of Ref Patches: ",num2str(size(mRefPatchInds,1))])
linkaxes;
