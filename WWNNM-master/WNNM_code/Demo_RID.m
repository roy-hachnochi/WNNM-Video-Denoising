clear;
% GT_Original_image_dir = 'C:\Users\csjunxu\Desktop\CVPR2017\cc_Results\Real_MeanImage\';
% GT_fpath = fullfile(GT_Original_image_dir, '*.png');
% TT_Original_image_dir = 'C:\Users\csjunxu\Desktop\CVPR2017\cc_Results\Real_NoisyImage\';
% TT_fpath = fullfile(TT_Original_image_dir, '*.png');
GT_Original_image_dir = 'C:\Users\csjunxu\Desktop\CVPR2017\cc_Results\Real_ccnoise_denoised_part\';
GT_fpath = fullfile(GT_Original_image_dir, '*mean.png');
TT_Original_image_dir = 'C:\Users\csjunxu\Desktop\CVPR2017\cc_Results\Real_ccnoise_denoised_part\';
TT_fpath = fullfile(TT_Original_image_dir, '*real.png');
GT_im_dir  = dir(GT_fpath);
TT_im_dir  = dir(TT_fpath);
im_num = length(TT_im_dir);


Par.patsize       =   6;                            % Patch size
Par.SearchWin =   20;
Par.patnum        =   70;
Par.Iter          =   4;                            % total iter numbers
Par.delta     =   0;                                  % Parameter between each iter
Par.c         =   sqrt(2);                              % Constant num for the weight vector
Par.Innerloop =   2;                                    % InnerLoop Num of between re-blockmatching
Par.ReWeiIter =   3;
Par.step      =   Par.patsize - 1;
for lamada =[8 9 11 12 13 14]
    Par.lamada = lamada;
    PSNR = [];
    SSIM = [];
    for i = 1:im_num
        O_Img = double( imread(fullfile(GT_Original_image_dir, GT_im_dir(i).name)) );
        N_Img = double(imread(fullfile(TT_Original_image_dir, TT_im_dir(i).name) ));
        nSig = NoiseEstimation(N_Img, Par.patsize);
        Par.nSig      =   nSig;                                 % Variance of the noise image
        fprintf( 'Noisy Image: nSig = %2.3f, PSNR = %2.2f \n\n\n', nSig, csnr( N_Img, O_Img, 0, 0 ) );
        E_Img = WNNM_DeNoising( N_Img, O_Img, Par );                                %WNNM denoisng function
        PSNR = [PSNR csnr( O_Img, E_Img, 0, 0 )];
        SSIM  = [SSIM cal_ssim( O_Img, E_Img, 0, 0 )];
        fprintf( 'Estimated Image: nSig = %2.3f, PSNR = %2.2f \n\n\n', nSig, PSNR(end) );
    end
    mPSNR=mean(PSNR);
    mSSIM=mean(SSIM);
    fprintf('The average PSNR = %2.4f, SSIM = %2.4f. \n', mPSNR,mSSIM);
    name = sprintf(['WNNM_NL_RID_CC' num2str(im_num) '_lamada' num2str(lamada) '.mat']);
    save(name,'nSig','PSNR','SSIM','mPSNR','mSSIM');
end
