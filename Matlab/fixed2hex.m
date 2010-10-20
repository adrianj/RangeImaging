% string = fixed2hex(fixed, bits, decimal_points)
% Converts a number into a fixed point hex string.
% decimal_points specifies how many digits should follow the implied decimal point
% bits specifies the number of bits in total. Overflows are ignored, and do strange things
% Two strings seperated by a space if number is complex

function string = fixed2hex(fixed, bits, decimal_points)

%fixed = 65536.625;
%bits = 32;
%decimal_points = 3;

bits = bits + mod(-bits,4);

MAX_NUM = 2^bits;

temp = floor(real(fixed)*2^decimal_points);
if real(fixed) < 0
    temp = MAX_NUM + temp;
end

real_string = dec2hex(temp,bits/4);

if isreal(fixed)
    string = real_string;
else
    temp = floor(imag(fixed)*2^decimal_points);
    if imag(fixed) < 0
        temp = MAX_NUM + temp;
    end
    
    imag_string = dec2hex(temp,bits/4); 
    string = [real_string ' ' imag_string];
end

