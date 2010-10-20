% Fixes a value to a fixed-width integer
% din is input.
% bits_after_dp gives digits after decimal point
% bits_before_dp gives max magnitude as 2^bbd. Values greater than this
% will be scaled back to max
function dout = bit_fix(din, bits_before_dp, bits_after_dp)

%din = sin(2*pi*[0:9]/10)*64

%bits_after_dp = -2;
%bits_before_dp = 6;

%bt = bits_after_dp+bits_before_dp;
bad = bits_after_dp;
bbd = bits_before_dp;
max_int = 2^bbd - 1/2^bad;
min_int = -2^bbd;

dout = floor(din*2^bad);

dout = dout/2^bad;

dout(dout>max_int)=max_int;
dout(dout<min_int)=min_int;

%plot(dout)
