% script to help me understand harmonic rejection...
t = 0:0.005:20-0.005;
N = length(t);
M = 16;
light = sin(2*pi*t)<0;

sensor = zeros(1,length(t));
% ratio is 1:sqrt(2):1.
c1 = N * 1/(2+sqrt(2));
c2 = c1 + N * sqrt(2)/(2+sqrt(2));

pixel = [];

for j = 0:M-1
for i = 1:N
    if i < c1
        sensor(i) = sin(2*pi*t(i) + j*2*pi/M - pi/4) < 0;
    elseif i < c2
        sensor(i) = sin(2*pi*t(i) + j*2*pi/M)<0; 
    else
        sensor(i) = sin(2*pi*t(i) + j*2*pi/M + pi/4) < 0;
    end
    sensor(i) = sin(2*pi*t(i) + j*2*pi/M)<0;
end
pixel = [pixel sum(sensor.*light)];
end


plot(t, light,t,sensor);
plot(pixel);