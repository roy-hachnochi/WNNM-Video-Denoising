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

vNoise =     zeros(length(svLogsInfo), 1);
vName =      cell(length(svLogsInfo), 1);
vAlgorithm = cell(length(svLogsInfo), 1);
vRuntime =   zeros(length(svLogsInfo), 1);
vPSNR =      zeros(length(svLogsInfo), 1);
vSSIM =      zeros(length(svLogsInfo), 1);
for iLog = 1:length(svLogsInfo)
    load(fullfile(logsDir, svLogsInfo(iLog).name), 'sLog');
    vNoise(iLog) =     sLog.noiseStd;
    vName{iLog} =      sLog.vidName;
    vAlgorithm{iLog} = sLog.alg;
    vRuntime(iLog) =   round(sLog.timePerFrame*100)/100;
    vPSNR(iLog) =      round(sLog.psnr*100)/100;
    vSSIM(iLog) =      round(sLog.ssim*100)/100;
end

%% Create table:
% sort - by noise, then name, then alg
[~, vIndsAlgSorted] = sort(vAlgorithm);
[~, vIndsNameSorted] = sort(vName(vIndsAlgSorted));
[~, vIndsNoiseSorted] = sort(vNoise(vIndsAlgSorted(vIndsNameSorted)));
vInds = vIndsAlgSorted(vIndsNameSorted(vIndsNoiseSorted));

vNoise =     vNoise(vInds);
vName =      vName(vInds);
vAlgorithm = vAlgorithm(vInds);
vRuntime =   vRuntime(vInds);
vPSNR =      vPSNR(vInds);
vSSIM =      vSSIM(vInds);

T = table(vNoise, vName, vAlgorithm, vPSNR, vSSIM, vRuntime,...
    'VariableNames', {'Noise STD', 'Video', 'Algorithm', 'PSNR', 'SSIM', 'Time per frame [sec]'});

%% Write to excel:
writetable(T, outFilename);
