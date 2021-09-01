% ========================================================================================================= %
% Test for BlockMatching function
% ========================================================================================================= %

rng(42);

%% Parameters:
vidInPath =       fullfile('Videos','gstennis.avi');
outFolder =       fullfile('Analysis','Figures');
refFrame =        11;
refPatchTestInd = 1553;
FACE_ALPHA =      0.3;
nPatchesToPlot =  7;
maxFrames =       20;
frameToPlot =     10;
noiseSigma =      20;
b_saveFig =       true;

%% Initializations:
sConfig = GetConfig();
sConfig.sVidProperties.maxFrames = maxFrames;
sConfig.sNoise.sigma = noiseSigma;
p = sConfig.sBlockMatching.patchSize;
mX = LoadVideo(vidInPath, sConfig.sVidProperties);
mX = VideoNoise(mX, sConfig.sNoise);
mX = single(squeeze(mX(:,:,1,:)));
[h, w, f] = size(mX);

%% Run BlockMatching:
for frame = 1:f
    mX(:,:,frame) = PreprocessFrame(mX(:,:,frame));
end
mSkip = false([h, w]);
mRefPatchInds = GetRefPatchInds(h, w, mSkip, sConfig);
[mGroupIndices, vNumNeighbors] = BlockMatching(mX, mRefPatchInds(refPatchTestInd, :), refFrame, sConfig);

%% Plot results:
% Display matched patches for same reference frame, and show histogram of patches per frames:
figure('units','normalized','outerposition',[0 0 1 1]);
subplot(1,2,1);
imshow(uint8(mX(:,:,frameToPlot)));   hold on;
for iPatch = 1:vNumNeighbors(1)
    if (mGroupIndices(1, iPatch, 3) == frameToPlot) % display only current frame's patches
        rectangle('Position', [mGroupIndices(1, iPatch, 2), mGroupIndices(1, iPatch, 1), p, p],...
                 'EdgeColor', 'c', 'FaceColor', [0, 1, 1, FACE_ALPHA]);
    end
end
rectangle('Position', [mRefPatchInds(refPatchTestInd, 2), mRefPatchInds(refPatchTestInd, 1), p, p],...
                 'EdgeColor', 'r', 'FaceColor', [1, 0, 0, FACE_ALPHA]);
title('Matched Patches in Single Frame');

subplot(1,2,2);
histogram(mGroupIndices(1,1:vNumNeighbors(1),3), 1:(size(mX,3)+1));  grid on;
xlabel('frame');    ylabel('# patches');
title(['Number of Matched Patches Per Frame',newline,'Reference Frame: ',num2str(refFrame),newline,...
    'Total number of matched patches: ',num2str(vNumNeighbors(1))]);

if b_saveFig
    saveas(gcf, fullfile(outFolder,'BMTest_frame.png'));
end

% Plot the patches themselves:
figure('units','normalized','outerposition',[0 0 1 1]);
subplot(3, nPatchesToPlot, ceil(nPatchesToPlot/2));
refRow =   mGroupIndices(1, 1, 1);
refCol =   mGroupIndices(1, 1, 2);
refFrame = mGroupIndices(1, 1, 3);
mRefPatch = mX(refRow + (0:(p-1)), refCol + (0:(p-1)), refFrame);
imshow(uint8(mRefPatch));
title('Reference Frame');
for iPlot = 1:2*nPatchesToPlot
    if iPlot <= nPatchesToPlot % show nearest patches
        iPatch = iPlot + 1;
        sTitle = 'Nearest Frames in Group';
    else % show furthest patches
        iPatch = vNumNeighbors(1) - (nPatchesToPlot*2 - iPlot);
        sTitle = 'Furthest Frames in Group';
    end
    if (iPatch <= 1) || (iPatch > vNumNeighbors(1))
        continue;
    end
    row =   mGroupIndices(1, iPatch, 1);
    col =   mGroupIndices(1, iPatch, 2);
    frame = mGroupIndices(1, iPatch, 3);
    subplot(3, nPatchesToPlot, nPatchesToPlot + iPlot);
    mPatch = mX(row + (0:(p-1)), col + (0:(p-1)), frame);
    dist = PatchesNorm(reshape(mPatch - mRefPatch, [1, p, p]), sConfig);
    imshow(uint8(mPatch));
    if (mod(iPlot, nPatchesToPlot) == ceil(nPatchesToPlot/2))
        title([sTitle,newline,sprintf('d = %.2f',dist)]);
    else
        title(sprintf('d = %.2f',dist));
    end
end
if b_saveFig
    saveas(gcf, fullfile(outFolder,'BMTest_patches.png'));
end


%% ==========================================================================================================
function d = PatchesNorm(mDiffPatches, sConfig)

switch sConfig.sBlockMatching.metric
    case 'l1'
        d = mean(abs(mDiffPatches), [2, 3]);
    case 'l2'
        d = sqrt(mean(abs(mDiffPatches).^2, [2, 3]));
    otherwise
        error('Metric not defined');
end

end
