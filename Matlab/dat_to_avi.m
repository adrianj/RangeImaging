% Reads a number of frames in binary format, and creates an avi file.
% Assumes input frames have 'width' pixel line width, 2 taps of 'width'/2 pixels.

%clear all;
clear all;
avi_folder = 'D:/AVIs/test/modFreq_vs_DC/';
%avi_folder = 'D:/ham_oct08/moving/';
%avi_folder = 'D:/ham_oct08/disambig/';
%avi_folder = 'D:/sync/PhD/';

figure;

%colour = [0:1/255:1]';
cmap = colormap(hsv(256));

taps = 2;
fps = 10;
rshape = 0;

width = 160*taps;
height = 120;

inFile = [avi_folder 'test_0.dat'];
outFile = [avi_folder 'test_0.avi'];

flip_vertical = 0;

ppf = width*height;



test = avifile(outFile);
test = set(test, 'fps', fps);
test = set(test, 'Colormap', cmap);
test = set(test, 'Compression', 'None');

n = 1;
Nframes = 1000;
begin_frame =30;

fid = fopen(inFile, 'r');
for frame = 1:Nframes
    
    if feof(fid) == 1
        break
    end

    c = fread(fid, ppf, 'uint16');
    if(length(c) ~= ppf)
        break;
    end
    temp = c;
    
    
    if taps == 2
        tap1 = temp(1:2:end);
        tap2 = temp(2:2:end);
        tap1_r = reshape(tap1, width/2, height)';
        tap2_r = reshape(tap2, width/2, height)';
        my_image = [tap1_r tap2_r];
    else
        my_image = reshape(c, width, height)';
    end
    
    if rshape == 1
        my_image = reshape(my_image', height, width);
    end
    
    
    if flip_vertical == 1
        my_image = my_image(end:-1:1, :);
    end
    
    %pixel_t = [pixel_t  65536-my_image(pixels(:,2)+height*(pixels(:,1)-1))];
    
    % Convert 16 bit values to 8 bit
    my_image = my_image / 256;

    
    
    

    
    if frame >= begin_frame
    %    pixel_t(frame,1) = my_image(81,65);
    %    pixel_t(frame,2) = my_image(65,81);
    %
    
        test = addframe(test, my_image);
    end
    
    fprintf('Frame: %d\tMaxRawPixel: %d\tPixel 0: %d\n', n, max(c), my_image(1,1));
    %figure; imagesc(my_image);
    n = n + 1;

end


fclose(fid);
test = close(test);
%pixel_t = pixel_t / frame;
imagesc(my_image);
%pixel_t = [pixel_t ; zeros(length(pixel_t)*3,2)];
%figure; plot(pixel_t');

%static80_8_88 = pixel_t;

%save static_analysis static* -append;
%figure; plot(abs(fft(pixel_t)));






