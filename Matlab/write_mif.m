function write_mif(input, width, outFilename)

%input = 1:1024;
%width = 16;

addr_width = ceil(log2(length(input)))
len = 2^addr_width


%outFilename = 'D:\PhD\VHDL\altera_atan.mif';
outFile = fopen(outFilename, 'w');

fprintf(outFile, 'DEPTH = %d;\n', length(input));
fprintf(outFile, 'WIDTH = %d;\n', width);
fprintf(outFile, 'ADDRESS_RADIX = HEX;\n');
fprintf(outFile, 'DATA_RADIX = HEX;\n');
fprintf(outFile, 'CONTENT\n');
fprintf(outFile, 'BEGIN\n');


for i = 1:len
    N = fixed2hex(i-1, addr_width, 0);
    D = fixed2hex(input(i), width, 0);
    %D = dec2bin(input(i), width);
    fprintf(outFile, '%s : %s;\n', N, D);
    %fprintf(outFile, '%s\n', D);
end

fprintf(outFile, 'END;');
outFile = fclose(outFile);

