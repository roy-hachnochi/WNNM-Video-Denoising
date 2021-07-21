function [E_Img, Par]   =  WWNNM_ALM_1AG( N_Img, O_Img, Par )

E_Img           = N_Img;   % Estimated Image
[h, w, ch]  = size(E_Img);
Par.h = h;
Par.w = w;
Par.ch = ch;
Par = SearchNeighborIndex( Par );
% noisy image to patch 
NoiPat =	Image2PatchNew( N_Img, Par );                      
for iter = 1 : Par.Iter
    % iterative regularization
    E_Img             	=	E_Img + Par.delta * (N_Img - E_Img);
    % image to patch
    CurPat =	Image2PatchNew( E_Img, Par );
    % estimate local noise variance
    Sigma_arr = Par.lamada*sqrt(abs(repmat(Par.nSig^2, 1, size(CurPat, 2)) - mean((NoiPat - CurPat).^2)));
    if (mod(iter-1, Par.Innerloop) == 0)
        Par.nlsp = Par.nlsp - 10;                                             % Lower Noise level, less NL patches
        NL_mat  =  Block_Matching(CurPat, Par);% Caculate Non-local similar patches for each
        if(iter == 1)
            Sigma_arr = Par.nSig * ones(size(Sigma_arr));                       % First Iteration use the input noise parameter
        end
    end
    
    [Y_hat, W_hat]  =  WALMPatEstimation( NL_mat, Sigma_arr, CurPat, Par );   % Estimate all the patches
    E_Img = PGs2Image(Y_hat, W_hat, Par);
    PSNR  = csnr( O_Img, E_Img, 0, 0 );
    SSIM      =  cal_ssim( O_Img, E_Img, 0, 0 );
    fprintf( 'Iter = %2.3f, PSNR = %2.2f, SSIM = %2.2f \n', iter, PSNR, SSIM );
    Par.PSNR(iter, Par.image)  =   PSNR;
    Par.SSIM(iter, Par.image)      =  SSIM;
end
return;





