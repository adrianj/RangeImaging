% Simple logarithm algorithm, for VHDL implementation
% Assume 16-bit input, 16-bit output.

N = 16;
linear_in = [1:2^N-1];
log_actual = log2(linear_in)*4096;

% This line is easily implemented in hardware by combinational logic
MSB = floor(log2(linear_in));
result_top_4 = MSB*4096;






% This is simple, just take a certain range of bits.
in_MSB_removed = linear_in - 2.^MSB;
linear_remainder = floor(in_MSB_removed./2.^(MSB-6))*64;
result_lin = result_top_4 + linear_remainder;
figure; plot(linear_remainder);
figure; plot(linear_in,log_actual,linear_in,result_lin);
figure; plot(log_actual-result_lin);
RMSErrorLinear = std(log_actual-result_lin)


% Use look-up-table for next few bits
lut16x8 = round((log2(16+[0:15])-4)*256)*16;
% Find next 4 bits after MSB
% Again, this can be impemented in hardware by combinational logic.
lut_address = floor((linear_in - 2.^MSB) ./ 2.^(MSB-4));
%plot(lut_address);
% Use lut_address to index into LUT to give bottom 12 bits.
result_middle_4 = zeros(1,length(linear_in));
for i = 1:length(linear_in)
    result_middle_4(i) = lut16x8(lut_address(i)+1);
end

result = result_top_4 + result_middle_4;
figure; plot(linear_in, log_actual, linear_in, result);
figure; plot(linear_in, log_actual-result);
RMSErrorLUT = std(log_actual-result)

return;
leftover_8 = floor(mod(linear_in,2.^(MSB-5))./2.^(MSB-12));
%part_2 = 192-mod(linear_in,2.^(MSB))./2.^(MSB-7);
%leftover_8 = leftover_8.*part_2/128;
figure; plot(linear_in,log_actual-result,linear_in, leftover_8, linear_in, 192-mod(linear_in,2.^(MSB))./2.^(MSB-7));
result = result+leftover_8;
figure; plot(log_actual-result)
RMS2 = std(log_actual-result);
figure; plot(linear_in, log_actual, linear_in, result);