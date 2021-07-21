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

Par.ps       =   6;                            % Patch size
Par.Iter          =   4;                            % total iter numbers
Par.win =   20;                                   % Non-local patch searching window
Par.delta     =   0.1;                                  % Parameter between each iter
Par.Constant         =   2 * sqrt(2);                              % Constant num for the weight vector
Par.Innerloop =   2;                                    % InnerLoop Num of between re-blockmatching
Par.step      =   floor((Par.ps) - 1);
Par.display = true;

Par.method = 'WNNM';
Par.maxIter = 10;
Par.rho = 1.1;
for nSig = 0.1:0.1:0.3
    Par.nSig = nSig;
    for lamada = 0.3
        Par.lamada = lamada;
        for mu = [0.6 0.62 0.58]
            Par.mu = mu;
            PSNR = [];
            SSIM = [];
            CCPSNR = [];
            CCSSIM = [];
            % record all the results in each iteration
            Par.PSNR = zeros(Par.Iter, im_num, 'single');
            Par.SSIM = zeros(Par.Iter, im_num, 'single');
            for i = 1:im_num
                Par.image = i;
                Par.nlsp        =   70;                           % Initial Non-local Patch number
                IMin = im2double(imread(fullfile(TT_Original_image_dir, TT_im_dir(i).name) ));
                IM_GT = im2double(imread(fullfile(GT_Original_image_dir, GT_im_dir(i).name)));
                S = regexp(GT_im_dir(i).name, '\.', 'split');
                IMname = S{1};
                [h,w,ch] = size(IMin);
                fprintf('%s: \n', TT_im_dir(i).name);
                CCPSNR = [CCPSNR csnr( IMin * 255, IM_GT * 255, 0, 0 )];
                CCSSIM = [CCSSIM cal_ssim( IMin * 255, IM_GT * 255, 0, 0 )];
                fprintf('The initial PSNR = %2.4f, SSIM = %2.4f. \n', CCPSNR(end), CCSSIM(end));
                % read clean image
                Par.I = IM_GT;
                Par.nim = IMin;
                %
                t1 = clock;
                [IMout, Par] = WWNNM_ALM_1AR( IMin, IM_GT, Par );                                %WNNM denoisng function
                t2=clock;
                etime(t2,t1)
                alltime(Par.image)  = etime(t2, t1);
                IMout(IMout>1)=1;
                IMout(IMout<0)=0;
                % calculate the PSNR
                %% output
                PSNR = [PSNR csnr( IMout * 255, IM_GT * 255, 0, 0 )];
                SSIM = [SSIM cal_ssim( IMout * 255, IM_GT * 255, 0, 0 )];
                fprintf('The final PSNR = %2.4f, SSIM = %2.4f. \n', PSNR(end), SSIM(end));
                %             imname = sprintf('nSig%d_clsnum%d_delta%2.2f_lambda%2.2f_%s', nSig, cls_num, delta, lambda, im_dir(i).name);
                %             imwrite(im_out,imname);
                fprintf('%s : PSNR = %2.4f, SSIM = %2.4f \n',TT_im_dir(i).name, Par.PSNR(Par.Iter, Par.image),Par.SSIM(Par.Iter, Par.image)     );
            end
            mPSNR=mean(Par.PSNR,2);
            [~, idx] = max(mPSNR);
            PSNR =Par.PSNR(idx,:);
            SSIM = Par.SSIM(idx,:);
            mSSIM=mean(SSIM,2);
            fprintf('The best PSNR result is at %d iteration. \n',idx);
            fprintf('The average PSNR = %2.4f, SSIM = %2.4f. \n', mPSNR(idx),mSSIM);
            name = sprintf([Par.method '_ALM_Sigma_1AR_nSig' num2str(nSig) '_lamada' num2str(lamada) '_mu' num2str(mu) '_Iter' num2str(Par.maxIter) '.mat']);
            save(name,'nSig','PSNR','SSIM','mPSNR','mSSIM');
        end
    end
end