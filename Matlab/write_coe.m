function write_coe(input, bits, filename)
% write_coe(input, filename, bits)
% Writes a .coe file of the input vector, with given number of bits
% Beware if input is greater than 2^bits, strings may be of different
% lengths.

%input = 1:12345:2^18;
%bits = 18;
%filename = '../VHDL/atan_lut.coe';

fid = fopen(filename, 'w');
fprintf(fid, 'MEMORY_INITIALIZATION_RADIX=16;\n');
fprintf(fid, 'MEMORY_INITIALIZATION_VECTOR=\n');

for i = 1:length(input)
    a = cast(input(i), 'uint32');
    s = sprintf('%x', a);
    while length(s) < ceil(bits/4)
        s = ['0' s];
    end
    if i == length(input)
        s = [s ';'];
    else
        s = [s ',\n'];
    end
    fprintf(fid, s);
    
end

fclose(fid);