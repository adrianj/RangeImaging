% function bin = RNStoBinary(X,P)
% Uses the Chinese Remainer Theorem (CRT) to convert from a Residue Number
% System (RNS) to a binary equivalent.
% X is a vector of the x values {x1, x2, ..., xi}, P is a vector of the
% same size giving the bases {P1, P2, ..., Pi}.
% Bases should be coprime.

%function bin = RNStoBinary(X, P)
clear all;
close all;
P = [4 5];
scale = 2^16;
SNR = 40;



%round(phases.*P/256)


M = prod(P)
actual_ds = 0:1:20
for iterations = 1:length(actual_ds)
    actual_d = actual_ds(iterations);
    
    fprintf('*** START HERE: d = %.2f\n',actual_d);
X = [mod(actual_d,P(1)) mod(actual_d,P(2))];
% Add noise to the X values...
noise_power = 10^(-SNR/10)*P;
noise = randn(1,2).*noise_power;
X = X + noise;
N(iterations) = sum(noise);
S = M./P;
Si = zeros(1,length(X));
for i = 1:length(X)
    Si(i) = mulinv(P(i),S(i));
end

Xm = sum(X.*S.*Si);

CRTI = mod(Xm,M);


% Using CRT II for 2 inputs
k0 = mulinv(P(2),P(1));
Xs = mod(floor(X*scale./P),scale)

actual_r = floor(actual_d*scale)

X1(iterations) = Xs(1);
X2(iterations) = Xs(2);

% Two multiplications here. Converts numbers from Fractional to Modulo
% Quite a small multiplication, since P is typically small.
Xs(1) = Xs(1) * P(1)
Xs(2) = Xs(2) * P(2)


k_mod = P(1)*scale

% Subtraction here. If negative, add k_mod.
diff = Xs(1) - Xs(2)
diffs(iterations) = diff;
if diff < 0
    diff = k_mod + diff
end
% A very small multiplication - possibly use LUT or shift or other logic?
% (since k0 is less than P(2), ie, small)
k_diff = diff*k0

CRTII = Xs(2) + mod(k_diff,k_mod)*P(2)
CRTII = CRTII/scale

R(iterations) = CRTII;
error(iterations) = CRTII-actual_d;

end
error(error > M/2) = error(error>M/2)-M;
figure; plot(error);
figure; plot(R);
%figure; plot(N);
%figure; plot(X1);
%figure; plot(X2);