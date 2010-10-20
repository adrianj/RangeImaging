% Analyse bit-widths for processing

fpb = 8;
lut_width = 8;      % signed
input_width = 16;   % unsigned
t = 0:fpb-1;

phase = 0;

c_lut = floor(cos(2*pi*t/fpb)*(2^(lut_width-1)-1));
s_lut = floor(sin(2*pi*t/fpb)*(2^(lut_width-1)-1));

pixel_a = floor((cos(2*pi*t/fpb + phase)+1)*(2^(input_width-1)-1));
pixel_b = floor((cos(2*pi*t/fpb + pi + phase)+1)*(2^(input_width-1)-1));

pixel_diff = pixel_a - pixel_b; % width = input_width + 1, signed

pixel_real = pixel_diff .* c_lut;   % width = input_width + lut_width, signed
pixel_imag = pixel_diff .* s_lut;

real_acc = zeros(fpb,1);
imag_acc = zeros(fpb,1);
real_acc(1) = pixel_real(1);
imag_acc(1) = pixel_imag(1);

for i = 2:fpb
    real_acc(i) = real_acc(i-1) + pixel_real(i);
    imag_acc(i) = imag_acc(i-1) + pixel_imag(i);
end

figure; plot(t, real_acc, t, imag_acc)
