function [mGroupIndices, vNumNeighbors] = BlockMatching(mX, mRefPatchInds, refFrame, sConfig, isWaitbar)
% --------------------------------------------------------------------------------------------------------- %
% Performs block matching per reference patch - find nearest (most similar) patches to each reference patches
% in entire video.
%
% Input:
%   mX -            3D array of video frames. [h, w, f]
%   mRefPatchInds - 2D array containing upper-left indices of reference patches. [N, 2]
%   refFrame -      Reference frame number for key-patches.
%   sConfig -       Struct containing all parameters for algorithm.
%   isWaitbar -     (optional) Display waitbar (default: false).
%
% Output:
%   mGroupIndices - 3D array containing upper-left indices of patches in group per reference patch. [N, K, 3]
%   vNumNeighbors - Array containing number of effective neighbors per reference patch. [N, 1]
% --------------------------------------------------------------------------------------------------------- %

if ~exist('isWaitbar', 'var') || isempty(isWaitbar)
    isWaitbar = false;
end

[~, ~, f] = size(mX);

k = sConfig.sBlockMatching.maxNeighborsFrame;
K = sConfig.sBlockMatching.maxGroupSize;

NRefPatches =   size(mRefPatchInds, 1);
mGroupIndices = zeros(NRefPatches, K, 3);
vNumNeighbors = zeros(NRefPatches, 1);

if isWaitbar
    wb = waitbar(0, 'Performing Block-Matching');
end
for iRef = 1:NRefPatches
    %% Find nearest patches per frame
    mSearchPatchInds =  zeros(f*k, 3); % indices of most similar patches per frame
    vSearchPatchDists = zeros(f*k, 1); % distances of most similar patches per frame
    
    vRefPatchInds = [mRefPatchInds(iRef, :), refFrame]; % include frame
    ind = 0;
    
%     if iRef == 1 || iRef == NRefPatches % Profiler
%         npStamp = ProfilerStartRecord(sConfig);
%     end   
    % Non-predictive (exhaustive) block matching for first frame:
    [mFirstInds, vFirstDists] = BlockMatchingNonPred(mX, vRefPatchInds, sConfig);
    mSearchPatchInds(ind*k + (1:k), :) = mFirstInds;
    vSearchPatchDists(ind*k + (1:k)) =   vFirstDists;
%     if iRef == 1 || iRef == NRefPatches % Profiler
%         ProfilerEndRecord(npStamp, "Non-Predictive-Search", iRef, sConfig);
%     end

%     if iRef == 1 || iRef == NRefPatches % Profiler
%         pStamp = ProfilerStartRecord(sConfig);
%     end   
    % Forward predictive block matching:
    mCurPatchInds = mFirstInds;
    for iFrame = refFrame+1:f
        ind = ind + 1;
        [mCurPatchInds, vCurPatchDists] = BlockMatchingPred(mX, vRefPatchInds, mCurPatchInds, iFrame, sConfig);
        mSearchPatchInds(ind*k + (1:k), :) = mCurPatchInds;
        vSearchPatchDists(ind*k + (1:k)) =   vCurPatchDists;
    end
    
    % Backward predictive block matching:
    mCurPatchInds = mFirstInds;
    for iFrame = refFrame-1:-1:1
        ind = ind + 1;
        [mCurPatchInds, vCurPatchDists] = BlockMatchingPred(mX, vRefPatchInds, mCurPatchInds, iFrame, sConfig);
        mSearchPatchInds(ind*k + (1:k), :) = mCurPatchInds;
        vSearchPatchDists(ind*k + (1:k)) =   vCurPatchDists;
    end
%     if iRef == 1 || iRef == NRefPatches % Profiler
%         ProfilerEndRecord(pStamp, "Predictive-Search", iRef, sConfig);
%     end    
    %% Find nearest patches from entire patch array:
    [vNearestDists, vNearestInds] = mink(vSearchPatchDists, K);
    mGroupIndices(iRef, 1:min(K,f*k), :) = mSearchPatchInds(vNearestInds, :);
    vNumNeighbors(iRef) =         sum(vNearestDists <= sConfig.sBlockMatching.distTh);
    
    if isWaitbar && (mod(iRef - 1, 20) == 0)
        waitbar(iRef/NRefPatches, wb);
    end
end
if isWaitbar
    close(wb);
end

end

%% ==========================================================================================================
function [mNearestInds, vNearestDists] = BlockMatchingNonPred(mX, vRefPatchInds, sConfig)
% --------------------------------------------------------------------------------------------------------- %
% Performs non-predictive (exhaustive) block matching in a single frame. Finds nearest patches to reference
% patch.
%
% Input:
%   mX -            3D array of video frames. [h, w, f]
%   vRefPatchInds - Array containing upper-left indices of reference patch. [3, 1]
%   sConfig -       Struct containing all parameters for algorithm.
%
% Output:
%   mNearestInds -  2D array containing upper-left indices of nearest patches. [k, 3]
%   vNearestDists - Array distances of nearest patches from reference patch. [k, 1]
% --------------------------------------------------------------------------------------------------------- %

[h, w, ~] = size(mX);

k = sConfig.sBlockMatching.maxNeighborsFrame;
m = sConfig.sBlockMatching.searchWindowNP;
s = sConfig.sBlockMatching.searchStrideNP;
p = sConfig.sBlockMatching.patchSize;

% extract reference patch:
refRow =   vRefPatchInds(1);
refCol =   vRefPatchInds(2);
refFrame = vRefPatchInds(3);

mRefPatch = mX(refRow + (0:p-1), refCol + (0:p-1), refFrame);
mRefPatch = reshape(mRefPatch,[1 size(mRefPatch)]);

mSinglePatchInd = (0:p-1)' + (0:h:h*(p-1)); % relative indices to the top-left corner for any patch in the frame
mSinglePatchInd = reshape(mSinglePatchInd,[1 size(mSinglePatchInd)]); % Adjust for 3-D efficient calculations

% calculate search window:
vStridR = [flip(0:-s:-m), s:s:m];
vStrideC = [flip(0:-s*h:-m*h), s*h:s*h:m*h];

vWinInd = [flip(0:-s:-m), s:s:m]' + [flip(0:-s*h:-m*h), s*h:s*h:m*h]; % index offset for each of the patches in th search window
vWinInd = vWinInd(:); % we dont neet this matrix as 2-D
refIdx = sub2ind([h, w],refRow,refCol);


% handle out-of-boundary cases of the search window by masking patches that out of frame
vMaskRow = (mod(refIdx,h)+vStridR > 0) & (mod(refIdx,h)+vStridR < h-p+1);
vMaskCol = ((refIdx+vStrideC) > 0) & ((refIdx+vStrideC) < (w-p)*h+1); 
mMask = vMaskRow'&vMaskCol;
vWinInd(~mMask(:)) = []; % Avoid using masked patches

vIdx = refIdx+vWinInd;

% find dists: 
mDiffPatches = mX(vIdx+repmat(mSinglePatchInd,[length(vIdx) 1 1])+(refFrame-1)*h*w) - repmat(mRefPatch,[length(vIdx) 1 1]);
vDists = PatchDist(mDiffPatches, sConfig);

% get nearest patches:
[vNearestDists, vNearestInds] = mink(vDists, k);
[vRows,vCols] = ind2sub([h w],vIdx(vNearestInds));
mNearestInds = [vRows, vCols, repmat(refFrame, [k, 1])];

end

%% ==========================================================================================================
function [mNearestInds, vNearestDists] = BlockMatchingPred(mX, vRefPatchInds, mPrevNearestInds, iFrame, sConfig)
% --------------------------------------------------------------------------------------------------------- %
% Performs predictive block matching in a single frame. Finds nearest patches to reference patch.
%
% Input:
%   mX -               3D array of video frames. [h, w, f]
%   vRefPatchInds -    Array containing upper-left indices of reference patch. [3, 1]
%   mPrevNearestInds - 2D array containing upper-left indices of previous frame's nearest patches. [k, 3]
%   iFrame -           Current frame for search.
%   sConfig -          Struct containing all parameters for algorithm.
%
% Output:
%   mNearestInds -  2D array containing upper-left indices of nearest patches. [k, 3]
%   vNearestDists - Array distances of nearest patches from reference patch. [k, 1]
% --------------------------------------------------------------------------------------------------------- %

[h, w, ~] = size(mX);

k = sConfig.sBlockMatching.maxNeighborsFrame;
m = sConfig.sBlockMatching.searchWindowP;
s = sConfig.sBlockMatching.searchStrideP;
p = sConfig.sBlockMatching.patchSize;

% extract reference patch:
refRow =   vRefPatchInds(1);
refCol =   vRefPatchInds(2);
refFrame = vRefPatchInds(3);

mRefPatch = mX(refRow + (0:p-1), refCol + (0:p-1), refFrame);
mRefPatch = reshape(mRefPatch,[1 size(mRefPatch)]);

mSinglePatchInd = (0:p-1)' + (0:h:h*(p-1)); % relative indices to the top-left corner for any patch in the frame
mSinglePatchInd = reshape(mSinglePatchInd,[1 size(mSinglePatchInd)]); % Adjust for 3-D efficient calculations

% calculate search windows:
% indStamp = ProfilerStartRecord(sConfig);
vStrideR = [flip(0:-s:-m), s:s:m];
vStrideC = [flip(0:-s*h:-m*h), s*h:s*h:m*h];

vWinInd = vStrideR' + vStrideC; % index offset for each of the patches in th search window
vWinInd = reshape(vWinInd,1,[]); % vectorize the window for single nearest patches
vWinInd = repmat(vWinInd, [size(mPrevNearestInds,1) 1]); % make 2-D matrix : 1st dim - # patches; 2nd dim - patch size p^2
vWinInd = vWinInd(:); % vectorize the whole struct as it will be masked
vIdx = sub2ind([h, w],mPrevNearestInds(:, 1),mPrevNearestInds(:, 2));

% handle out-of-boundary cases of the search window by masking patches that out of frame
vMaskRow = (mod(vIdx,h)+vStrideR > 0) & (mod(vIdx,h)+vStrideR < h-p);
vMaskCol = ((vIdx+vStrideC) > 0) & ((vIdx+vStrideC) < (w-p)*h); 

mMaskRows = repmat(vMaskRow,[1 1 3]);
mMaskRows = reshape(mMaskRows,size(mMaskRows,1),[]);
mMaskCols = permute(repmat(vMaskCol,[1 1 3]),[1 3 2]);
mMaskCols = reshape(mMaskCols,size(mMaskCols,1),[]);
mMask = mMaskRows & mMaskCols;

vIdx = repmat(vIdx,[1 m^2]);
vIdx = vIdx(:);

vIdx = vIdx+vWinInd;
vIdx(~mMask(:)) = []; % avoid masked patches
vIdx = unique(vIdx);
% % ProfilerEndRecord(indStamp, "Predictive-Ind-Search", sConfig);


% find dists:
% distStamp = ProfilerStartRecord(sConfig);
% Efficient implementation by using Indices instead of subscripts and arrangeing patches in 3-D tensor
mDiffPatches = mX(vIdx+repmat(mSinglePatchInd,[length(vIdx) 1 1])+(iFrame-1)*h*w) - repmat(mRefPatch,[length(vIdx) 1 1]);
vDists = PatchDist(mDiffPatches, sConfig);
% ProfilerEndRecord(distStamp, "Predictive-Dist", sConfig);

% get nearest patches:
% minkStamp = ProfilerStartRecord(sConfig);
[vNearestDists, vNearestInds] = mink(vDists, k);
[vRows,vCols] = ind2sub([h, w],vIdx(vNearestInds));
mNearestInds = [vRows, vCols, repmat(iFrame, [k, 1])];
% ProfilerEndRecord(minkStamp, "Predictive-Mink", sConfig);
end

%% ==========================================================================================================
function d = PatchDist(mDiffPatches, sConfig)
% Inputs is 3-D tensor that contains the differences between suspected 
% patches and thereference patch.
%   - 1st dim is the number of suspected patches
%   - 2nd & 3rd dims are the size of the patches

switch sConfig.sBlockMatching.metric
    case 'l1'
        d = sum(abs(mDiffPatches),[2 3]);
    case 'l2'
        d = sqrt(sum(abs(mDiffPatches).^2,[2 3]));
    otherwise
        error('Metric not defined');
end

end
