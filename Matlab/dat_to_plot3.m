% Reads up to a given frame number and generates a 3d plot of that frame.
% Used for ICST 2008 and LNEE book chapter.

clear all;


frame_num = 40;

width = 128;

inFile = 'D:\AVIs\test\action_125fps_5fpb.dat';
outFilename = 'D:\AVIs\test\action_125fps_5fpb_rng.avi';
% setting this to 1 will generate an avi of the image/surf plots.
outputAVI = 0;
if outputAVI == 1
    outFile = avifile(outFilename, 'FPS', 8);
end

%scrsz = get(0,'ScreenSize');
%fig = figure('Position',[10 scrsz(4)/2.5 scrsz(3)/1.1 scrsz(4)/2])
fig = figure;
PrettifyFigure(fig, 800,400);

%cmap = colormap(hsv(256));
cmap = gray;

n = 1;

cutoff = 0.3e4;

pixel1 = [];
pixel2 = [];
pixel3 = [];
pixel4 = [];
pixel5 = [];
pixel6 = [];

fid = fopen(inFile, 'r');
while(n <= frame_num)

    if feof(fid) == 1
        break;
    end

    c = fread(fid, 16384, 'uint16');
    if(length(c) ~= 16384)
        break;
    end

    tap1 = c(1:2:end);
    tap2 = c(2:2:end);

    tap1_r = reshape(tap1, 64, length(tap1)/64)';
    tap2_r = reshape(tap2, 64, length(tap2)/64)';

    %my_image = [tap2_r(:,end) tap1_r(:,1:end-1) tap1_r(:,end) tap2_r(:,1:end-1)];
    %my_image = [tap1_r tap2_r(:,2:end) tap2_r(:,1)];
    my_image = [tap1_r tap2_r];
    
    % my_image(128-vertical, horizontal)
    % for action_125fps: pendulum at ~(80,64), bear's head (80, 100)
    % space above bear (cardboard) (90,100), turntable (50, 100)
    % Back wall (110, 70), paper start(70,60), paper finish(45,60)
    % paper middle(57,60);
    % 1 = (84,102), 2 = (110,65), 3 = (68,60)
    % 4 = (54,60), 5 = (40,60), 6 = (26,60)
    vert = 90;
    horz = 110;
    temp = 0;
    for ii = 0:2
        for jj = 0:2
            temp = temp + my_image(vert+ii, horz+jj);
        end
    end
    pixel1 = [pixel1 my_image(94,102)];
    pixel2 = [pixel2 my_image(110,65)];
    pixel3 = [pixel3 my_image(68,60)]; % 128-66 = 60
    pixel4 = [pixel4 my_image(56,60)]; % 128 - 56 = 72
    pixel5 = [pixel5 my_image(44,60)]; % 128 - 44 = 84
    pixel6 = [pixel6 my_image(80,65)];
    
    for i = 1:128
        for j = 1:128
            if my_image(j,i) < cutoff
                my_image(j,i) = my_image(j,i) + 2^16;
            end
            if (j-width/2)^2 > ((width/2)-4)^2 - (i-width/2)^2
                my_image(j,i) = 0;
            end
            %if j > 90
            %    my_image(j,i) = 0;
            %end
        end
    end

    clf;
    subplot(1,2,1);
    s = sprintf('Frame: %d', n);
    %h = surf(1:128, 128:-1:1, my_image, 'EdgeColor', 'none'); title(s);
    flip_image = my_image(128:-1:1, 128:-1:1);
    h = imagesc(flip_image);
    %axis([1,128,1,128,1+cutoff,2^16+cutoff,1+cutoff,2^16+cutoff]);
    %view(180,90);
    
    subplot(1,2,2);
    s = sprintf('Frame: %d', n);
    h = surf(1:128, 128:-1:1, my_image, 'EdgeColor', 'none'); title(s);
    axis([1,128,1,128,1+cutoff,2^16+cutoff,1+cutoff,2^16+cutoff]);
    view(-190,70);
    %view(0,90);
    colormap(hsv);
    
    
    %figure; imagesc(flip_image);
    %colormap(hsv);
    
    pause(0.05);
    
    fprintf('Frame: %d\n', n);
    rect = [120 25 960 480];
    if n == 1
        image1 = flip_image;
    end
    n = n + 1;
    if outputAVI == 1
        F = getframe(fig, rect);
        outFile = addframe(outFile, F);
    end
    
end
 
if outputAVI == 1
    outFile = close(outFile);   
end
fclose(fid);

pixel1 = 2*pi - pixel1*2*pi/2^16;
pixel2 = 2*pi - pixel2*2*pi/2^16;
pixel3 = 2*pi - pixel3*2*pi/2^16;
pixel4 = 2*pi - pixel4*2*pi/2^16;
pixel5 = 2*pi - pixel5*2*pi/2^16;
pixel6 = 2*pi - pixel6*2*pi/2^16;

scale = 3e8/(4*pi*40e6);
pixel1 = pixel1*scale;
pixel2 = pixel2*scale;
pixel3 = pixel3*scale;
pixel4 = pixel4*scale;
pixel5 = pixel5*scale;
pixel6 = pixel6*scale;
pixel_ave = (pixel1+pixel2+pixel3+pixel4)/4;
d_distance = image1 * scale*2*pi/2^16;
h = figure; imagesc(max(max(d_distance))-d_distance);
axis off;
colormap(gray); colorbar('southoutside');
%PrettifyFigure(h,640,600);

h = figure; plot(1:frame_num,pixel1, '-x',1:frame_num,pixel2,'-*',1:frame_num,pixel3,'-s',1:frame_num,pixel4,'-o',1:frame_num,pixel5,'-h'); 
%h = figure; plot(1:frame_num,pixel1, '-x',1:frame_num,pixel3,'-s',1:frame_num,pixel4,'-o',1:frame_num,pixel5,'-h'); 
%figure; plot(1:frame_num, pixel_ave)
axis([1 frame_num 0 scale*2*pi]); legend('1','2','3','4','5', 'location', 'southwest');
xlabel('frame number'); ylabel('distance (m)');
%PrettifyFigure(h, 640, 480);

mean_pixel1 = mean(pixel1)
stdev_pixel1 = std(pixel1)
mean_pixel2 = mean(pixel2)
stdev_pixel2 = std(pixel2)

% print mean error from a linear fit. Not exactly true is it...
x = 1:length(pixel1);
stdev_pixel1_fitted = std(polyval(polyfit(x,pixel1,1),x)-pixel1)
stdev_pixel2_fitted = std(polyval(polyfit(x,pixel2,1),x)-pixel2)


%colormap(hsv(256)); image(my_image/256);
%figure; plot(my_image);
%figure;


%figure; plot(my_image);



