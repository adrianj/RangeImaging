% Makes colour map look-up-tables.
% Each are 16 bits wide.
% One is a 1024 point HSV,
% the other is a 1024 point 8 colours (for Spartan3)
% Red occupies bits (15:11), Green (10:6), Blue (5:0)

N = 256;

h = colormap(hsv(N));
close all;

n = [1:N];

%colormap(hsv(N));

%figure; plot(n);

r = cast(round(interp(h(:,1),4)*31), 'uint16') * 32 * 64;
g = cast(round(interp(h(:,2),4)*31), 'uint16') * 64;
b = cast(round(interp(h(:,3),4)*63), 'uint16');



figure; image(n);
h = colormap(h);
n = 1:1024;

d = 171;

r2 = floor([ones(d,1) ; [1:-1/d:1/d]' ; zeros(2*d-1,1) ; [0:1/d:(d-1)/d]' ; ones(d-1,1)] * 31) * 32 * 64;
g2 = floor([[0:1/d:(d-1)/d]' ; ones(2*d-1,1) ; [1:-1/d:1/d]' ; zeros(2*d-1,1)] * 31) * 64;
b2 = floor([zeros(2*d-1,1) ; [0:1/d:(d-1)/d]' ; ones(2*d-1,1) ; [1:-1/d:1/d]'] * 63);


figure; plot(n,r2,n,r);
figure; plot(n,g2,n,g);
figure; plot(n,b2,n,b);

rgb = r2 + g2 + b2;

write_coe(rgb, 16, 'D:\PhD\VHDL\hsvcolour_lut1024x16.coe');
write_mif(rgb, 16, 'D:\PhD\VHDL\hsvcolour_lut1024x16.mif');

r8 = [zeros(512,1) ; ones(512,1)];
g8 = [zeros(256,1) ; ones(256,1) ; zeros(256,1) ; ones(256,1)];
b8 = [zeros(128,1) ; ones(128,1) ; zeros(128,1) ; ones(128,1) ; zeros(128,1) ; ones(128,1) ; zeros(128,1) ; ones(128,1)];

rgb8 = r8 * 32 * 16 * 64 + g8 * 64 * 16 + b8 * 32;

write_coe(rgb8, 16, 'D:\PhD\VHDL\colour8_lut1024x16.coe');
write_mif(rgb8, 16, 'D:\PhD\VHDL\colour8_lut1024x16.mif');