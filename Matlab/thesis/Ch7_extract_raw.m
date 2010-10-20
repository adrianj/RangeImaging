% Extracts just raw data into a MAT file.
close all;
clear all;
set_avi_folder;
N = 30;
f = 36;
t = 20*N;
show_frames = 0;
%setFileName = 'videoRate';
setFileName = 'rebecca15';

width = 160;
height = 120;
ppf = width*height;

tap1_type = 'uint16';
taps = 2;
tap2_type = 'uint16';


proc_count = 0;
Ts_a = floor(floor((t*1000)/N)/1000*N);
avi_folder = sprintf('%s%s/%d_%d_%d_%d_%d/', avi_folder,setFileName, f, f, N, N, Ts_a);


files = sprintf('%s',avi_folder);

setFilename = sprintf('%s%d_%d_%d',avi_folder,0,0,0);
inFilename = sprintf('%s.dat',setFilename);

fprintf('%s\n', inFilename);
matFile = [setFilename '_raw'];

inFile = fopen(inFilename, 'r');

nFrames = 1000;
ignoreFrames = 2;
d_raw = zeros(ppf,nFrames);
if taps == 2
    inFilename1 = sprintf('%s_r1.dat',setFilename);
    inFile1 = fopen(inFilename1, 'r');
    
    d_raw_r1 = d_raw;
end
proc_count = 0;

if show_frames == 1
   PrettifyFigure(44,24,1,0); 
end

for i=1:nFrames
    % Get raw pixels from file
    if (feof(inFile) == 1)
        break;
    end
    
    d_raw_read = fread(inFile, ppf, tap1_type);
    if(length(d_raw_read) ~= ppf)
        break;
    end
    if taps == 2
        d_raw_read_r1 = fread(inFile1, ppf, tap2_type);
    end
    if i > ignoreFrames
        proc_count = proc_count + 1;
        d_raw(:,proc_count) = d_raw_read;
        if taps == 2
            d_raw_r1(:,proc_count) = d_raw_read_r1;
        end
        
    end
    
    if show_frames == 1
        if taps == 2
            subplot(1,2,2);
            imagesc(reshape(d_raw_read_r1,width,height)',[0 40000]);
            subplot(1,2,1);
        end
        imagesc(reshape(d_raw_read,width,height)');
        pause(0.03);
    end
    
end

d_raw = d_raw(:,1:proc_count);


save(matFile,'d_raw','N','height','t','f','width','proc_count');


figure; imagesc(mod(reshape(mean(d_raw,2),width,height)',5000))

if taps == 2
    d_raw_r1 = d_raw_r1(:,1:proc_count);
    figure; imagesc(reshape(mean(d_raw_r1,2),width,height)');
    save(matFile,'-append','d_raw_r1');
end
    