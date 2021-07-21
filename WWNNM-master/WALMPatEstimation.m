function [ EPat, W ] = WALMPatEstimation( NL_mat, Sigma_arr, CurPat, Par )

EPat = zeros(size(CurPat));
W    = zeros(size(CurPat));
for  i      =  1 : length(Par.SelfIndex)                                 % For each keypatch group
    index = NL_mat(1:Par.nlsp, i);
    Temp    =   CurPat(:, index);                  % Non-local similar patches to the keypatch
    M_Temp  =   repmat(mean( Temp, 2 ), 1, Par.nlsp);
    Temp    =   Temp - M_Temp;
    
    %     E_Temp 	=   WWNNM( Temp, Sigma_arr(NL_mat(1:Par.patnum,i)), M_Temp, Par); % WWNNM Estimation
    %     E_Temp 	=   WLRAppro( Temp, Sigma_arr(NL_mat(1:Par.patnum,i)), M_Temp, Par.c, Par.rank );
    E_Temp 	=   WWNNM_ALM( Temp, Sigma_arr(index), M_Temp, Par ); % Sigma_arr(Self_arr(i))
    EPat(:, index)  = EPat(:, index) + E_Temp;
    W(:, index)     = W(:, index) + ones(Par.ps2ch, size(index, 1));
end
end

