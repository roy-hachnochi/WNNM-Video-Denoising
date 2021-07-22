function SetPaths()

parentFolders = {'Utils', 'Videos', 'WNNVD'};

for fInd = 1:length(parentFolders)
    addpath(genpath(parentFolders{fInd}));
end

end
