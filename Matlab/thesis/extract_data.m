% Extracts data from raw .dat files at specified test points.
% Tries to read the set file for paramaters.
% Appends data to .mat file produced by getSetParams

clear all;
%close all;
set_avi_folder;
showPhaseMag = 1;
outputAVI = 0;

estimatedCapturingTime =  39 * 13 * 1 * 1 * 3 * 50*120/1000;
%countDown(estimatedCapturingTime);

p_width = 40;
width = 160;
height = 120;
start_row = 0;
start_column = 0;
taps = 1;
do_subtract = 2;

setFileName = 'Lb310_Jul23_box25_fullscreen';   % 160x120, taps=1, do_sub=2.


Ns_1 = [24];
%Ns_2 = [120];
Ns_2 = Ns_1;
%Fs_1 = [1 2 4 6 8 10 12 14 16 18 19 20 21 22 23 24 26 28 30 32 34 36 38 40 42 44 46 48 50 52 54 56 58 60 62 64 66 68 70];
%Fs_1 = [26 28 30 32 34 36 38 40 42 44 46 48 50 52 54 56 58 60 62 64 66 68 70];
Fs_1 = [24];%1 4 10 20];% 4 10 20 30 40 50];
Fs_2 = Fs_1;
Ts = [1001];%16.667 20 25 33.334 40 50 66.6667];%5 7.5 10 12.5 15 20 25 30 35 40 50 60 75];
Rs = 0;
Ps_1_length = 1;
Ps_2_length = 1;

% Test locations in form [x1 y1 ; x2 y2 ; x3 y3 ; ...];
% Test locations actual distance in mm
%tp = [32 28];%73 56 ; 55 56 ; 114 9 ; 100 9 ; 28 30 ; 42 30 ; 72 30 ; 61 30 ; 48 14 ; 60 14 ; 83 16 ; 73 16];
tp = [35 41];
%tp = [width/2 height/2];
capture_all_raw = 0;

if capture_all_raw == 1
    max_frames = 192;
    all_raw_frames = zeros(height, width, max_frames);
end
%tp(:,1) = tp(:,1) - start_column;
%tp(:,2) = tp(:,2) - start_row;

tp_distance_actual = [2500];% 3745 3745 5005 5005 6253 6253 7499 7499 8752 8752];


verbose = 1;

frame0 = 0;
frame1 = 0;
frame2 = 0;
frame3 = 0;
for f = 1:length(Fs_1)
    for n = 1:length(Ns_1)
        t = clock;
        fprintf('\nFs = %d+%d, Ns = %d+%d. Current time: %d:%d\t', Fs_1(f), Fs_2(f), Ns_1(n), floor(Ns_2(n)), t(4), t(5));
        
        for t = 1:length(Ts)
            for r = 1:length(Rs)
                Ps_2 = [0:Ps_2_length-1];%[0:floor(Ms_2(f)*80/Fs_2(f)/Ps_2_length):floor(Ms_2(f)*79/Fs_2(f))];
                for p_2 = 1:length(Ps_2)
                    Ps_1 = [0:Ps_1_length-1];%[0:floor(Ms_1(f)*80/Fs_1(f)/Ps_1_length):floor(Ms_1(f)*79/Fs_1(f))];
                    for p_1 = 1:length(Ps_1)
                        % This bizzarre correction from rounding errors in file
                        % nomenclature. Remove for corrected
                        proc_count = 0;
                        Ts_a = Ts(t);
                        Ts_a = floor(floor((Ts(t)*1000)/Ns_1(n))/1000*Ns_1(n));
                        folder = sprintf('%s%s/%d_%d_%d_%d_%d/',avi_folder,setFileName, floor(Fs_1(f)), floor(Fs_2(f)), Ns_1(n), floor(Ns_2(n)), Ts_a);
                        
                        
                        files = sprintf('%s',folder);
                        
                        setFilename = sprintf('%s%d_%d_%d',folder,Rs(r),Ps_2(p_2),Ps_1(p_1));
                        inFilename = sprintf('%s.dat',setFilename);
                        
                        if verbose == 1 fprintf('%s', inFilename); end
                        matFile = setFilename;
                        
                        if outputAVI == 1 && f == 1 && n == 1 && t == 1 && p_1 == 1 && p_2 == 1
                            outAVIFilename = sprintf('%s.avi',files);
                            outAVIFile = avifile(outAVIFilename, 'FPS', 13, 'COLORMAP', gray);
                            fig = PrettifyFigure(8, 6, 0);
                            
                        end
                        inFile = fopen(inFilename, 'r');
                        if do_subtract == 2
                            inFilename1 = sprintf('%s_r1.dat',setFilename);
                            inFile1 = fopen(inFilename1, 'r');
                        end
                        if inFile == -1
                            if verbose == 1 fprintf(': Data file NOT FOUND.\n'); end
                            continue;
                        end
                        if getSetParams(setFilename, matFile) < 0
                            if verbose == 1 fprintf(': Set file NOT FOUND.\n'); end
                            continue;
                        end
                        if verbose == 1 fprintf('.\n'); else fprintf('.'); end
                        load(matFile);
                        
                        ignoreFrames = 2*fpoutput;
                        %nFrames = 100*fpoutput;
                        
                        if fpoutput > 20
                            ignoreFrames = 2*fpoutput;
                        end
                        %ignoreFrames = 0;
                        
                        steps_per_cycle1 = (pll_c_count1_hi + pll_c_count1_lo) * 8;
                        steps_per_cycle2 = (pll_c_count2_hi + pll_c_count2_lo) * 8;
                        
                        
                        % option for subtracting left frame from right frame (2 for yes, 1 for no)
                        % - necessary when processing raw outputs of PMD.
                        
                        % Phase offset in radians. (Get this from 'phase_correction')
                        offset1 = 0 + (phase_step_init1*2*pi/steps_per_cycle1);
                        offset2 = 0 + (phase_step_init2*2*pi/steps_per_cycle2);
                        c = 299792458;    % Speed of light.
                        du1 = 1000*c/(2*fm1);  % unambiguous range in mm
                        du2 = 1000*c/(2*fm2);
                        
                        
                        s = size(tp);
                        raw_data_a = zeros(p_width*p_width,s(1),1);
                        if do_subtract == 2
                            raw_data_b = raw_data_a;
                        end
                        raw_data_sub = raw_data_a;
                        phase_data_1 = raw_data_a;
                        %saturated_p = raw_data_a;
                        magnitude_data_1 = raw_data_a;
                        phase_data_2 = raw_data_a;
                        magnitude_data_2 = raw_data_a;
                        
                        d_atan_sum_1 = 0;
                        d_mag_sum_1 = 0;
                        d_atan_sum_2 = 0;
                        d_mag_sum_2 = 0;
                        %saturated = zeros(width, height);
                        %all_raw_data_a = zeros(height, width, nFrames);
                        %all_raw_data_b = zeros(height, width, nFrames);
                        
                        ppf = width*height*taps;     % pixels per frame
                        
                        wave_index = 1;
                        frame_count = 1;
                        proc_count = 0;
                        raw_count = 0;
                        d_real1 = 0;
                        d_imag1 = 0;
                        d_real2 = 0;
                        d_imag2 = 0;
                        
                        raw_max = -10e5;
                        raw_min = 10e5;
                        
                        for nf = 1:nFrames+ignoreFrames
                            % Get raw pixels from file
                            if (feof(inFile) == 1)
                                break;
                            end
                            if do_subtract == 1
                                d_raw_read = fread(inFile, ppf, 'int16');
                                if(length(d_raw_read) ~= ppf)
                                    break;
                                end
                            elseif do_subtract == 2
                                d_raw_read = fread(inFile, ppf, 'uint16');
                                if(length(d_raw_read) ~= ppf)
                                    break;
                                end
                                d_raw_read1 = fread(inFile1, ppf, 'uint16');
                            end
                            %d_raw_read1 = fread(inFile1, ppf, 'uint16');
                            %fprintf('%d\t%d\n',nf,ignoreFrames);
                            if nf > ignoreFrames
                                
                                if do_subtract == 1
                                    tap1 = reshape(d_raw_read,width,height)';
                                    d_raw = -tap1;
                                elseif do_subtract == 2
                                    tap1 = reshape(d_raw_read,width,height)';
                                    tap2 = reshape(d_raw_read1,width,height)';
                                    d_raw = tap1-tap2;
                                end
                                d_raw(1) = d_raw(2);
                                d_raw = cast(d_raw, 'double');
                                
                                
                                raw_count = raw_count + 1;
                                
                                if capture_all_raw == 1
                                    all_raw_frames(:,:,raw_count) = d_raw;
                                end
                                
                                for ii = 1:s(1)
                                    poi = tap1(tp(ii,2)-p_width/2+1:tp(ii,2)+p_width/2,tp(ii,1)-p_width/2+1:tp(ii,1)+p_width/2);
                                    raw_data_a(:,ii,raw_count) = poi(:);
                                    if do_subtract == 2
                                        poi1 = tap1(tp(ii,2)-p_width/2+1:tp(ii,2)+p_width/2,tp(ii,1)-p_width/2+1:tp(ii,1)+p_width/2);
                                        poi2 = tap2(tp(ii,2)-p_width/2+1:tp(ii,2)+p_width/2,tp(ii,1)-p_width/2+1:tp(ii,1)+p_width/2);
                                        raw_data_a(:,ii,raw_count) = poi1(:);
                                        raw_data_b(:,ii,raw_count) = poi2(:);
                                        raw_data_sub(:,ii,raw_count) = poi1(:)-poi2(:);
                                    else
                                        raw_data_a(:,ii,raw_count) = poi(:);
                                        raw_data_sub(:,ii,raw_count) = poi(:);
                                    end
                                end
                                
                                %d_raw = d_raw - d_raw1;
                                
                                if outputAVI == 1
                                    rect = [44 28 210 190];
                                    raw_image = (d_raw+2^11)/32;
                                    if min(min(raw_image)) < raw_min
                                        raw_min = min(min(raw_image));
                                    end
                                    if max(max(raw_image)) > raw_max
                                        raw_max = max(max(raw_image));
                                    end
                                    figure(200); image(raw_image); colormap(gray);
                                    axis off;
                                    F = getframe(fig);
                                    
                                    outAVIFile = addframe(outAVIFile, raw_image);
                                end
                                
                                %fprintf('%d %d\n', max(max(d_raw)), min(min(d_raw)));
                                
                                % Process 1 Hz frequency
                                %likely_phase = floor(steps_per_cycle/fpb1)*(wave_index-1)/steps_per_cycle;
                                likely_phase1 = (wave_index-1)/fpb1;
                                likely_phase2 = (wave_index-1)/fpb2;
                                %fprintf('li: %d\tus: %d\t',likely_phase,(wave_index-1)/fpb1);
                                
                                d_cos1 = cos((2*pi*likely_phase1)+offset1);
                                d_sin1 = sin((2*pi*likely_phase1)+offset1);
                                d_cos2 = cos((2*pi*likely_phase2)+offset2);
                                d_sin2 = sin((2*pi*likely_phase2)+offset2);
                                
                                d_real_new1 = d_raw * d_cos1;
                                d_imag_new1 = d_raw * d_sin1;
                                
                                d_real_new2 = d_raw * d_cos2;
                                d_imag_new2 = d_raw * d_sin2;
                                
                                d_real1 = d_real_new1 + d_real1;
                                d_imag1 = d_imag_new1 + d_imag1;
                                
                                d_real2 = d_real_new2 + d_real2;
                                d_imag2 = d_imag_new2 + d_imag2;
                                
                                % Increment index into sin and cos LUTs
                                if wave_index == fpb1
                                    wave_index = 1;
                                else
                                    wave_index = wave_index + 1;
                                end
                                %fprintf('wi: %d\tfc: %d\n', wave_index, frame_count);
                                
                                if frame_count == fpoutput
                                    
                                    d_atan1 = atan2(-d_imag1, d_real1);
                                    d_atan1(d_atan1<0) = d_atan1(d_atan1<0) + 2*pi;
                                    d_atan2 = atan2(-d_imag2, d_real2);
                                    d_atan2(d_atan2<0) = d_atan2(d_atan2<0) + 2*pi;
                                    
                                    d_atan_sum_1 = d_atan_sum_1 + d_atan1;
                                    
                                    % Find actual distance in mm
                                    %d_distance = d_atan * 1000 * c / (4 * pi * fm1);
                                    
                                    d_mag1 = sqrt(d_imag1.^2 + d_real1.^2)/2;
                                    d_mag_sum_1 = d_mag_sum_1 + d_mag1;
                                    d_mag2 = sqrt(d_imag2.^2 + d_real2.^2)/2;
                                    d_mag_sum_2 = d_mag_sum_2 + d_mag2;
                                    
                                    d_atan_sum_2 = d_atan_sum_2 + d_atan2;
                                    
                                    frame_count = 1;
                                    
                                    % Extract points of interest
                                    proc_count = proc_count + 1;
                                    for ii = 1:s(1)
                                        poi = d_atan1(tp(ii,2)-p_width/2+1:tp(ii,2)+p_width/2,tp(ii,1)-p_width/2+1:tp(ii,1)+p_width/2);
                                        phase_data_1(:,ii,proc_count) = poi(:);
                                        poi = d_mag1(tp(ii,2)-p_width/2+1:tp(ii,2)+p_width/2,tp(ii,1)-p_width/2+1:tp(ii,1)+p_width/2);
                                        magnitude_data_1(:,ii,proc_count) = poi(:);
                                        poi = d_atan2(tp(ii,2)-p_width/2+1:tp(ii,2)+p_width/2,tp(ii,1)-p_width/2+1:tp(ii,1)+p_width/2);
                                        phase_data_2(:,ii,proc_count) = poi(:);
                                        poi = d_mag2(tp(ii,2)-p_width/2+1:tp(ii,2)+p_width/2,tp(ii,1)-p_width/2+1:tp(ii,1)+p_width/2);
                                        magnitude_data_2(:,ii,proc_count) = poi(:);
                                        %poi = saturated(tp(ii,2)-p_width/2+1:tp(ii,2)+p_width/2,tp(ii,1)-p_width/2+1:tp(ii,1)+p_width/2);
                                        %saturated_p(:,ii,proc_count) = poi(:);
                                    end
                                    
                                    d_real1 = 0;
                                    d_imag1 = 0;
                                    d_real2 = 0;
                                    d_imag2 = 0;
                                    saturated = zeros(width, height);
                                else
                                    frame_count = frame_count + 1;
                                end
                                
                            end
                        end
                        
                        if outputAVI == 1
                            outAVIFile = close(outAVIFile);
                        end
                        
                        inFile = fclose(inFile);
                        
                        
                        % do some calculations...
                        
                        
                        % Calculate distance from phase
                        distance_data_1 = phase_data_1 * du1/(2*pi);
                        distance_data_2 = phase_data_2 * du2/(2*pi);
                        
                        % Find standard deviation in time for every pixel.
                        std_per_pixel = std(distance_data_1,0,3);
                        mean_std_per_pixel = mean(std_per_pixel);
                        std_std_per_pixel = std(std_per_pixel);
                        
                        
                        % Do the same for phase
                        phase_std_per_pixel = std(phase_data_1,0,3);
                        phase_mean_std_per_pixel = mean(phase_std_per_pixel);
                        phase_std_std_per_pixel = std(phase_std_per_pixel);
                        %figure; errorbar(mean_std_per_pixel, std_std_per_pixel); title([files 'std deviation of test pixels']);
                        
                        % Find mean for each pixel in time.
                        mean_per_pixel = mean(distance_data_1,3);
                        mean_mean_per_pixel = mean(mean_per_pixel);
                        std_mean_per_pixel = std(mean_per_pixel);
                        %figure; plot(mean_per_pixel);
                        
                        % And the same for phase
                        phase_mean_per_pixel = mean(phase_data_1,3);
                        phase_mean_mean_per_pixel = mean(phase_mean_per_pixel);
                        phase_std_mean_per_pixel = std(phase_mean_per_pixel);
                        %figure; errorbar(mean_mean_per_pixel, std_mean_per_pixel); title([files 'mean deviation of test pixels']);
                        
                        % Find mean distance of each test point
                        mean_per_point = squeeze(mean(distance_data_1,1));
                        %figure; plot(mean_per_point');
                        %t = sprintf('mean distance vs time for test points. %d MHz, %d N, %d ms',Fs_1(f), Ns_1(n), Ts(t)); title(t);
                        
                        % Find distance error for the mean values.
                        % find expected ambiguous range for test points at this frequency
                        distance_expected = tp_distance_actual;
                        for i = 1:5
                            distance_expected(distance_expected > du1) = distance_expected(distance_expected>du1) - du1;
                        end
                        
                        %phase_correction_1 = (distance_expected(3)-mean_per_point(3))*2*pi/du1;
                        
                        distance_error = mean_mean_per_pixel - distance_expected;
                        %distance_error(distance_error < 0) = distance_error(distance_error < 0) + du1;
                        %figure; errorbar(distance_error, std_mean_per_pixel); title([files 'mean error of test pixels (mm)']);
                        
                        %Find phase error
                        phase_error = distance_error / (du1/(2*pi));
                        phase_error_std = std_mean_per_pixel / (du1/(2*pi));
                        %figure; errorbar(phase_error, phase_error_std); title([files 'mean error of test pixels (radians)']);
                        %hold on; plot(1:length(phase_error),ones(length(phase_error),1)*mean(phase_error), '-.r'); hold off;
                        
                        
                        save(matFile,'-APPEND','raw_data_*', 'distance_*', 'magnitude_*', 'phase_*','mean_*','std_*','tp', 'tp_distance_actual', 'd_atan_sum_*','d_mag_sum_*','fm1','du1','fm2','du2');%,'saturated_p');
                        if capture_all_raw == 1
                            save(matFile,'-APPEND','all_raw_frames');
                        end
                        
                    end
                end
            end
        end
    end
    
    if proc_count>0
        dist = squeeze(distance_data_1(:,1,:));
        mag = squeeze(magnitude_data_1(:,1,:));
        
        dist_mean = mean(dist,2);
        mag_mean = mean(mag,2);
        
        %PrettifyFigure(44,15,0,0); subplot(1,2,1);imagesc(reshape(mag_mean,p_width,p_width));
        %subplot(1,2,2); imagesc(reshape(dist_mean,p_width,p_width));
    end
end
fprintf('\nComplete!\n');
if showPhaseMag == 1
    
    % delete two right most columns
    d_atan_sum_1 = d_atan_sum_1(1:end,1:end-2);
    d_mag_sum_1 = d_mag_sum_1(1:end,1:end-2);
    
    d_atan_test_1 = d_atan_sum_1/proc_count;
    d_atan_test_1 = d_atan_test_1 * du1 / (2*pi);
    d_mag_test_1 = d_mag_sum_1;
    d_atan_test_2 = d_atan_sum_2/proc_count;
    d_atan_test_2 = d_atan_test_2 * du2 / (2*pi);
    d_mag_test_2 = d_mag_sum_2;
    % Draw a square around the test pixels.
    draw_squares = 0;
    if draw_squares == 1
        for ii = 1:length(tp)
            d_mag_test_1(tp(ii,2)-p_width/2+1:tp(ii,2)+p_width/2,   tp(ii,1)-p_width/2+1) = ii;
            d_mag_test_1(tp(ii,2)-p_width/2+1:tp(ii,2)+p_width/2,   tp(ii,1)+p_width/2) = ii;
            d_mag_test_1(tp(ii,2)-p_width/2+1,   tp(ii,1)-p_width/2+1:tp(ii,1)+p_width/2) = ii;
            d_mag_test_1(tp(ii,2)+p_width/2,   tp(ii,1)-p_width/2+1:tp(ii,1)+p_width/2) = ii;
            d_mag_test_2(tp(ii,2)-p_width/2+1:tp(ii,2)+p_width/2,   tp(ii,1)-p_width/2+1) = ii;
            d_mag_test_2(tp(ii,2)-p_width/2+1:tp(ii,2)+p_width/2,   tp(ii,1)+p_width/2) = ii;
            d_mag_test_2(tp(ii,2)-p_width/2+1,   tp(ii,1)-p_width/2+1:tp(ii,1)+p_width/2) = ii;
            d_mag_test_2(tp(ii,2)+p_width/2,   tp(ii,1)-p_width/2+1:tp(ii,1)+p_width/2) = ii;
        end
    end
    
    
    
    %d_atan_test(d_mag < 50) = max(max(d_atan_test));
    %d_atan_test(d_mag < 20) = NaN;
    
    % Attempt to flip vertically.
    %for i = 1:60
    %    t = d_atan_test(i,:);
    %    d_atan_test(i,:) = d_atan_test(121-i,:);
    %    d_atan_test(121-i,:) = t;
    %end
    % Crop top and sides
    
    h=PrettifyFigure(0,27, 0, 0);
    subplot(2,2,1); imagesc(d_mag_test_1); title('magnitude source 1');
    subplot(2,2,2); imagesc(d_mag_test_2); title('magnitude source 2');
    % Negate, ie, close objects are closer...
    d_d = du1-d_atan_test_1;
    d_d(d_d<2000) = d_d(d_d<2000)+du1;
    subplot(2,2,3); imagesc(d_d); title('distance source 1');
    d_atan_test_2 = du2-d_atan_test_2;
    subplot(2,2,4); imagesc(d_atan_test_2); title('distance source 2');
    % Crop on z axis
    %d_atan_test(d_atan_test < -8.5) = -8.5;
    
    %d_atan_test(d_atan_test > -6) =NaN;    % These are closer
    
    
    %blackMap = zeros(256,3); blackMap(1,:) = ones(1,3)*0.6;
    %h=PrettifyFigure(15,10, 1); surf(d_atan_test, -d_atan_test); colormap(1-gray); shading flat; axis off;
    %colorbar('location','WestOutside');
    
end



%return;

% dist1 = d_atan_test_1+760;
% dist1(dist1>du1) = dist1(dist1>du1)-du1;
% PrettifyFigure(12,14,0,0);
% imagesc(dist1);
% colormap(jet(256));
% axis off;
% title('40 MHz')
% colorbar('location','southoutside');
% 
% dist2 = d_atan_test_2+720;
% dist2(dist2>du2) = dist2(dist2>du2)-du2;
% PrettifyFigure(12,14,0,0);
% imagesc(dist2);
% colormap(jet(256));
% axis off;
% title('32 MHz')
% colorbar('location','southoutside');
% 
% p1 = dist1*2*pi/du1;
% p2 = dist2*2*pi/du2;
% f1 = fm1; f2 = fm2;
% save('40and32MHz.mat','p1','p2','f1','f2');
% [p1r,p2r,d,k1,k2] = findUnambiguous(dist1*2*pi/du1, dist2*2*pi/du2, f1,f2);
% duu = c/2/abs(f1-f2)*1000;
% d(d>11800)=11800;
% 
% PrettifyFigure(12,14,0,0);
% imagesc(d);
% colormap(jet(256));
% axis off;
% title('40 + 32 MHz Combined')
% colorbar('location','southoutside');
% 
% 
% mag = d_mag_test_1;
% PrettifyFigure(16,12,0,0);
% imagesc(mag);
% axis off;
% colormap((gray+0.1)/1.1);

if setFileName == 'Lb310_Jul23_box25_fullscreen'

ADC_GAIN = 6/(1+5*((63-adc_gain_left)/63));
V_MAX = 4;
ADC_STEPS = 2^16;
ADC_FACTOR = V_MAX/ADC_STEPS/ADC_GAIN;

correction = -d_atan_test_1(62,73);
dd = -d_atan_test_1-correction+tp_distance_actual(1);
dd(dd<0)=dd(dd<0)+du1;
dd(dd>5000)=5000;
dd(dd<1200)=1200;
dd = dd(2:end,:);
PrettifyFigure(21,12,1,0); imagesc(dd);
set(gca,'Position',[0.03 0.04 0.92 0.95]);
%axis off;
colorbar;
colormap(jet(256));
text(180,80,'distance (mm)','rotation',90);

print -dtiff -r200 chap4images/test_scene_dist

dm = d_mag_test_1*ADC_FACTOR*2/24;
dm = dm(2:end,:);
dm(80,55:95) = 0;
dm(40,55:95) = 0;
dm(41:79,55) = 0;
dm(41:79,95) = 0;


PrettifyFigure(21,12,1,0); imagesc(log10(dm));
colormap(gray(256));
set(gca,'Position',[0.03 0.04 0.92 0.95]);
%axis off;
colorbar;
text(180,90,'amplitude, V_A - V_B (log_1_0(V))','rotation',90);
print -dtiff -r200 chap4images/test_scene_amp



end


