% ========================================================================================================= %
% Read all log structs and summarize data in excel file.
% ========================================================================================================= %

%% In/out filenames:
logsDir = fullfile('Results','Logs');
outFilename = fullfile('Results','Summary.xlsx');

%% Read data from all logs:
svLogsInfo = dir(logsDir);
vIsFile = ~[svLogsInfo.isdir];
svLogsInfo = svLogsInfo(vIsFile);

Noise =     zeros(length(svLogsInfo), 1);
Algorithm = cell(length(svLogsInfo), 1);
Name =      cell(length(svLogsInfo), 1);
Runtime =   zeros(length(svLogsInfo), 1);
PSNR =      zeros(length(svLogsInfo), 1);
SSIM =      zeros(length(svLogsInfo), 1);
for iLog = 1:length(svLogsInfo)
    load(fullfile(logsDir, svLogsInfo(iLog).name), 'sLog');
    Noise(iLog) =     sLog.noiseStd;
    Algorithm{iLog} = sLog.alg;
    Name{iLog} =      sLog.vidName;
    Runtime(iLog) =   round(sLog.time*100)/100;
    PSNR(iLog) =      round(sLog.psnr*100)/100;
    SSIM(iLog) =      round(sLog.ssim*100)/100;
end

%% Create table:
% sort - by noise, then alg, then name
[~, vIndsNameSorted] = sort(Name);
[~, vIndsAlgSorted] = sort(Algorithm(vIndsNameSorted));
[~, vIndsNoiseSorted] = sort(Noise(vIndsNameSorted(vIndsAlgSorted)));
vInds = vIndsNameSorted(vIndsAlgSorted(vIndsNoiseSorted));

Noise =     Noise(vInds);
Algorithm = Algorithm(vInds);
Name =      Name(vInds);
Runtime =   Runtime(vInds);
PSNR =      PSNR(vInds);
SSIM =      SSIM(vInds);

T = table(Noise, Algorithm, Name, PSNR, SSIM, Runtime);

%% Write to excel:
writetable(T, outFilename);
