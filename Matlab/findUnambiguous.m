% [d,nA,nB,e] = findUnambiguous(p1, p2, f1, f2, s,w)
%
% Uses CRT to Calculate unambiguous range given two phase values, p1 and p2 (can be 2D arrays)
% f1 and f2 are modulation frequencies, which should be relative to
% eachother by whole numbers less than 10.
% s is the full-scale for the phase input. Can be integer (eg 2^16) or 2pi
% for example.
% d is distance, in millimetres.
% p1 is phase for frequency 1, possibly > s.
% p2 is phase for frequency 2, possibly > s.
% w is weighting - preferably some function of frequency and amplitude
function [d,nA,nB,e] = findUnambiguous(p1, p2, f1, f2, s,w)
% clear all;
% 
% s = 1;
% f1 = 50e6;
% f2 = 30*1e6;
% d_max = 150e9/gcd(f1,f2);
% actual_d = [0:d_max];%[0:15000];
% p1 = mod(actual_d*s*f1/150e9,s);
% p2 = mod(actual_d*s*f2/150e9,s);
% e = 0;%[0:0.01*s:s]';
% p2 = mod(p2 + e,s);
% p1 = mod(p1 + e,s);

% w = 0.5;
%load 40and32MHz
if size(who('w')) == 0, w = 0.5; end
% work out maximum unambiguous ranges in mm - used to correctly scale final output.
c = 300e6;
du1 = c/2/f1*1000;
du2 = c/2/f2*1000;

% ratio between frequencies - preferably low integers.
MA = f1/gcd(f1,f2);
MB = f2/gcd(f1,f2);

% renaming to match Journal equation.
% do some swapping to ensure MA > MB

if MA > MB
    pA = p1;
    pB = p2;
    duA = du1;
    duB = du2;
else
    temp = MA;
    MA = MB;
    MB = temp;
    pA = p2;
    pB = p1;
    duA = du2;
    duB = du1;
end

pB = pB/s;
pA = pA/s;

dE = 150e9/gcd(f1,f2);

k0 = mulinv(MA,MB);
k1 = mulinv(MB,MA);


e = pA*MB-pB*MA;
%nA = mod(k0*round(e),MA);
nB = mod(k0*round(e),MB);
%nB = round(mod(k0*e,MB));
nA = mod(k1*round(-e),MA);



E = e - round(e);
%E = -e - round(-e);

pEMM = MA*(pB + nB) + w.*E;
%pEMM = MB*(pA + nA) - w*E;

%pEMM = w*MB*(pA+nA) + (1-w)*MA*(pB+nB);


d = pEMM*dE/MA/MB;
%figure; plot(d,nA,'.',d,nB,'.');

e = pEMM;
%figure; 
%subplot(2,2,1); plot(e); title('e');
%subplot(2,2,2); plot(pEMM); title('pEMM');
%subplot(2,2,3); plot(E); title('E');
%subplot(2,2,4); plot(nB); title('kB');
%e = w.*E;

% return these values out of interest and for comparison
k1 = floor(d/du1);
k2 = floor(d/du2);
% These are results utilising only information from the single sources.
p1r = p1 + k1*s;
p2r = p2 + k2*s;
