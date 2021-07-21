%
function  [X] =  WWNNM( Y, C, NSig, m, Par )

% initialize X as Y or ?
X = Y;
for i = 1:Par.ReWeiIter
    Ystar = X + 1/Par.mu * (Y - X) * diag(NSig).^2;
    [U, SigmaY, V] =   svd(full(Ystar), 'econ'); % Ystar
    PatNum        = size(Y,2);
    TempC  = C * sqrt(PatNum) * 2 * NSig(1)^2; % 2/Par.mu * 
    [SigmaX, svp] = ClosedWNNM(SigmaY, TempC, eps);
    X =  U(:,1:svp) * diag(SigmaX) * V(:,1:svp)';
end
    X =  X + m;
return;

% function  [X]  =  WWNNM( Y, C, NSig, m, Iter )
% [U,SigmaY,V] =   svd(full(Y), 'econ');
% PatNum        = size(Y, 2);
% Temp            =   sqrt(max( diag(SigmaY) .^ 2 - PatNum * NSig(1) ^ 2, 0 ));
% W_Sam = C * sqrt(PatNum) * NSig(1) ^ 2;
% for i=1:Iter
%     %         W_Vec    =   (C * sqrt(PatNum) * NSig .^ 2) ./ ( Temp + eps );               % Weight vector
%     W_Vec  = W_Sam ./ ( Temp + eps );
%     SigmaX = soft(SigmaY, diag(W_Vec));
%     Temp    = diag(SigmaX);
% end
% X =  U * SigmaX * V' + m;
% return;
