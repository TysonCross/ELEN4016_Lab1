tic
plt=0;
X = cell2mat(in_data);
T = cell2mat(target_data);
[ I N ] = size(X); % [ 1 200000 ]
[ O N ] = size(T); % [ 1 200000 ]
% Define data for training
Ntrn = N-2*round(0.15*N) % Default 0.7/0.15/0.15 trn/val/tst ratios
trnind = 1:Ntrn;
Ttrn = T(trnind);
Ntrneq = prod(size(Ttrn)) % Product of element
MSE00 = var(T',1) % 0.1021
% Calculate Z-Score for input (x) and target (t)
zx = zscore(X, 1);
zt = zscore(T, 1);
zxtrn = zscore(X(trnind), 1);
zttrn = zscore(T(trnind), 1);
% Plot Input & Output for both original and transformed (Z-scored)
plt = plt+1,figure(plt);
subplot(221)
plot(X)
title('SIMPLENARX INPUT SERIES')
subplot(222)
plot(zx)
title('STANDARDIZED INPUT SERIES')
subplot(223)
plot(T)
title('SIMPLENARX OUTPUT SERIES')
subplot(224)
plot(zt)
title('STANDARDIZED OUTPUT SERIES')
rng('default')
L = floor(0.95*(2*N-1)) % 189
for i = 1:10 % Number of repetations to use for estimating summary statistics
    % This is for Target (T) Autocorrelation
    n = zscore(randn(1,N),1);
    autocorrn = nncorr( n,n, N-1, 'biased');
    sortabsautocorrn = sort(abs(autocorrn));
    thresh95T(i) = sortabsautocorrn(L);
      % This is for Input-Target (IT) Crosscorelation
      nx = zscore(randn(1,N),1);
      nt = zscore(randn(1,N),1);
      autocorrnIT = nncorr( nx,nt, N-1, 'biased');
      sortabsautocorrnIT = sort(abs(autocorrnIT));
      thresh95IT(i) = sortabsautocorrnIT(L);
  end
  % For Target Autocorrelation
  sigTthresh95 = median(thresh95T)% 0.1470
  meanTthresh95 = mean(thresh95T) % 0.1480
  minTthresh95 = min(thresh95T) % 0.1045 
  medTthresh95 = median(thresh95T) % 0.1470
  stdTthresh95 = std(thresh95T) % 0.0204
  maxTthresh95 = max(thresh95T) % 0.2058 
% For Input-Target Autocorrelation
sigITthresh95 = median(thresh95IT)% 0.1373
meanITthresh95 = mean(thresh95IT) % 0.1418
mintIThresh95 = min(thresh95IT) % 0.1078
medtIThresh95 = median(thresh95IT) % 0.1373
stdtIThresh95 = std(thresh95IT) % 0.0193
maxtIThresh95 = max(thresh95IT) % 0.2261
%%CORRELATIONS
%%%%%TARGET AUTOCORRELATION %%%%%%%
% 
autocorrt = nncorr(zttrn,zttrn,Ntrn-1,'biased');
sigflag95 = -1+ find(abs(autocorrt(Ntrn:2*Ntrn-1))>=sigTthresh95); %significant Feedback Delay (FD) => [0 2 3 4 5 7 9 11 14 16 22 45]
sigflag95(sigflag95==0)=[]; % Remove 0 from FD => [2 3 4 5 7 9 11 14 16 22 45]
% 
plt = plt+1, figure(plt);
hold on
plot(0:Ntrn-1, -sigTthresh95*ones(1,Ntrn),'b--')
plot(0:Ntrn-1, zeros(1,Ntrn),'k')
plot(0:Ntrn-1, sigTthresh95*ones(1,Ntrn),'b--')
plot(0:Ntrn-1, autocorrt(Ntrn:2*Ntrn-1))
plot(sigflag95,autocorrt(Ntrn+sigflag95),'ro')
title('SIGNIFICANT TARGET AUTOCORRELATIONS (FD)')
%
%%%%%%INPUT-TARGET CROSSCORRELATION %%%%%%
%
crosscorrxt = nncorr(zxtrn,zttrn,Ntrn-1,'biased');
sigilag95 = -1 + find(abs(crosscorrxt(Ntrn:2*Ntrn-1))>=sigITthresh95) %significant Input Delay (ID) => [0 1 3 4 5 6 8 9 10 12 15 17 35]
% 
plt = plt+1, figure(plt);
hold on
plot(0:Ntrn-1, -sigITthresh95*ones(1,Ntrn),'b--')
plot(0:Ntrn-1, zeros(1,Ntrn),'k')
plot(0:Ntrn-1, sigITthresh95*ones(1,Ntrn),'b--')
plot(0:Ntrn-1, crosscorrxt(Ntrn:2*Ntrn-1))
plot(sigilag95,crosscorrxt(Ntrn+sigilag95),'ro')
title('SIGNIFICANT INPUT-TARGET CROSSCORRELATIONS (ID)')
