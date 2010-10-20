% Perform disambiguation by mixing modulation signals.
% frequency of shutter = fs,
% frequency of light = f1 + f2
% apply two difference frequencies, fd1 and fd2.

clear all;

max_time = 2; % seconds
theta = 10;
sample_rate = 30; % Hz


t = 0:0.00001:max_time;

f1 = 2e4;
f2 = 3e4;
fd1 = 2;
fd2 = 3;


ss = sin(t*f1*2*pi) + sin(t*f2*2*pi); % shutter signal
sl1 = sin(2*pi*t*(f1+fd1)+theta); % light signal
sl2 = sin(2*pi*t*(f2+fd2)+theta);
sl = sl1+sl2;

sr = ss.*sl; % resultant signal

figure; plot(t,sr);
% low-pass filter (action of digital camera)
[B,A] = butter(4,0.01);

srf = filter(B,A,sr);


% beat frequency is 3 and 5 Hz, so reasonable sample rate can expect 30 Hz.
resample_rate = floor(length(t)/(sample_rate*max_time));
srr = srf(1:resample_rate:end);
% Add back in 1st sample, since it shouldn't be zero.
srr(1) = srr(sample_rate+1);
tr = t(1:resample_rate:end);
figure; subplot(2,1,1); plot(t,srf); axis([0,max_time,-1.2,1.2]); subplot(2,1,2); plot(tr,srr,'-o'); axis([0,max_time,-1.2,1.2]);

sin1 = sin(tr*fd1*2*pi);
sin2 = sin(tr*fd2*2*pi);
cos1 = cos(tr*fd1*2*pi);
cos2 = cos(tr*fd2*2*pi);
figure; plot(tr,cos1,'-o');

real1 = cos1*srr';
imag1 = sin1*srr';
real2 = cos2*srr';
imag2 = sin2*srr';

atan2(imag1,real1)
atan2(imag2,real2)



