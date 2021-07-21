function [ X ] = solve_lyp( A,B,C,flag )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

if(flag ==1)
    [U S V] = svd(A);
    s = diag(S);
    b = diag(B);
    Ts = repmat(s,[1 size(b)]);
    Tb = repmat(b',[size(s) 1]);
    TEMP = Ts+Tb;
    Y = (U'*C)./TEMP;
    X = U*Y;
else
    [U S V] = svd(B);
    s = diag(S);
    a = diag(A);
    Ta = repmat(a,[1 size(s)]);
    Ts = repmat(s',[size(a) 1]);
    TEMP = Ta+Ts;
    Y = (C*U)./TEMP;
    X = Y*U';
end

