% Build Rebecca using calibration box
close all;
path('../',path);
clear all;
set_avi_folder
%avi_folder = 'd:/PhD_Data/';

c = 300e3;
f = 36;
N = 30;

T = 19.999;

% Scale from ranger 16-bit output to actual distance.
du = 1000*150/f;    % du in mm.
scale = du/2^16;


setFileName = 'rebecca15';
setFilePath = sprintf('%s%s/%d_%d_%d_%d_%d/%d_%d_%d',avi_folder, setFileName, f, f, N, N, floor(T*N),0,0,0);

matFile = [setFilePath '_raw'];

load(matFile);

% Do processing related to calibration box.
box = scale*reshape(mean(d_raw,2),width,height)';
box_mid = box(width/2,height/2);
%figure; imagesc(box)


% Process Rebecca herself.
T = 20;
setFilePath = sprintf('%s%s/%d_%d_%d_%d_%d/%d_%d_%d',avi_folder, setFileName, f, f, N, N, floor(T*N),0,0,0);

%setFilename = sprintf('%s%d_%d_%d',avi_folder,0,0,0);
matFile = [setFilePath '_raw'];

load(matFile);

distance = scale*reshape(mean(d_raw,2),width,height)';
amp = reshape(mean(d_raw_r1,2),width,height)';


%figure; imagesc(amp);
%figure; imagesc(distance)
diff = distance-box;
diff2 = distance-box_mid;
d_max = 200;
d_min = -12;

%figure; imagesc(diff2)
%figure; imagesc(diff);
diff(diff>d_max) = d_max;
diff(diff<d_min) = d_min;
diff2(diff2>d_max) = d_max;
diff2(diff2<d_min) = d_min;


d_max = 100;

diff(diff>d_max)=d_max;
diff2(diff2>d_max)=d_max;
%figure; imagesc(diff2)
diff = diff(13:110,53:117);
diff2 = diff2(13:110,53:117);
amp = amp(13:110,53:117);
box = box(13:110,53:117)-box_mid;
offset = 1000;
d_max = d_max+offset;
diff = diff+offset;
diff2 = diff2+offset;
box = box+offset;
d_min = min(min(diff));
d_min2 = min(min(diff2));
d_min = min(d_min,d_min);

%a_min = 20000;
%amp(amp<a_min) = a_min;

PrettifyFigure(10,15,1,0);  
%subplot(1,2,1);
imagesc(diff2,[d_min d_max]);
axis off;
cb = colorbar('location','southoutside');
text (33,118,'distance (mm)','horizontalalignment', 'center')
colormap(jet(256));
print -dtiff -r200 chap7images\rebecca_ugly

PrettifyFigure(10,15,1,0); 
%subplot(1,2,2);
imagesc(10.^(amp./2^16));
axis off;
colorbar('location','southoutside');
colormap(gray(256));
text (33,118,'amplitude (arbitrary units)','horizontalalignment', 'center')

print -dtiff -r200 chap7images\rebecca_amp

PrettifyFigure(10,15,1,0);  
%subplot(1,2,2);
imagesc(box);
axis off;
colorbar('location','southoutside');
text (33,118,'distance (mm)','horizontalalignment', 'center')
colormap(jet(256));
print -dtiff -r200 chap7images\rebecca_flat

PrettifyFigure(10,15,1,0); 
%subplot(1,2,1); 
imagesc(diff,[d_min d_max]);
axis off;
colorbar('location','southoutside');
text (33,118,'distance (mm)','horizontalalignment', 'center')

print -dtiff -r200 chap7images\rebecca_pretty

PrettifyFigure(24,16,1,0);  surf(-diff,10.^(amp./2^16),'edgecolor','none');
view(110,60)
colormap(gray(256))
axis([0 62 0 110 -d_max -d_min]);
print -dtiff -r200 chap7images\rebecca_3dpretty
PrettifyFigure(24,16,1,0);  surf(-diff2,'edgecolor','none');
colormap(gray(256))
view(130,50)
axis([0 62 0 110 -d_max -d_min]);

%print -dtiff -r200 d:\sync\phd\documents\thesis\chap7images\rebecca_ugly

