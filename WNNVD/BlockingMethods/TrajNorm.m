function d = TrajNorm(vDiffTraj, sConfig)
% Calculates norm of all trajectoires error.

switch sConfig.sBlockMatching.metric
    case 'l1'
        d = mean(abs(vDiffTraj));
    case 'l2'
        d = sqrt(mean(abs(vDiffTraj).^2));
    otherwise
        error('Metric not defined');
end

end
