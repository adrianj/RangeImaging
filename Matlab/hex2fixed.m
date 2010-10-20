% fixed = hex2fixed(string, bits, decimal_points)
% Converts a twos complement fixed point hexadecimal input string
% decimal_points is the number of bits which follow the decimal point
% bits is the number of bits being used.

function fixed = hex2fixed(string, bits, decimal_points)

dec = hex2dec(string);

if dec >= 2^(bits-1)
    fixed = dec - 2^bits;
else
    fixed = dec;
end

fixed = fixed / 2^decimal_points;

