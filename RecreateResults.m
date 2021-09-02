% ========================================================================================================= %
% A script for recreating all results presented in our project report:
% Runs WNNVD/WNNID/VBM3D video-denoising algorithms for various noise levels and for different input files.
% ========================================================================================================= %

%% In/out files:
vNoiseSigs = [10, 20, 30];
vidNames =   {'gbicycle', 'gflower', 'gmissa', 'gsalesman', 'gstennis'};
imNames =    {'lena'}; % just for testing WNNVD
inDir =      'Videos';
outDir =     fullfile('Results','Clean');
logDir =     fullfile('Results','Logs');
algs =       {'WNNVD', 'WNNID', 'VBM3D'};

%% Initializations:
nVids =   length(vidNames);
nIms =    length(imNames);
nInputs = nVids + nIms;

sConfig = GetConfig();

%% Run all algorithms on all noise levels:
for noiseSig = vNoiseSigs
    for iAlg = 1:length(algs)
        if strcmp(algs{iAlg},'WNNVD') % run images only with WNNVD
            noisedPaths = cell(1, nInputs);
            origPaths =   cell(1, nInputs);
            outPaths =    cell(1, nInputs);
            logPaths =    cell(1, nInputs);
        else
            noisedPaths =  cell(1, nVids);
            origPaths =    cell(1, nVids);
            outPaths =     cell(1, nVids);
            logPaths =     cell(1, nVids);
        end
        
        for iVid = 1:nVids
            noisedPaths{iVid} = fullfile(inDir,'Noised',[vidNames{iVid},'_',num2str(noiseSig),'.avi']);
            origPaths{iVid} = fullfile(inDir,[vidNames{iVid},'.avi']);
            outPaths{iVid} = fullfile(outDir,[vidNames{iVid},'_',algs{iAlg},'_',num2str(noiseSig),'.avi']);
            logPaths{iVid} = fullfile(logDir,[vidNames{iVid},'_',algs{iAlg},'_',num2str(noiseSig)]);
        end
        
        if strcmp(algs{iAlg},'WNNVD') % run images only with WNNVD
            for iIm = 1:nIms
                noisedPaths{nVids + iIm} = fullfile(inDir,'Noised',[imNames{iIm},'_',num2str(noiseSig),'.png']);
                origPaths{nVids + iIm} = fullfile(inDir,[imNames{iIm},'.png']);
                outPaths{nVids + iIm} = fullfile(outDir,[imNames{iIm},'_',algs{iAlg},'_',num2str(noiseSig),'.png']);
                logPaths{nVids + iIm} = fullfile(logDir,[imNames{iIm},'_',algs{iAlg},'_',num2str(noiseSig)]);
            end
        end

        RunDenoising(sConfig, algs{iAlg}, noisedPaths, origPaths, outPaths, logPaths, noiseSig);
    end
end
