function  [par]=ParSet(nSig)

par.nSig      =   nSig;                                 % Variance of the noise image
par.win =   30;                                   % Non-local patch searching window
par.delta     =   0.1;                                  % Parameter between each iter
par.Constant         =   2 * sqrt(2);                              % Constant num for the weight vector
par.Innerloop =   2;                                    % InnerLoop Num of between re-blockmatching
par.ReWeiIter =   3;
if nSig<=20
    par.ps       =   6;                            % Patch size
    par.nlsp        =   70;                           % Initial Non-local Patch number
    par.Iter          =   8;                            % total iter numbers
    par.lamada        =   0.54;                         % Noise estimete parameter
elseif nSig <= 40
    par.ps       =   7;
    par.nlsp        =   90;
    par.Iter          =   12;
    par.lamada        =   0.56; 
elseif nSig<=60
    par.ps       =   8;
    par.nlsp        =   120;
    par.Iter          =   14;
    par.lamada        =   0.58; 
else
    par.ps       =   9;
    par.nlsp        =   140;
    par.Iter          =   14;
    par.lamada        =   0.58; 
end
par.step      =   floor((par.ps) - 1);       
% par.step      =   floor((par.patsize)/2-1);                   
% Blockmatching and perform WNNM algorithm on all the patches in the image
% is time consuming, we just perform the blockmatching and WNNM on parts of
% patches in the image (we call these patches keypatch in explanatory notes)
% par.step is the step between each keypatch, smaller step will further
% improve the denoisng result