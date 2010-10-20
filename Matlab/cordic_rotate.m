% [x y z] = cordic_rotate(x0, y0, z0, d, k, width)
% performs a cordic rotation with input argument x0 + iy0.
% z0 = atan(y0/x0)
% d is the decision to rotate clockwise (-1) or anticlockwise (1)
% k is the current step index, ie, phase rotation will be atan(1/2^k)
% w is the bit width of the input. Use 1 if dealing with unit circle.
function [x y z] = cordic_rotate(x0, y0, z0, d, k, width)

    phase_scale = 2^(width-1); % typically this is pi.
    % at values would be hard coded in some sort of Look-up-table.
    if k < 6
        at = atan(1/2^k) .*phase_scale/pi;
    else
        at = atan(1/2^6) / 2^(k-6) .*phase_scale/pi;
    end
    % Should really use fixed-point precision for the phase values also...
    if width > 1
    %at = floor(at);
    end
    %fprintf('\ttheta: %x\t', cast(at,'int16'));
    z = z0 - d .* at;
    x = x0 - y0 .* d .* 1/2^k;
    y = y0 + x0 .* d .* 1/2^k;
    %fprintf('x0 = %+.6f\ty0 = %+.6f\td = %+.6f\tz = %+.6f\tphase = %+.6f\t\n', x0, y0, d, z, at);
    
