function [] = SaveLog(sLog, logPath)
% --------------------------------------------------------------------------------------------------------- %
% Saves Log struct.
%
% Input:
%   sLog -    Log struct to save.
%   logPath - Log output path.
% --------------------------------------------------------------------------------------------------------- %

warning('off', 'MATLAB:MKDIR:DirectoryExists');

logDir = split(logPath, '/');
logDir = join(logDir(1:end-1), '/');
mkdir(logDir{1});

save(logPath, 'sLog');

end
