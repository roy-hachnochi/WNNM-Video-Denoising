function [] = SaveLog(sLog, logPath)
% --------------------------------------------------------------------------------------------------------- %
% Saves Log struct.
%
% Input:
%   sLog -    Log struct to save.
%   logPath - Log output path.
% --------------------------------------------------------------------------------------------------------- %

warning('off', 'MATLAB:MKDIR:DirectoryExists');

logDir = split(logPath, filesep);
logDir = join(logDir(1:end-1), filesep);
mkdir(logDir{1});

save(logPath, 'sLog');

end
