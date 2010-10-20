% sin_sq - creates a square wave from sine waves.
% function s = sin_sq(t,N)
% t is the usual sine input. N is the number of frequencies to add
function s = sin_sq(t,N)


d = 0;
for i = 1:2:N
    d = d + sin(i*t)/i;
end

s = d;%*4/pi;
if N > 2
    s = s*4/pi;
end
