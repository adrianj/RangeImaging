% sin_tr - creates a triangular wave from sine waves.
% function s = sin_tr(t,N)
% t is the usual sine input. N is the number of frequencies to add
function s = sin_tr(t,N)

d = 0;
for i = 1:2:N
    order = floor(i/2);
    d = d + sin(i*t)/(i^2)*(-1)^order;
end

s = d;%*4/pi;
if N > 2
    s = s*8/pi^2;
end
