function [] = ProfilerEndRecord(startRecord, msg, msgIdx, sConfig)
% --------------------------------------------------------------------------------------------------------- %
% End recording time for chosen time stamp and print the elapsed time
% --------------------------------------------------------------------------------------------------------- %

% TODO: instead of printing, maybe just add times to sLog?

if nargin == 3
    sConfig = msgIdx; % TODO: maybe more neat implementation of this case?
end
    
if sConfig.sDB.profiler
    if nargin == 4
        fprintf(msg+" # %d ; Elapsed time: %.2f\n",msgIdx,toc(startRecord));
    else
        fprintf(msg+" ; Elapsed time: %.2f\n",toc(startRecord));
    end
end

end