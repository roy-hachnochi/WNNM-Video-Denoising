function [X ] = LRAppro( Y,sigma,M_Temp,c,k )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%   The algorithm solves the following optimization problem
%      1/2||Y-U'V||_F_2 + lambda/2(||U||_F_2 + ||V||_F_2)

%% initialization
[row, col] = size(Y);
D = randn(row,k);
tempD = zeros(size(D));
A = randn(k,col);
tempA = zeros(size(A));
maxiter = 6;
OMG = 1.75;
epsl = 1e-5;


seta = mean(mean(Y.^2,1));
lambda = c*sigma^2/sqrt(seta)+epsl;
lambda1 = lambda*col/k;
lambda2 = lambda*row/k;

%% Alternate Direction Optimization 
% main loop
for i = 1:maxiter
    A = (D'*D+lambda2*eye(k))\(D'*Y);
    tempA = OMG*A+(1-OMG)*tempA;
%     t1 = max(max(abs(tempA-A)));
    A = tempA;
    
    D = (Y*A')/(A*A'+lambda1*eye(k));
    tempD = OMG*D+(1-OMG)*tempD;
%     t2 = max(max(abs(tempD-D)));
    D = tempD;
%     if max(t1,t2)<epsl
%         i
%         break;
%     end

end

%% result
X = D*A;
X=X+M_Temp;
    
end



