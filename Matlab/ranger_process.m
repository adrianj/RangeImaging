% Processes a given input .dat file containing binary encoded frames of
% raw ranger data.

clear all;
close all;
avi_folder = 'D:/AVIs/test/freq_testing/';
files = 'test';

inFilename = [avi_folder files '_combined.dat'];
inFile = fopen(inFilename, 'r');

fps_in = 10;            % input frames per second

fm1 = 30e6;          % modulation frequency
fpb1 = 4;                % frames per beat
fd1 = fps_in / fpb1;                % diff frequency
fpo1 = fpb1*1;            % input frames per output frame. Should be multiple of fpb
fps_out = fps_in * fpo1; % output frames per second
width = 160;            % image width
height = 120;           % image height

do_subtract = 1;    % option for subtracting left frame from right frame (2 for yes, 1 for no) - necessary when processing raw outputs of PMD.
do_disambig = 0;
taps = 1;
ppf = width*height*taps;     % pixels per frame
nFrames = 1000;        % Number of frames to process. Large number just continues to end of fle
ignoreFrames = 0;

distance_offset1 = 0;

fm2 = 100e6/3;
fpb2 = 4;
fpo2 = fpb2*2;

distance_offset2 = 0;

offset1 = 1.65; % see table
offset2 = 0.39;
c = 299792458;    % Speed of light.

% Phase Offsets - I haven't worked out the calculation for them
% 40 MHz, 6 fpb = 0.52 with 33 MHz, 0.41 with 6.66 MHz.
% 33 MHz, 3 fpb = 0.39 with 40 MHz.
% 6.6Mhz, 3 fpb = -0.03 with 40 MHz.
% 40 MHz, 4 fpb = 0.66.
% 33 MHz, 4 fpb = 0.52
% 6.6MHz, 8 fpb = -0.07
% 6.6MHz, 4 fpb = -0.09

d_wave = zeros(ppf, 1);

wave_index1 = 1;
frame_count1 = 1;
d_real1 = 0;
d_imag1 = 0;
d_real2 = 0;
d_imag2 = 0;

distance_1_average = zeros(height,width*taps/do_subtract);
distance_2_average = zeros(height,width*taps/do_subtract);

% disambiguation stuff
max_distance = 12000;
M = 5;%1 / gcd(6,1);
N = 6;% / gcd(6,1);
weight = 0.5;  % weighting of fm1 = weight, fm2 = 1-weight.

wave_index2 = 1;
frame_count2 = 1;



tp = [110 80 ; 50 60 ; 75 70 ; 100 50];
% This 3d vector will grow with frames.
raw_data = zeros(16,length(tp),1);
% data is in the form (<pixel/16>,<test point>,<frame num>)
phase_data = raw_data;
mag_data = raw_data;


d_actual = [1000 2500 4750 5500 8500 10000];
labels = cell(1,length(d_actual));
for i = 1:length(d_actual)
    labels{i} = sprintf('%d mm',d_actual(i));
end

proc_count1 = 0;
raw_count = 0;

for n = 1:nFrames+ignoreFrames
    
    % Get raw pixels from file
    if (feof(inFile) == 1)
        break;
    end
    d_raw_read = fread(inFile, ppf, 'int16');
    if(length(d_raw_read) ~= ppf)
        break;
    end
    if n > ignoreFrames
        
        if taps == 2
            % These two lines for Cameralink system
            tap1 = reshape(d_raw_read(1:2:end),width,height)';
            tap2 = reshape(d_raw_read(2:2:end),width,height)';
            % These two lines for PMD
            tap1 = reshape(d_raw_read(1:2:end),width,height)';
            tap2 = reshape(d_raw_read(2:2:end),width,height)';
            tap1(1) = tap1(2);
            tap2(1) = tap2(2);
            %figure; imagesc(tap1);
        
            if do_subtract == 2
                d_raw = tap1 - tap2;
            else
                d_raw = [tap1 tap2];
            end
        else
            d_raw = reshape(d_raw_read,width,height)';
            %d_raw = [d_raw(:,1:2:end) d_raw(:,2:2:end)];
            %figure; imagesc(d_raw);
        end
        d_raw = cast(d_raw, 'double');
        d_raw(1) = d_raw(2);
        %figure; imagesc(d_raw);
        
        
        % Pixels of interest
        %poi = [d_raw(tp1) d_raw(tp2) d_raw(tp3) d_raw(tp4) d_raw(tp5) d_raw(tp6)];
        %raw_data = [raw_data ; poi];
        
        raw_count = raw_count + 1;
            for ii = 1:length(tp)
                poi = d_raw(tp(ii,2)-1:tp(ii,2)+2,tp(ii,1)-1:tp(ii,1)+2);
                raw_data(:,ii,raw_count) = poi(:);
            end
        
        
        
        % Process 1 Hz frequency
        d_cos1 = cos((2*pi*(wave_index1-1)/fpb1)+offset1);
        d_sin1 = sin((2*pi*(wave_index1-1)/fpb1)+offset1);
        
        d_real_new1 = d_raw * d_cos1;
        d_imag_new1 = d_raw * d_sin1;
        
        d_real1 = d_real_new1 + d_real1;
        d_imag1 = d_imag_new1 + d_imag1;
        
        % Increment index into sin and cos LUTs
        if wave_index1 == fpb1
            wave_index1 = 1;
        else
            wave_index1 = wave_index1 + 1;
        end
        if frame_count1 == fpo1
            
            d_atan1 = atan2(d_imag1, d_real1);
            d_atan1 = d_atan1 + offset1;
            d_atan1(d_atan1<0) = d_atan1(d_atan1<0) + 2*pi;
            %d_atan1(d_atan1>pi) = d_atan1(d_atan1>pi) - pi;
            
            % Find atan of accumulators
            d_distance1 = d_atan1 * 1000 * c / (4 * pi * fm1);
            distance_1_average = distance_1_average + d_distance1;
            
            d_mag = sqrt(d_imag1.^2 + d_real1.^2)/2;
            %figure; imagesc(d_mag);
            
            frame_count1 = 1;
            %poi1 = [d_distance1(tp1) d_distance1(tp2) d_distance1(tp3) d_distance1(tp4) d_distance1(tp5) d_distance1(tp6)];
            %proc_data1 = [proc_data1 ; poi1];
            %figure; imagesc(d_distance1);
            proc_count1 = proc_count1 + 1;
            for ii = 1:length(tp)
                poi = d_distance1(tp(ii,2)-1:tp(ii,2)+2,tp(ii,1)-1:tp(ii,1)+2);
                phase_data(:,ii,proc_count1) = poi(:);
                poi = d_mag(tp(ii,2)-1:tp(ii,2)+2,tp(ii,1)-1:tp(ii,1)+2);
                mag_data(:,ii,proc_count1) = poi(:);
            end
            
            d_real1 = 0;
            d_imag1 = 0;
            
        else
            frame_count1 = frame_count1 + 1;
        end
        
        % Process 2 Hz frequency
        d_cos2 = cos((2*pi*(wave_index2-1)/fpb2)+offset2);
        d_sin2 = sin((2*pi*(wave_index2-1)/fpb2)+offset2);
        d_real_new2 = d_raw * d_cos2;
        d_imag_new2 = d_raw * d_sin2;
        
        %         if wave_index2 == 1
        %             d_real_old2 = 0;
        %             d_imag_old2 = 0;
        %         else
        %             d_real_old2 = d_real_new2;
        %             d_imag_old2 = d_imag_new2;
        %         end
        
        d_real2 = d_real_new2 + d_real2;
        d_imag2 = d_imag_new2 + d_imag2;
        
        % Increment index into sin and cos LUTs
        if wave_index2 == fpb2
            wave_index2 = 1;
        else
            wave_index2 = wave_index2 + 1;
        end
        if frame_count2 == fpo2 && do_disambig == 1
            
            d_atan2 = atan2(d_imag2, d_real2);
            d_atan2 = d_atan2 + offset2;
            d_atan2(d_atan2<0) = d_atan2(d_atan2<0) + 2*pi;
            
            % Find atan of accumulators
            d_distance2 = d_atan2 * 1000 * c / (4 * pi * fm2);
            
            distance_2_average = distance_2_average + d_distance2;
            
            frame_count2 = 1;
            poi2 = [d_distance2(tp1) d_distance2(tp2) d_distance2(tp3) d_distance2(tp4) d_distance2(tp5) d_distance2(tp6)];
            
            proc_count2 = proc_count2 + 1;
            for ii = 1:length(tp)
                poi = d_distance2(tp(ii,2)-1:tp(ii,2)+2,tp(ii,1)-1:tp(ii,1)+2);
                proc_data2(:,ii,proc_count2) = poi(:);
            end
            
            d_real2 = 0;
            d_imag2 = 0;
            
            % Begin disambiguation of test points.
            if do_disambig == 1
                dd_1 = poi1;
                dd_2 = poi2;
                
                r = ones(size(dd_1))*max_distance;
                difference = r + c/(2*fm1);
                pass = r;
                
                d_2 = dd_2;
                
                for n = 1:M
                    
                    d_1 = dd_1;
                    
                    for m = 1:N
                        pass = (abs(d_1 - d_2) < difference) & d_1 < max_distance & d_2 < max_distance;
                        difference = difference + abs(d_1 - d_2) .* pass - difference .* pass;
                        weighted_r = (d_1 .* pass * weight) + (d_2 .* pass * (1-weight));
                        r = r + weighted_r - r .* pass;
                        d_1 = d_1 + c*500/fm1;
                    end
                    
                    d_2 = d_2 + c*500/fm2;
                    
                end
                proc_data_db = [proc_data_db ; r];
            end
            
            
        else
            frame_count2 = frame_count2 + 1;
        end
        
    end
end

%raw_data = squeeze(mean(raw_data))';
%proc_data1 = squeeze(mean(proc_data1))';
%proc_data2 = squeeze(mean(proc_data2))';
%proc_data_db = squeeze(mean(proc_data_db))';
save([files '.mat'], 'raw_data','phase_*','mag_*','tp','fm*','fpb*');

inFile = fclose(inFile);
%return;
% To refresh: data is in the form (<pixel/16>,<test point>,<frame num>)
mag_mean = squeeze(mean(mag_data,1));
mag_mean = mean(mag_mean');
phase_mean = squeeze(mean(phase_data,1));
phase_mean = mean(phase_mean');


%figure; plot(mag_mean);

save([files '.mat'], 'raw_data','phase_*','mag_*','tp','fm*','fpb*');
%figure; plot(raw_data);
%figure; plot(proc_data1);
%figure; imagesc(d_distance1);
   
%save([files '.mat'], 'raw_data','proc_data*','mean*','labels','d_actual','std*','fm*','fpb*');

 
 %colormap(gray);
 %colorbar('southoutside');
 %PrettifyFigure(h,800,800);
 %colormap(1-gray); colorbar('southoutside');

%figure; plot(proc_data1);
%axis([1,length(tp1),0,c*500/fm1]);
%title([inFilename '1 Hz pixels: distance (mm)']); legend(labels);

%figure; plot(proc_data2);
%axis([1,length(tp2),0,c*500/fm2]);
%title([inFilename '2 Hz Pixels: distance (mm)']); legend(labels);

%figure; plot(proc_data_db);
%axis([1,length(tp2),0,max_distance]);
%title([inFilename '2 Hz Pixels: distance (mm)']); legend(labels);
%fprintf('\nmean raw data\n');
%fprintf('%5.5f\n', mean(raw_data));
%fprintf('\nstd deviation raw data\n');
%fprintf('%5.5f\n', std(raw_data));
%fprintf('\nproc1\n');
%fprintf('%5.5f\n', mean1);
%fprintf('\nproc2\n');
%fprintf('%5.5f\n', mean2);
%fprintf('\nproc_db\n');
%fprintf('%5.5f\n', mean_db);

return;

% Begin disambiguation of entire averaged frame

dd_1 = distance_1_average;
dd_2 = distance_2_average;

r = ones(size(dd_1))*max_distance;
difference = r + c/(2*fm1);
pass = r;

d_2 = dd_2;
weight = 1;

for n = 1:M
    
    d_1 = dd_1;
    
    for m = 1:N
        pass = (abs(d_1 - d_2) < difference) & d_1 < max_distance & d_2 < max_distance;
        difference = difference + abs(d_1 - d_2) .* pass - difference .* pass;
        weighted_r = (d_1 .* pass * weight) + (d_2 .* pass * (1-weight));
        r = r + weighted_r - r .* pass;
        d_1 = d_1 + c*500/fm1;
    end
    
    d_2 = d_2 + c*500/fm2;
    
end
scrsz = get(0,'ScreenSize');
fig = figure('Position',[0 scrsz(4)/2.5 scrsz(3)/3.5 scrsz(4)/3.5]); colorbar; colormap(gray)
set(fig,'color',[1 1 1]);
imagesc(dd_1/1000); colorbar('eastoutside'); axis off; %title('Ambiguous Range (m): 40 MHz');
fig = figure('Position',[0 scrsz(4)/2.5 scrsz(3)/3.5 scrsz(4)/3.5]); colorbar; colormap(gray)
set(fig,'color',[1 1 1]);
imagesc(dd_2/1000); colorbar('eastoutside'); axis off; %title('Ambiguous Range (m): 33 MHz');

fig = figure('Position',[0 scrsz(4)/2.5 scrsz(3)/3.5 scrsz(4)/3.5]); colorbar; colormap(gray)
set(fig,'color',[1 1 1]);
imagesc(r/1000); colorbar('eastoutside'); axis off; %title('Unambiguous Range (m): 40 + 33 MHz'); 



%fig = figure('Position',[10 60 scrsz(3)/1.2 scrsz(4)/1.2]);
%h = surf(1:160, 1:120, max_distance-r, r); title('Unambiguous Range'); colorbar; colormap(gray)
%axis([1,160,1,120,min(min(r)),max(max(r)),min(min(r)),max(max(r))]);
%view(-20,290);


