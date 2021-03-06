function [psnr] = PSNR(mA, mB)
% --------------------------------------------------------------------------------------------------------- %
% Calculates PSNR evaluation metric between two matrices.
% --------------------------------------------------------------------------------------------------------- %

mA = double(mA);
mB = double(mB);
mse = mean((mA(:) - mB(:)).^2);
psnr = 10*log10((255^2)/mse);

end
