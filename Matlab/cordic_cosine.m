% Calculates sine and cosine for a given phase using Cordic
% Incorporates a scale factor for converting to fixed point arithmetic.
% [cosine sine] = cordic_cosine(phase, cordic_width, output_bits, verbose)
function [cosine sine] = cordic_cosine(phase, cordic_width, output_bits, verbose)

% Correct in range from -phase_scale -> 2 * phase_scale.
a = 0.607252935;
bits = cordic_width;
mag_scale = 2^bits-1;
x0 = floor(mag_scale/2)*a;

phase_scale = 2^(bits-1);  % typically this is pi.

actual_y = sin(phase*pi/phase_scale);
actual_x = cos(phase*pi/phase_scale);

if phase > 3*phase_scale/2
    x = 0;
    y = x0;
    z = 3*phase_scale/2;
elseif phase > phase_scale
    x = -x0;
    y = 0;
    z = phase_scale;
elseif phase > phase_scale/2
    x = 0;
    y = -x0;
    z = phase_scale/2;
elseif phase > 0
    x = x0;
    y = 0;
    z = 0;
elseif phase > -phase_scale/2
    x = x0;
    y = 0;
    z = 0;
else
    x = 0;
    y = x0;
    z = -phase_scale/2;
end

N = bits-1;


a = 1;
if verbose == 1 fprintf('\n'); end

if verbose == 1 fprintf('x: %s\ty: %s\tz: %s\td: %d\n', fixed2hex(floor(x),bits,0), fixed2hex(floor(y),bits,0), fixed2hex(floor(z),bits,0), 0);
end
for i = 0:N   
    diff = z - phase;
    if diff >= 0
        d = 1;
    else
        d = -1;
    end
    [x y z] = cordic_rotate(x,y,z,d,i,cordic_width);
    a = a * 1/sqrt(1+1/2^(2*i));
    if verbose == 1 fprintf('x: %s\ty: %s\tz: %s\td: %d\n', fixed2hex(floor(x),bits,0), fixed2hex(floor(y),bits,0), fixed2hex(floor(z),bits,0), d);
    end
end
if verbose == 1 fprintf('\n'); end


x = x;
y = y;

%cosine = x*correction;
%sine = y*correction*-1;
cosine = floor(x/(2^(bits-output_bits)));
sine = floor(-y/(2^(bits-output_bits)));


if verbose == 1 fprintf('final: x = %+.6f (%+.6f),\ty = %+.6f (%+.6f)\n', cosine, actual_x, sine, actual_y);
end
%fprintf('final: x = %x (%x),\ty = %x (%x)\n', floor(cosine*2^16), floor(actual_x*2^16), floor(sine*2^16), floor(actual_y*2^16));


