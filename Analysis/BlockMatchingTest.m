% Test for BlockMatching function:

%% Parameters:
refFrame =        2;
refPatchTestInd = 238;
FACE_ALPHA =      0.3;
nPatchesToPlot =  15;
maxFrames =       3;

%% Initializations:
sConfig = GetConfig();
sConfig.sTest.maxFrames = maxFrames;
p = sConfig.sBlockMatching.patchSize;
mX = VideoLoad(sConfig.sTest);
mX = single(squeeze(mX(:,:,1,:)));
[h, w, ~] = size(mX);

%% Run BlockMatching:
mSkip = false([h, w]);
mRefPatchInds = GetRefPatchInds(h, w, mSkip, sConfig);
[mGroupIndices, vNumNeighbors] = BlockMatching(mX, mRefPatchInds(refPatchTestInd, :), refFrame, sConfig);

%% Plot results:
% Display matched patches for same reference frame, and show histogram of patches per frames:
figure;
subplot(1,2,1);
imshow(uint8(mX(:,:,refFrame)));   hold on;
for iPatch = 1:size(mGroupIndices, 2)
    if (mGroupIndices(1, iPatch, 3) == refFrame) % display only current frame's patches
        rectangle('Position', [mGroupIndices(1, iPatch, 2), mGroupIndices(1, iPatch, 1), p, p],...
                 'EdgeColor', 'c', 'FaceColor', [0, 1, 1, FACE_ALPHA]);
    end
end
rectangle('Position', [mRefPatchInds(refPatchTestInd, 2), mRefPatchInds(refPatchTestInd, 1), p, p],...
                 'EdgeColor', 'r', 'FaceColor', [1, 0, 0, FACE_ALPHA]);
title('Matched Patches in Single Frame');

subplot(1,2,2);
histogram(mGroupIndices(1,:,3), 1:(size(mX,3)+1));  grid on;
xlabel('frame');    ylabel('# patches');
title(['Number of Matched Patches Per Frame',newline,'Reference Frame: ',num2str(refFrame)]);

% Plot the patches themselves:
figure;
for iPatch = 1:nPatchesToPlot
    row =   mGroupIndices(1, iPatch, 1);
    col =   mGroupIndices(1, iPatch, 2);
    frame = mGroupIndices(1, iPatch, 3);
    subplot(ceil(nPatchesToPlot/5), 5, iPatch);
    imshow(uint8(mX(row + (0:(p-1)), col + (0:(p-1)), frame)));
end
