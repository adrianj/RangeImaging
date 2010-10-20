% signal = read_fixed(filename, isComplex, decimal_points)
% Reads a text file with 16 bit twos complement fixed values written in hex.
% For non complex values, expect each line to have 4 characters,
% complex values should have 8 characters per line.
% See hex2fixed for definition of  decimal_points

function signal = read_fixed(filename, isComplex, decimal_points)

fid = fopen(filename, 'r');
dIn = fscanf(fid,'%s');
fclose(fid);
if isComplex == 1
    len = length(dIn)/4;
else
    len = length(dIn)/8;
end
len
signal = zeros(len,1);
for i = 1:len
    if isComplex == 1
        signal(i) = hex2fixed(dIn(i*8-7:i*8-4),16, decimal_points) + j * hex2fixed(dIn(i*8-3:i*8),16, decimal_points);
    else
        signal(i) = hex2fixed(dIn(i*8-7:i*8),32,decimal_points);
    end
end

