% Atan look-up-table code
% Result of atan is scaled to be from 0 to 8, rather than -pi to pi
% So to retrieve actual phase, multiply by pi/4.

phd_folder = 'D:/sync/PhD';

N = 4096; % Number of points in LUT.
i = [0:N-1]/N;

lut_width = 16;


a = atan(i)*4/pi;

% Round lut to 16 bits.
lut_mif = floor(a*2^lut_width);
lut = lut_mif / (2^lut_width);

M = 200;

imag_t = sin([0:M-1]*2*pi/M) + randn(1,M)/10000000;
real_t = cos([0:M-1]*2*pi/M) + randn(1,M)/10000000;

imag_t = floor((imag_t) * 2^14 * 1.9);
real_t = floor((real_t) * 2^14 * 1.9);



%write_mif(lut_mif, lut_width, 'D:/PhD/VHDL/atan_lut16384x16.mif');
%write_coe(lut_mif, lut_width, 'D:/PhD/VHDL/atan_lut16384x16.coe');

%write_mif(lut_mif, lut_width, 'D:/PhD/VHDL/atan_lut1024x12.mif');
%write_coe(lut_mif, lut_width, 'D:/PhD/VHDL/atan_lut1024x12.coe');

write_mif(lut_mif, lut_width, 'D:/sync/PhD/VHDL/atan_lut4096x16.mif');
write_coe(lut_mif, lut_width, 'D:/sync/PhD/VHDL/atan_lut4096x16.coe');

actual_t = zeros(length(real_t),1);
approx_t = actual_t;

abs_r_t = actual_t;
abs_i_t = actual_t;

ratio_t = actual_t;
lut_t = actual_t;
addr_t = actual_t;

div_t = actual_t;
num_t = actual_t;
den_t = actual_t;

for k = 1:M

real_in = real_t(k);
imag_in = imag_t(k);

actual = atan2(imag_in, real_in);
if actual < 0
    actual = actual + 2*pi;
end

sign_r = 0;
abs_r = real_in;
if real_in < 0
    sign_r = 1;
    abs_r = -real_in;
end
sign_i = 0;
abs_i = imag_in;
if imag_in < 0
    sign_i = 1;
    abs_i = -imag_in;
end

if abs_i > abs_r
    den = abs_i;
    num = abs_r;
    i_gt_r = 1;
else
    den = abs_r;
    num = abs_i;
    i_gt_r = 0;
end

% Simulate hardware divider = 32-bit / 16-bit 
% giving 32-bit + 16-bit remainder

den = cast(den, 'uint32');
num = cast(num*2^16, 'uint32');
num_t(k) = num;
den_t(k) = den;
ratio = floor(num/den);
ratio_t(k) = ratio;

addr = floor(ratio*N/2^16)+1;

if addr > N
    addr = N;
end

fprintf('%d\t%d\t%d\t%d\n', k, real_in, imag_in, addr);



if i_gt_r == 0 && sign_i == 0 && sign_r == 0
    theta = lut(addr);
elseif i_gt_r == 1 && sign_i == 0 && sign_r == 0
    theta = 2 - lut(addr);
elseif i_gt_r == 1 && sign_i == 0 && sign_r == 1
    theta = 2 + lut(addr);
elseif i_gt_r == 0 && sign_i == 0 && sign_r == 1
    theta = 4 - lut(addr);
elseif i_gt_r == 0 && sign_i == 1 && sign_r == 1
    theta = 4 + lut(addr);
elseif i_gt_r == 1 && sign_i == 1 && sign_r == 1
    theta = 6 - lut(addr);
elseif i_gt_r == 1 && sign_i == 1 && sign_r == 0
    theta = 6 + lut(addr);
elseif i_gt_r == 0 && sign_i == 1 && sign_r == 0
    theta = 8 - lut(addr);
end

actual_t(k) = actual;%*4/pi;
approx_t(k) = theta *2*pi/8;

abs_r_t(k) = abs_r;
abs_i_t(k) = abs_i;
ratio_t(k) = ratio;
lut_t(k) = lut(addr);
addr_t(k) = addr - 1;

end

%debug = read_fixed([phd_folder '/VHDL/atan_debug.hex'], 0, 0) / 2^28 * 2*pi/8;
%debug = debug/2^18;

%figure; plot(debug); title('debug');
%figure; plot(imag(debug)); title('imag debug');

%figure; plot(abs_r_t); title('abs r');
%figure; plot(abs_i_t); title('abs i');
figure; plot(ratio_t); title('ratio');
%figure; plot(lut_t); title('lut dout');
figure; plot(addr_t); title('lut addr');
figure; plot(actual_t); title('actual');
figure; plot(approx_t); title('approx');
%figure; plot(actual_t - debug); title('diff');
figure; plot(actual_t - approx_t); title('diff');