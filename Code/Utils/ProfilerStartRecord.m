function savedTimeStamp = ProfilerStartRecord(sConfig)
% --------------------------------------------------------------------------------------------------------- %
% Start recording time for chosen time stamp
% --------------------------------------------------------------------------------------------------------- %
if sConfig.sDB.profiler
    savedTimeStamp = tic;
end

end