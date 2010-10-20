% Compare the findUnambiguous methods using CRT to naive method.
%clear all
%close all
fA = 40e6;
fBs = [30]*1e6;
NOISE_DB = [5:1:25];
NOISE_POWER = 10.^(-NOISE_DB/20);

sdev_v_f_N = zeros(length(fBs),length(NOISE_DB));
sdev_v_f_C = zeros(length(fBs),length(NOISE_DB));
err_v_f_N = zeros(length(fBs),length(NOISE_DB));
err_v_f_C = zeros(length(fBs),length(NOISE_DB));
ITERATIONS = 100;
N = 1000;

for ff = 1:length(fBs)
    fB = fBs(ff);

c = 300e9;
s = 2^16;

MA = fA/gcd(fA,fB);
MB = fB/gcd(fA,fB);

duA = c/2/fA;
duB = c/2/fB;

max_d = duA*MA;




sdev_N = zeros(ITERATIONS,length(NOISE_DB));
sdev_C = zeros(ITERATIONS,length(NOISE_DB));
err_N = zeros(ITERATIONS,length(NOISE_DB));
err_C = zeros(ITERATIONS,length(NOISE_DB));

for nn = 1:length(NOISE_DB)
for i = 1:ITERATIONS

actual_d = ones(N,1)*7000;
%actual_d = rand(N,1)*max_d;



dA = mod(actual_d,duA);
dB = mod(actual_d,duB);


%noiseA = [0:N-1]'*s/N;
%noiseB = [0:N-1]'*s/N;
noiseA = floor(randn(N,1)*NOISE_POWER(nn)*s);
%noiseB = floor(randn(N,1)*NOISE_POWER(nn)*s);
%noiseA = zeros(N,1);
noiseB = zeros(N,1);

pA = dA*s/duA;
pB = dB*s/duB;
pA = floor(pA + noiseA);
pB = floor(pB + noiseB);
pB = mod(pB,s);
pA = mod(pA,s);

%figure; plot(pA);
%figure; plot(pB);

dC = findUnambiguous(pA, pB, fA, fB,s);
%figure; plot(actual_d);
%figure; plot(dC);
%figure; plot(actual_d-dC);
dN = findUnambiguousNaive(pA, pB, fA, fB,s);
%figure; plot(dN);

%figure; plot(actual_d-dN);

error_N = actual_d-dN;
error_C = actual_d-dC;

%error_N(error_N>max_d/2) = error_N(error_N>max_d/2) - max_d;
%error_N(error_N<-max_d/2) = error_N(error_N<-max_d/2) + max_d;
%error_C(error_C>max_d/2) = error_C(error_C>max_d/2) - max_d;
%error_C(error_C<-max_d/2) = error_C(error_C<-max_d/2) + max_d;

%figure; plot(0:99,error_N,0:99,error_C);

sdev_N(i,nn) = std(error_N);
sdev_C(i,nn) = std(error_C);

e = sum(abs(error_N)>(du1-NOISE_POWER(nn)*du1));
err_N(i,nn) = e/N;

if sum(e) > 0
    error_N;
end

e = sum(abs(error_C)>(du1-NOISE_POWER(nn)*du1));
err_C(i,nn) = e/N;


end

fprintf('%d\t%d\t%d\t%d\n',fB,NOISE_DB(nn),MA,MB);

end
%figure; surf(log10(sdev_N)); title('Naive');
%figure; surf(log10(sdev_C)); title('CRT');

figure; semilogy(NOISE_DB,mean(sdev_N),NOISE_DB,mean(sdev_C)); legend('naive','CRT');
figure; plot(NOISE_DB,mean(err_N),NOISE_DB,mean(err_C),'o'); legend('naive','CRT');

%figure; plot(NOISE_DB,mean(sdev_C)./mean(sdev_N)); legend('naive','CRT');

%figure; plot([0:N-1]*s/N,error_N,[0:N-1]'*s/N,error_C);

sdev_v_f_N(ff,:) = mean(sdev_N);
sdev_v_f_C(ff,:) = mean(sdev_C);
err_v_f_N(ff,:) = mean(err_N);
err_v_f_C(ff,:) = mean(err_C);

end

%figure; semilogy(NOISE_DB, sdev_v_f_N); title('sdev naive');
%legend('59','58','56','55','54','50','48','40','36','20','10');
%figure; semilogy(NOISE_DB, sdev_v_f_C); title('sdev CRT');
%legend('59','58','56','55','54','50','48','40','36','20','10');

%figure; semilogy(NOISE_DB, err_v_f_N); title('err naive');
%legend('59','58','56','55','54','50','48','40','36','20','10');
%figure; semilogy(NOISE_DB, err_v_f_C); title('err CRT');
%legend('59','58','56','55','54','50','48','40','36','20','10');