  

    nSig  = 40;
    O_Img = double(imread('lena.png'));

    randn('seed', 0);
    N_Img = O_Img + nSig* randn(size(O_Img));                                   %Generate noisy image
    PSNR  =  csnr( N_Img, O_Img, 0, 0 );
    fprintf( 'Noisy Image: nSig = %2.3f, PSNR = %2.2f \n\n\n', nSig, PSNR );
    
    Par   = ParSet(nSig);   
    E_Img = WNNM_DeNoising( N_Img, O_Img, Par );                                %WNNM denoisng function
    PSNR  = csnr( O_Img, E_Img, 0, 0 );
    
    fprintf( 'Estimated Image: nSig = %2.3f, PSNR = %2.2f \n\n\n', nSig, PSNR );
    figure;
    subplot(1,3,2);
    imshow(uint8(O_Img));
    title('Original');
    subplot(1,3,1);
    imshow(uint8(N_Img));
    title('Noised');
    subplot(1,3,3);
    imshow(uint8(E_Img));
    title('Denoised');