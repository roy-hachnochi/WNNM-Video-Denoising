function [sLog] = UpdateLog(sLog, refFrame, processed, vNPatchesPerFrame, itTime)
% --------------------------------------------------------------------------------------------------------- %
% Updates log struct with current iteration statistics.
%
% Input:
%   sLog -              Log struct with run statistics.
%   refFrame -          Chosen reference frame.
%   processed -         Proportion of done pixels.
%   vNPatchesPerFrame - Number of chosen patches per frame.
%   itTime -            Iteration time.
%
% Output:
%   sLog - Log struct with run statistics.
% --------------------------------------------------------------------------------------------------------- %

it = sLog.nIt + 1;

sLog.nIt =                      it;
sLog.vChosenFrames(it) =        refFrame;
sLog.vProcessed(it) =           processed;
sLog.vTime(it) =                itTime;
sLog.mNPatchesPerFrame(it, :) = vNPatchesPerFrame(:).';

end
