% Projected Normal Distribution
% A normal distribution at high amplitude, which becomes a uniform
% distribution for low amplitudes due to quantization.

p = 0;

N = 4;


AMP = [0.1:0.1:5];

sdev = 1/max(AMP);


ITERATIONS = 100000;
bins = [-pi*3*sdev:sdev/10*pi:pi*3*sdev];

phase_dist = zeros(length(AMP),length(bins));
SNR = 1;
for a = 1:length(AMP)
    A = AMP(a);
    pe = zeros(1,ITERATIONS);
    pp = pe;
    ppf = pe;
    for i = 1:ITERATIONS
        p = rand*2*pi;
        im = A*sin(p);
        re = A*cos(p);
        noise = randn*sdev;
        im_f = floor(im+noise);
        re_f = floor(re+noise);
        
        p_actual = atan2(im,re);
        p_est = atan2(im_f,re_f);
        
        pp(i) = p_actual;
        ppf(i) = p_est;
    end
    pe = pp-ppf;
    pe = cleverUnwrap(pe,2*pi);
    phase_dist(a,:) = histc(pe,bins);
    if mod(a,floor(ITERATIONS/20000))==0, fprintf('%d\n',a); end
end
phase_dist(:,end) = phase_dist(:,end-1);
figure;imagesc(phase_dist);
figure;surf(bins,AMP,phase_dist);
back_row = mean(phase_dist(1,:))
figure; plot(pp,ppf,'.');