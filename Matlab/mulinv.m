% function x = mulinv(n,m)
% Finds the modular multiplicative inverse, such that xm - yn = 1 for some
% integers x and y.
function x = mulinv(n,m)
%m = 385;
%n = 3;
d = gcd(m,n);
if d > 1
    fprintf('gcd(%d,%d) > 1. Multiplicative Inverse does not exist\n', m, n);
    %x = 0;
    %return;
end
n = n/d;
m = m/d;

for x = 0:m
    for y = 0:n
        r = x*n-y*m;
        if r == 1
            
            %check = mod(x*m,n); fprintf('Check: %d.%d - %d.%d = 1\n', x, n, y, m);
            %x = x*d;
            return;
        end
    end
end
