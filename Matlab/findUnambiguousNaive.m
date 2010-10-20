% [p1r,p2r,d,k1,k2] = findUnambiguous(p1, p2, f1, f2, mag_1, mag_2)
%
% Uses CRT to Calculate unambiguous range given two phase values, p1 and p2 (can be 2D arrays)
% f1 and f2 are modulation frequencies, which should be relative to
% eachother by whole numbers less than 10.
% d is distance, in millimetres.
% s is the full-scale for the phase input. Can be integer (eg 2^16) or 2pi
% for example.
% p1r is phase for frequency 1, possibly > 2*pi.
% p2r is phase for frequency 2, possibly > 2*pi.
% k1 and k2 are the integer units where phase has wrapped around.
function [d,p1r,p2r,k1,k2] = findUnambiguous(p1, p2, f1, f2, s)
% actual_d = 14445;
% s = 2^16;
% p1 = 686;
% p2 = 62709;
% f1 = 40e6;
% f2 = 30e6;
%load 40and32MHz
c = 300e6;
du1 = c/2/f1*1000;
du2 = c/2/f2*1000;
si = size(p1);


MA = f1/gcd(f1,f2);
MB = f2/gcd(f1,f2);

MBt = MB*p1;
MAt = MA*p2;
offset = MBt-MAt;

min_y = ones(si(1),si(2))*s;
kA = min_y;
kB = min_y;

for k1 = 0:MA-1
    for k2 = 0:MB-1
        y = abs(offset + s*(MB*k1 - MA*k2));
        %fprintf('kA: %d\tkB: %d\ty: %d\n',k1,k2,y);
        
        kA(y<min_y) = k1;
        kB(y<min_y) = k2;
        min_y(y < min_y) = y(y < min_y);
        
    end
end

d1 = (du1 .* (kA*s + p1))/s;
d2 = (du2 .* (kB*s + p2))/s;
% d is weighted average of the two
d = (d1+d2)/2;

p1r = d *2*pi/du1;
p2r = d *2*pi/du2;

