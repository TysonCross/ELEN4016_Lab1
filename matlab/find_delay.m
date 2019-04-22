X = cell2mat(in_data);
T = cell2mat(target_data);
[ O N ] = size(T); % [ 1 200000 ]
[ I N ] = size(X); % [ 1 200000 ]
zscT1 = zscore(T,1);
zscX1 = zscore(X',1)';
autocorrt = nncorr(zscT1,zscT1,N-1,'biased')
autocorrt_pos = autocorrt(N+1:2*N-1)

