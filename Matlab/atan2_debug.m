%[theta, debug] = atan2_debug(imag_t, real_t)
% Calculates atan2 using look-up-table, and also provides a debugging
% output.
% Requires input to be between -2 and 2.

function [theta,debug] = atan2_debug(imag_t, real_t, debug_select)

lut_width = 16;
N = 16384;
i = [0:N-1]/N;
a = atan(i)*4/pi;
% Round lut to 16 bits.
lut_mif = floor(a*2^lut_width);
lut = lut_mif / (2^lut_width);

M = min(length(imag_t), length(real_t));
debug = zeros(M,1);
theta = zeros(M,1);

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

    i_gt_r = 0;
    if abs_i > abs_r
        i_gt_r = 1;
    end

    if i_gt_r == 1
        if abs_i == 0
            numer = 0;
            denom = 1;
        else
            numer = abs_r;
            denom = abs_i;
        end
    else
        if abs_r == 0
            numer = 0;
            denom = 1;
        else
            numer = abs_i;
            denom = abs_r;
        end
    end
    
    ratio = numer * 2^lut_width / denom;

    if ratio >= 2^17
        addr = N;
    else
        addr = floor(ratio*N/2^lut_width)+1;
    end
    
    if debug_select == 11
        debug(k) = numer / 64;
    elseif debug_select == 12
        debug(k) = denom / 64;
    else
        debug(k) = addr;
    end
    
    if i_gt_r == 0 && sign_i == 0 && sign_r == 0
        theta(k) = lut(addr);
    elseif i_gt_r == 1 && sign_i == 0 && sign_r == 0
        theta(k) = 2 - lut(addr);
    elseif i_gt_r == 1 && sign_i == 0 && sign_r == 1
        theta(k) = 2 + lut(addr);
    elseif i_gt_r == 0 && sign_i == 0 && sign_r == 1
        theta(k) = 4 - lut(addr);
    elseif i_gt_r == 0 && sign_i == 1 && sign_r == 1
        theta(k) = 4 + lut(addr);
    elseif i_gt_r == 1 && sign_i == 1 && sign_r == 1
        theta(k) = 6 - lut(addr);
    elseif i_gt_r == 1 && sign_i == 1 && sign_r == 0
        theta(k) = 6 + lut(addr);
    elseif i_gt_r == 0 && sign_i == 1 && sign_r == 0
        theta(k) = 8 - lut(addr);
    end

    
end


