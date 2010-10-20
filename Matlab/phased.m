% Projected Normal Distribution
% A normal distribution at high amplitude, which becomes a uniform
% distribution for low amplitudes due to quantization.
% same parameters as randn, with extra parameter of AMP.
function p = phased(r,c,AMP)

% pick a random point on unit circle.
p = rand(r,c)*2*pi;
% Find real and imag components, scaled by AMP
im = AMP*sin(p);
re = AMP*cos(p);

% Add uniformly distributed noise, equal to both components
n = randn(r,c);
im = im + n;
re = re + n;

% Round result to nearest int
im = round(im);
re = round(re);

%return new phase
p = (p-atan2(im,re))*AMP;
while sum(p<pi) > 1
    p(p<pi) = p(p<pi)+2*pi;
end
while sum(p>pi) > 1
    p(p>pi) = p(p>pi)-2*pi;
end
