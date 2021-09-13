function d = PatchesNorm(mDiffPatches, sConfig)
% Calculates norm of all patches.
% Assuming input is of shape [k, p, p]:
%   k - number of patches.
%   p - size of the patches.

switch sConfig.sBlockMatching.metric
    case 'l1'
        d = mean(abs(mDiffPatches), [2, 3]);
    case 'l2'
        d = sqrt(mean(abs(mDiffPatches).^2, [2, 3]));
    otherwise
        error('Metric not defined');
end

end