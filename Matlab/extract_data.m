% Extracts data from raw .dat files at specified test points.
% Tries to read the set file for paramaters.
% Appends data to .mat file produced by getSetParams

clear all;
%close all;

showPhaseMag = 1;
outputAVI = 0;

p_width = 8;
width = 160;
height = 120;
start_row = 0;
start_column = 0;

setFileName = 'D:/AVIs/I2MTC_final/Co250_Jan21_overnight';

Ns_1 = [3];%[3 4 5 6 8 10];
Ns_2 = [3];%[3 4 5 6 8 10];
Fs_1 = [40];% 36 32 28 24 20 16 12 8 4];
Fs_2 = [8];% 36 32 28 24 20 16 12 8 4];
Ms_1 = [120 108 96 84 72 120 96 72 120 60];
Ms_2 = [120 108 96 84 72 120 96 72 120 60];
Ts = [250];
Rs = [0];%0 13 26 38 51 64 77 90 102 115 128 141 154 166 179 192 205 218 230 243 255];
Ps_1_length = 1;%40;
Ps_2_length = 1;

% Test locations in form [x1 y1 ; x2 y2 ; x3 y3 ; ...];
% Test locations actual distance in mm
tp = [75 70;62 70;75 45;62 45;75 32;62 32];
tp(:,1) = tp(:,1) - start_column;
tp(:,2) = tp(:,2) - start_row;

tp_distance_actual = [2400 1520 3400 3400 5280 5280];

frame0 = 0;
frame1 = 0;
frame2 = 0;
frame3 = 0;
for f = 1:length(Fs_1)
    for n = 1:length(Ns_1)
        for t = 1:length(Ts)
            for r = 1:length(Rs)
                Ps_2 = [0:floor(Ms_2(f)*80/Fs_2(f)/Ps_2_length):floor(Ms_2(f)*79/Fs_2(f))];
                for p_2 = 1:length(Ps_2)
                    Ps_1 = [0:floor(Ms_1(f)*80/Fs_1(f)/Ps_1_length):floor(Ms_1(f)*79/Fs_1(f))];
                    for p_1 = 1:length(Ps_1)
                        % This bizzarre correction from rounding errors in file
                        % nomenclature. Remove for corrected
                        Ts_a = Ts(t);
                        Ts_a = floor(floor((Ts(t)*1000)/Ns_1(n))/1000*Ns_1(n));
                        avi_folder = sprintf('%s/%d_%d_%d_%d_%d/',setFileName, Fs_1(f), Fs_2(f), Ns_1(n), floor(Ns_2(n)), Ts_a);
                        
                        
                        files = sprintf('%s',avi_folder);
                        
                        setFilename = sprintf('%s%d_%d_%d',avi_folder,Rs(r),Ps_2(p_2),Ps_1(p_1));
                        inFilename = sprintf('%s.dat',setFilename);
                        fprintf('%s', inFilename);
                        matFile = setFilename;
                        
                        if outputAVI == 1 && f == 1 && n == 1 && t == 1 && p_1 == 1 && p_2 == 1
                            outAVIFilename = sprintf('%s.avi',files);
                            outAVIFile = avifile(outAVIFilename, 'FPS', 13, 'COLORMAP', gray);
                            fig = PrettifyFigure(8, 6, 0);
                            
                        end
                        inFile = fopen(inFilename, 'r');
                        if inFile == -1
                            fprintf(': Data file NOT FOUND.\n');
                            continue;
                        end
                        if getSetParams(setFilename, matFile) < 0
                            fprintf(': Set file NOT FOUND.\n');
                            continue;
                        end
                        fprintf('.\n');
                        load(matFile);
                        
                        ignoreFrames = 2*fpoutput;
                        nFrames = 12*fpoutput;
                        
                        steps_per_cycle1 = (pll_c_count1_hi + pll_c_count1_lo) * 8;
                        steps_per_cycle2 = (pll_c_count2_hi + pll_c_count2_lo) * 8;
                        
                        taps = 1;
                        % option for subtracting left frame from right frame (2 for yes, 1 for no)
                        % - necessary when processing raw outputs of PMD.
                        do_subtract = 1;
                        % Phase offset in radians. (Get this from 'phase_correction')
                        offset1 = 0 + (phase_step_init1*2*pi/steps_per_cycle1);
                        offset2 = 0 + (phase_step_init2*2*pi/steps_per_cycle2);
                        c = 299792458;    % Speed of light.
                        du1 = 1000*c/(2*fm1);  % unambiguous range in mm
                        du2 = 1000*c/(2*fm2);
                        
                        
                        
                        raw_data_a = zeros(p_width*p_width,length(tp),1);
                        raw_data_b = raw_data_a;
                        raw_data_sub = raw_data_a;
                        phase_data_1 = raw_data_a;
                        saturated_p = raw_data_a;
                        magnitude_data_1 = raw_data_a;
                        phase_data_2 = raw_data_a;
                        magnitude_data_2 = raw_data_a;
                        
                        d_atan_sum_1 = 0;
                        d_mag_sum_1 = 0;
                        d_atan_sum_2 = 0;
                        d_mag_sum_2 = 0;
                        saturated = zeros(width, height);
                        
                        
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
                            d_raw_read = fread(inFile, ppf, 'int16');
                            if(length(d_raw_read) ~= ppf)
                                break;
                            end
                            if nf > ignoreFrames
                                
                                if taps == 2
                                    % These two lines for Cameralink system
                                    %tap1 = reshape(d_raw_read(1:2:end),width,height)';
                                    %tap2 = reshape(d_raw_read(2:2:end),width,height)';
                                    % These two lines for PMD
                                    tap1 = reshape(d_raw_read(1:2:end),width,height)';
                                    tap2 = reshape(d_raw_read(2:2:end),width,height)';
                                    % Replace first pixel with second pixel
                                    % - this is actually frame count.
                                    tap1(1) = tap1(2);
                                    tap2(1) = tap2(2);
                                    if do_subtract == 2
                                        d_raw = tap1 - tap2;
                                    else
                                        d_raw = [tap1 tap2];
                                    end
                                else
                                    tap1 = reshape(d_raw_read,width,height)';
                                    d_raw = tap1;
                                    d_raw(1) = d_raw(2);
                                end
                                d_raw = cast(d_raw, 'double');
                                
                                saturated(mod(d_raw,2)==1) = saturated(mod(d_raw,2)==1) + 1;
                                %saturated = (mod(d_raw,2)==1);
                                %figure; imagesc(saturated);
                                
                                raw_count = raw_count + 1;
                                for ii = 1:length(tp)
                                    poi = tap1(tp(ii,2)-p_width/2+1:tp(ii,2)+p_width/2,tp(ii,1)-p_width/2+1:tp(ii,1)+p_width/2);
                                    raw_data_a(:,ii,raw_count) = poi(:);
                                    if taps == 2
                                        poi = tap2(tp(ii,2)-p_width/2+1:tp(ii,2)+p_width/2,tp(ii,1)-p_width/2+1:tp(ii,1)+p_width/2);
                                        raw_data_b(:,ii,raw_count) = poi(:);
                                        if do_subtract == 2
                                            poi1 = tap1(tp(ii,2)-p_width/2+1:tp(ii,2)+p_width/2,tp(ii,1)-p_width/2+1:tp(ii,1)+p_width/2);
                                            poi2 = tap2(tp(ii,2)-p_width/2+1:tp(ii,2)+p_width/2,tp(ii,1)-p_width/2+1:tp(ii,1)+p_width/2);
                                            raw_data_sub(:,ii,raw_count) = poi1(:)-poi2(:);
                                        end
                                        
                                    else
                                        raw_data_b(:,ii,raw_count) = poi(:);
                                        raw_data_sub(:,ii,raw_count) = poi(:);
                                    end
                                end
                                
                                
                                
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
                                    for ii = 1:length(tp)
                                        poi = d_atan1(tp(ii,2)-p_width/2+1:tp(ii,2)+p_width/2,tp(ii,1)-p_width/2+1:tp(ii,1)+p_width/2);
                                        phase_data_1(:,ii,proc_count) = poi(:);
                                        poi = d_mag1(tp(ii,2)-p_width/2+1:tp(ii,2)+p_width/2,tp(ii,1)-p_width/2+1:tp(ii,1)+p_width/2);
                                        magnitude_data_1(:,ii,proc_count) = poi(:);
                                        poi = d_atan2(tp(ii,2)-p_width/2+1:tp(ii,2)+p_width/2,tp(ii,1)-p_width/2+1:tp(ii,1)+p_width/2);
                                        phase_data_2(:,ii,proc_count) = poi(:);
                                        poi = d_mag2(tp(ii,2)-p_width/2+1:tp(ii,2)+p_width/2,tp(ii,1)-p_width/2+1:tp(ii,1)+p_width/2);
                                        magnitude_data_2(:,ii,proc_count) = poi(:);
                                        poi = saturated(tp(ii,2)-p_width/2+1:tp(ii,2)+p_width/2,tp(ii,1)-p_width/2+1:tp(ii,1)+p_width/2);
                                        saturated_p(:,ii,proc_count) = poi(:);
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
                        % get mean of 16 pixel spread
                        if do_subtract == 2
                            raw_data_a_mean = squeeze(mean(raw_data_a,1));
                            raw_data_b_mean = squeeze(mean(raw_data_b,1));
                            % Find phase and magnitude of individual channels
                            t = 0:length(raw_data_a_mean)-1;
                            sin_lut = sin(2*pi*t/fpb1);
                            cos_lut = cos(2*pi*t/fpb1);
                            phase_a = atan((raw_data_a_mean * sin_lut') ./ (raw_data_a_mean * cos_lut'));
                            phase_a(phase_a<0) = phase_a(phase_a<0) + 2*pi;
                            distance_a = phase_a * du1/(2*pi);
                            magnitude_a = sqrt((raw_data_a_mean * sin_lut').^2 + (raw_data_a_mean * cos_lut').^2)/2;
                            phase_b = atan((raw_data_b_mean * sin_lut') ./ (raw_data_b_mean * cos_lut'));
                            phase_b(phase_b<0) = phase_b(phase_b<0) + 2*pi;
                            distance_b = phase_b * du1/(2*pi);
                            magnitude_b = sqrt((raw_data_b_mean * sin_lut').^2 + (raw_data_b_mean * cos_lut').^2)/2;
                        end
                        %figure; plot([magnitude_a magnitude_b]); title([files 'mean magnitude per channel']);
                        
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
                        
                        
                        save(matFile,'raw_data_*','-APPEND', 'distance_*', 'magnitude_*', 'phase_*','mean_*','std_*','tp', 'tp_distance_actual', 'd_atan_sum_*','d_mag_sum_*','fm1','du1','fm2','du2','saturated_p');
                    end
                end
            end
        end
    end
end

if showPhaseMag == 1
    
    d_atan_test_1 = d_atan_sum_1/proc_count;
    d_atan_test_1 = d_atan_test_1 * du1 / (2*pi);
    d_mag_test_1 = d_mag_sum_1;
    d_atan_test_2 = d_atan_sum_2/proc_count;
    d_atan_test_2 = d_atan_test_2 * du2 / (2*pi);
    d_mag_test_2 = d_mag_sum_2;
    % Draw a square around the test pixels.
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
    
    
    h=PrettifyFigure(20,17, 1, 0);
    subplot(2,2,1); imagesc(d_mag_test_1); title('magnitude source 1');
    subplot(2,2,2); imagesc(d_mag_test_2); title('magnitude source 2');
    
    %d_atan_test(d_mag < 50) = max(max(d_atan_test));
    %d_atan_test(d_mag < 20) = NaN;
    
    % Attempt to flip vertically.
    %for i = 1:60
    %    t = d_atan_test(i,:);
    %    d_atan_test(i,:) = d_atan_test(121-i,:);
    %    d_atan_test(121-i,:) = t;
    %end
    % Crop top and sides
    
    
    % Negate, ie, close objects are closer...
    d_atan_test_1 = du1-d_atan_test_1;
    subplot(2,2,3); imagesc(d_atan_test_1); title('distance source 1');
    d_atan_test_2 = du2-d_atan_test_2;
    subplot(2,2,4); imagesc(d_atan_test_2); title('distance source 2');
    % Crop on z axis
    %d_atan_test(d_atan_test < -8.5) = -8.5;
    
    %d_atan_test(d_atan_test > -6) =NaN;    % These are closer
    
    
    %blackMap = zeros(256,3); blackMap(1,:) = ones(1,3)*0.6;
    %h=PrettifyFigure(15,10, 1); surf(d_atan_test, -d_atan_test); colormap(1-gray); shading flat; axis off;
    %colorbar('location','WestOutside');
    
end








