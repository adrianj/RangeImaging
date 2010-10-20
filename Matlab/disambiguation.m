% This will give arbitrary results, but the algorithm is sound

f1 = 50e6;
f2 = 30e6;
c = 3e8;
k1 = c/(2*f1)*2^15;
k2 = c/(2*f2)*2^15;

ppf = 128*128; % pixels per frame

theta1 = [0:ppf-1]*4;
theta2 = floor((cos([1:ppf]*2*pi/(ppf+1))+1)*2^15);

m1 = theta1*k1/(2^31);
m2 = theta2*k2/(2^31);

%figure; plot(1:ppf,m1,1:ppf,m2);

k1 = c/(2*f1);
k2 = c/(2*f2);

theta1 = [0:ppf-1]*2*pi/ppf;
theta2 = (cos([1:ppf]*2*pi/ppf)+1)*pi;
m1 = theta1*k1/(2*pi);
m2 = theta2*k2/(2*pi);

figure; plot(1:ppf,m1,1:ppf,m2);

d = ones(ppf,1)*2^16;
min_diff = ones(ppf,1)*2^16;

% this is algorithm in software.
for i = 1:ppf
    d1 = m1(i);

    for n1 = 0:floor(k1)-1
        d2 = m2(i);
        for n2 = 0:floor(k2)-1
            %d1 = m1(i) + n1*k1;
            %d2 = m2(i) + n2*k2;
            diff = abs(d1 - d2);
            if diff < min_diff(i)
                d(i) = (d1+d2)/2;
                min_diff(i) = diff;
            end
            d2 = d2 + k2;
        end
        d1 = d1 + k1;
    end
end

%figure; plot(1:ppf,min_diff,1:ppf,d);
%figure; plot(d)

d = ones(ppf,1)*k1*k2;
min_diff = ones(ppf,1)*k1*k2;

% Hardware algorithm unrolls loops.
for i = 2000%1:ppf
    
    d1 = m1(i)
    d2 = m2(i)
    
    p1 = theta1(i)
    p2 = theta2(i)
    
    % Use Chinese Remainder Theorem
    % First convert 
    
    diff = abs(d1-d2);
    if diff < min_diff(i)
        d(i) = (d1+d2)/2;
        min_diff(i) = diff;
    end
    d2 = d2 + k2;
    diff = abs(d1-d2);
    if diff < min_diff(i)
        d(i) = (d1+d2)/2;
        min_diff(i) = diff;
    end
    d2 = d2 + k2;
    diff = abs(d1-d2);
    if diff < min_diff(i)
        d(i) = (d1+d2)/2;
        min_diff(i) = diff;
    end
    d1 = d1 + k1;
    d2 = m2(i);
    diff = abs(d1-d2);
    if diff < min_diff(i)
        d(i) = (d1+d2)/2;
        min_diff(i) = diff;
    end
    d2 = d2 + k2;
    diff = abs(d1-d2);
    if diff < min_diff(i)
        d(i) = (d1+d2)/2;
        min_diff(i) = diff;
    end
    d2 = d2 + k2;
    diff = abs(d1-d2);
    if diff < min_diff(i)
        d(i) = (d1+d2)/2;
        min_diff(i) = diff;
    end
    d1 = d1 + k1;
    d2 = m2(i);
    diff = abs(d1-d2);
    if diff < min_diff(i)
        d(i) = (d1+d2)/2;
        min_diff(i) = diff;
    end
    d2 = d2 + k2;
    diff = abs(d1-d2);
    if diff < min_diff(i)
        d(i) = (d1+d2)/2;
        min_diff(i) = diff;
    end
    d2 = d2 + k2;
    diff = abs(d1-d2);
    if diff < min_diff(i)
        d(i) = (d1+d2)/2;
        min_diff(i) = diff;
    end
    d(i)
end


%figure; plot(min_diff);
%figure; plot(d)