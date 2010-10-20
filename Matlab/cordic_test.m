% Tests cordic
 path(path, 'cordic\');
 clear all;
close all;

test_bits = 2;
input_bits = 2;
cordic_bits = 10;
X = -2^(test_bits-1)+1:2^(test_bits-1)-1;
Y = -2^(test_bits-1)+1:2^(test_bits-1)-1;

result_cordic = zeros(2^test_bits, 2^test_bits);
result_atan2 = zeros(2^test_bits, 2^test_bits);

for i = 1:length(X)
    for j = 1:length(Y)
        x = floor(X(i)/2^(test_bits-input_bits))
        y = floor(Y(i)/2^(test_bits-input_bits))
        c = cordic_atan(x,y, cordic_bits) * 2*pi/2^cordic_bits;
        result_cordic(i,j) = c;
        c = atan2(X(i)*2*pi/2^input_bits,Y(j)*2*pi/2^input_bits);
        if c<0 c=c+2*pi; end
        result_atan2(i,j) = c;
        if x == 0 && y == 0
            result_atan2(i,j) = 0;
            result_cordic(i,j) = 0;
        end
    end
end
%result_cordic(0,0) = 0;
%result_atan2(0,0) = 0;
%figure; plot(result_cordic);
%figure; plot(result_atan2);
figure; plot(result_cordic-result_atan2)