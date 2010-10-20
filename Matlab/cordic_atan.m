% Calculates phase and magnitude for a given complex number Z = x + iy 
% using Cordic
% Incorporates a scale factor for converting phase into fixed point
% arithmetic.
% Iterations is equal to cordic_width-1, which is also the number of bits
% in the result.
% [phase magnitude] = cordic_atan(y,x, cordic_width)
function [phase magnitude] = cordic_atan(y, x, cordic_width)

%scale = 1;
bits = cordic_width;
phase_scale = pi; % typically this is pi. Full scale = 2*pi.
z = 0;
x0 = x;
y0 = y;

if x < 0
    x = -x0;
    y = -y0;
    z = -phase_scale;
end

N = bits-1;
actual_z = atan2(y0,x0) * phase_scale/pi;
%if actual_z < 0
%    actual_z = 2*phase_scale+actual_z;
%end
actual_x = sqrt(x0.*x0 + y0.*y0);
a = 0.607252935;


%fprintf('\t\t\t\t%s\t%s\t%s\n', fixed2hex(floor(x),bits,0), fixed2hex(floor(y),bits,0), fixed2hex(floor(z),bits,0));
fprintf('\t\t\t\t%2.2f\t%2.2f\t%2.2f\n', x, y, z);

xx = zeros(1,cordic_width+1);
xx(1) = x;
yy = zeros(1,cordic_width+1);
yy(1) = y;
zz = zeros(1,cordic_width+1);
zz(1) = z;
A = 1;
for i = 0:N    
    if y < 0
        d = 1;
    else
        d = -1;
    end
    
    [x y z] = cordic_rotate(x,y,z,d,i, cordic_width);
    A = A*sqrt(1+2^(-2*i));
    xx(i+2) = x/A;
    yy(i+2) = y/A;
    zz(i+2) = z;
    %fprintf('%s\t%s\t%s\n', fixed2hex(floor(x),bits,0), fixed2hex(floor(y),bits,0), fixed2hex(floor(z),bits,0));
    fprintf('\t\t\t\t%2.2f\t%2.2f\t%2.2f\n', x, y, z*2*phase_scale/2^bits);
end
xx2 = zeros(1,length(xx)*2);
yy2 = zeros(1,length(yy)*2);
xx2(2:2:end) = xx;
yy2(2:2:end) = yy;
figure;plot(xx,yy,'-o',xx2,yy2,'k','linewidth',2);
axis([-0.01 1.1 -1.1 1.1]);
grid on;

x = x*a;

phase = z;
if phase < 0
    phase = phase+2.*phase_scale;
end
magnitude = x;

%fprintf('final: mag = %+.6f (%+.6f),\tphase = %+.6f (%+.6f)\n', magnitude, actual_x, phase, actual_z);
%fprintf('final: mag = %x (%x),\tphase = %x (%x)\n', floor(magnitude), floor(actual_x), floor(phase*2^12), floor(actual_z*2^12));


