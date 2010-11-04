% Build Rebecca using calibration box
close all;
clear all;
set_avi_folder;
outpath = 'chap7images\';

c = 300e3;
f = 24;
N = 3;

T = 20;

% Scale from ranger 16-bit output to actual distance.
du = 150/f;    % du in mm.
scale = du/2^16;

setFileName = 'videoRate';
setFilePath = sprintf('%s%s/%d_%d_%d_%d_%d/%d_%d_%d',avi_folder, setFileName, f, f, N, N, floor(T*N),0,0,0);

matFile = [setFilePath '_raw'];

rngAVI = [avi_folder setFileName '_rng.avi'];
ampAVI = [avi_folder setFileName '_amp.avi'];

load(matFile);



distance = d_raw*scale;
amp = d_raw_r1;
amp(amp<10000)=10000;

hand_index = 60;
hand_d = reshape(distance(:,hand_index),width,height)';
hand_a = reshape(amp(:,hand_index),width,height)';
imagesc(hand_a(2:end,:));
hand_moving_index = 69;
back_index = 99;
sit_index = 160;

% PrettifyFigure(24,18,1,0);
% imagesc(hand_d(2:end,:),[0 7]);
% axis off;
% PrettifyFigure(24,18,1,0);
% imagesc(10.^(hand_a(2:end,:)./2^16));
% PrettifyFigure(24,18,1,0);
% imagesc(hand_a(2:end,:));
% axis off;
% 
% PrettifyFigure(24,18,1,0);
% imagesc(hand_d(2:end,:),[0 7]);
% axis off;

begin_walk_index = 206;
end_walk_index = 244;
PrettifyFigure(24,18,1,0);
axis off;
walk_index = begin_walk_index:5:end_walk_index;
for i = 1:length(walk_index)
    PrettifyFigure(24,18,1,0);
    %subplot(length(walk_index)/2,2,i);
    imagesc(reshape(distance(:,walk_index(i)),width,height)',[0 5]);
    fstring = sprintf('frame_%d',i);
    colormap(jet(256));
    axis off;
    print('-dtiff','-r200',[outpath fstring]);
    %title(fstring);
    
    fprintf('%s\n',fstring);
    pause(0.2);
end

tp_w = 21;
tp_h = 11;
tp_s1 = [45 96];
tp_s2 = [5 85];
last_frame = reshape(distance(:,walk_index(end)),width,height)';
last_frame(tp_s1(1):tp_s1(1)+tp_w-1,tp_s1(2)) = 0;
last_frame(tp_s1(1):tp_s1(1)+tp_w-1,tp_s1(2)+tp_w-1) = 0;
last_frame(tp_s2(1):tp_s2(1)+tp_w-1,tp_s2(2)) = 0;
last_frame(tp_s2(1):tp_s2(1)+tp_w-1,tp_s2(2)+tp_w-1) = 0;
last_frame(tp_s1(1):tp_s1(1)+tp_w-1,tp_s1(2)+tp_h-1) = 0;
last_frame(tp_s2(1):tp_s2(1)+tp_w-1,tp_s2(2)+tp_h-1) = 0;

last_frame(tp_s1(1),tp_s1(2):tp_s1(2)+tp_w-1) = 0;
last_frame(tp_s1(1)+tp_w-1,tp_s1(2):tp_s1(2)+tp_w-1) = 0;
last_frame(tp_s2(1),tp_s2(2):tp_s2(2)+tp_w-1) = 0;
last_frame(tp_s2(1)+tp_w-1,tp_s2(2):tp_s2(2)+tp_w-1) = 0;
last_frame(tp_s1(1)+tp_h-1,tp_s1(2):tp_s1(2)+tp_w-1) = 0;
last_frame(tp_s2(1)+tp_h-1,tp_s2(2):tp_s2(2)+tp_w-1) = 0;
PrettifyFigure(24,18,1,0);
imagesc(last_frame,[0 5]);
fstring = sprintf('frame_%d',length(walk_index));
    colormap(jet(256));
    axis off;
    print('-dtiff','-r200',[outpath fstring]);



axis off;
N = 5000;
PrettifyFigure(18,3,1,0);
imagesc([-1:N]);
colormap(jet(256));
set(gca,'YTick',[],'XTick',[1 1000 2000 3000 4000 5000],'XTickLabel',[0 1000 2000 3000 4000 5000]);
text(N/2, 2.2,'distance (mm)','horizontalalignment','center');
print('-dtiff','-r200',[outpath 'colorbar']);


PrettifyFigure(20,13,1,0);

tp = zeros(tp_w*tp_w,proc_count);
% Write AVI
avi_r = avifile(rngAVI);
avi_r = set(avi_r, 'fps', 17);
avi_r = set(avi_r, 'Colormap', jet(256));
avi_r = set(avi_r, 'Compression', 'None');
avi_a = avifile(ampAVI);
avi_a = set(avi_a, 'fps', 17);
avi_a = set(avi_a, 'Colormap', gray(256));
avi_a = set(avi_a, 'Compression', 'None');


for i = 1:proc_count
d = reshape(distance(:,i),width,height)';
avi_r = addframe(avi_r, d/5*256);
a = reshape(amp(:,i),width,height)';
avi_a = addframe(avi_a, a/max(max(a))*256);
t = d(tp_s1(1):tp_s1(1)-1+tp_w,tp_s1(2):tp_s1(2)-1+tp_w);
tp(:,i) = t(:);
end

avi_r = close(avi_r);
avi_a = close(avi_a);

figure;plot(tp');
sd = std(tp,0,2)*1000;
me = mean(tp,2)*1000;
figure; plot(sd);
fprintf('Mean Sdev for Target 2: %3.3f mm +- %3.3f (~%3.2f%%)\n',mean(sd), std(sd),100*mean(sd)/mean(me));
tp_w = 20;
tp_start = 70;
tp = zeros(tp_w*tp_w,proc_count-tp_start+1);

for i = tp_start:proc_count
d = reshape(distance(:,i),width,height)';
t = d(tp_s2(1):tp_s2(1)-1+tp_w,tp_s2(2):tp_s2(2)-1+tp_w);
tp(:,i-tp_start+1) = t(:);
end

figure;plot(tp');
sd = std(tp,0,2)*1000;
me = mean(tp,2)*1000;
figure; plot(sd);
fprintf('Mean Sdev for Target 2: %3.3f mm +- %3.3f (~%3.2f%%)\n',mean(sd), std(sd),100*mean(sd)/mean(me));


return;