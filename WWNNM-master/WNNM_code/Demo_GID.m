
clear;
Original_image_dir  =    'C:\Users\csjunxu\Desktop\PGPD_TIP\20images\';
fpath = fullfile(Original_image_dir, '*.png');
im_dir  = dir(fpath);
im_num = length(im_dir);

nSig  = 40;

PSNR = [];
SSIM = [];
for i = 1:im_num
    O_Img = double( imread(fullfile(Original_image_dir, im_dir(i).name)) );
    randn('seed', 0);
    N_Img = O_Img + nSig* randn(size(O_Img));                                   %Generate noisy image
    fprintf( 'Noisy Image: nSig = %2.3f, PSNR = %2.2f \n\n\n', nSig, csnr( N_Img, O_Img, 0, 0 ) );
    
    Par   = ParSet(nSig);
    E_Img = WNNM_DeNoising( N_Img, O_Img, Par );                                %WNNM denoisng function
    PSNR = [PSNR csnr( O_Img, E_Img, 0, 0 )];
    SSIM  = [SSIM cal_ssim( O_Img, E_Img, 0, 0 )];
    fprintf( 'Estimated Image: nSig = %2.3f, PSNR = %2.2f \n\n\n', nSig, PSNR(end) );
end
mPSNR=mean(PSNR);
mSSIM=mean(SSIM);
fprintf('The average PSNR = %2.4f, SSIM = %2.4f. \n', mPSNR,mSSIM);
name = sprintf(['WNNM_nSig' num2str(nSig) '.mat']);
save(name,'nSig','PSNR','SSIM','mPSNR','mSSIM');