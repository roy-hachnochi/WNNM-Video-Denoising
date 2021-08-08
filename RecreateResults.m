% ========================================================================================================= %
% A script for recreating all results presented in our project report:
% Runs WNNVD/WNNID/VBM3D video-denoising algorithms for various noise levels and for different input files.
% ========================================================================================================= %

%% In/out files:
vNoiseSigs = [10, 20, 40];
vidNames =   {'gbicycle', 'gflower', 'gmissa', 'gsalesman', 'gstennis'};
imNames =    {'lena'}; % just for testing WNNVD
inDir =      fullfile('Videos','Noised');
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
            inPaths =  cell(1, nInputs);
            outPaths = cell(1, nInputs);
            logPaths = cell(1, nInputs);
        else
            inPaths =  cell(1, nVids);
            outPaths = cell(1, nVids);
            logPaths = cell(1, nVids);
        end
        
        for iVid = 1:nVids
            inPaths{iVid} = fullfile(inDir,[vidNames{iVid},'_',num2str(noiseSig),'.avi']);
            outPaths{iVid} = fullfile(outDir,[vidNames{iVid},'_',algs{iAlg},'_',num2str(noiseSig),'.avi']);
            logPaths{iVid} = fullfile(logDir,[vidNames{iVid},'_',algs{iAlg},'_',num2str(noiseSig)]);
        end
        
        if strcmp(algs{iAlg},'WNNVD') % run images only with WNNVD
            for iIm = 1:nIms
                inPaths{nVids + iIm} = fullfile(inDir,[imNames{iIm},'_',num2str(noiseSig),'.png']);
                outPaths{nVids + iIm} = fullfile(outDir,[imNames{iIm},'_',algs{iAlg},'_',num2str(noiseSig),'.png']);
                logPaths{nVids + iIm} = fullfile(logDir,[imNames{iIm},'_',algs{iAlg},'_',num2str(noiseSig)]);
            end
        end

        RunTest(sConfig, algs{iAlg}, inPaths, outPaths, logPaths, noiseSig, true, true);
    end
end
