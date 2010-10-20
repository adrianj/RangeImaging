% Produce a test avi of simple waveforms, with magnitudes not too small.
% Creates a simple test pattern frame.

avi_folder = 'D:/AVIs';

fpb = 4;
Nframes = 40;
h = 120; w = 160;

theta = 0;
theta_d = 2*pi/fpb;
theta_d2 = 2*pi/16;

outFilename = [avi_folder '/test/testpattern_19k.dat'];
outFile = fopen(outFilename, 'w');

frame = cast(zeros(1,h*w),'uint16');

p1 = zeros(1,Nframes);
p16000 = zeros(1,Nframes);

for i = 1:Nframes
    
    for n = 1:h
       for m = 1:w
           
           temp = sin(2*pi/fpb + 2*pi*m/w + theta) + 1.001; 
            temp = 16*15*floor(n*temp)+32;
            noise = randn*100+200;
            if noise < 0
                noise = 0;
            end
            temp = temp + noise;
            frame(((n-1)*w)+m) = cast(temp, 'uint16');
       end
    end
    
    p1(i) = frame(1);
    p16000(i) = frame(16000);
    fwrite(outFile, frame, 'uint16');
    fprintf('Frame %d\n', i);
    theta = theta + theta_d;
    
    if mod(i,fpb) == 0
        theta = theta + theta_d2;
    end
    
end

figure; imagesc(frame); colormap(gray);
temp = sin(2*pi*i/fpb + 2*pi*m/w + theta)+1.001;

figure; plot(p1);
figure; plot(p16000);

outFile = fclose(outFile);