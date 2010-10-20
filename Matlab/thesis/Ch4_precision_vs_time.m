% Extracts data from raw .dat files at specified test points.
% Tries to read the set file for paramaters.
% Appends data to .mat file produced by getSetParams

clear all;
%close all;
set_avi_folder;
folder = [avi_folder 'LB310_Jul28_box25_overnight/'];

freq = [1 4 10 20 30 40];
freq_for_sat = 1;
leg_labels = cell(length(freq),1);

N = 120;
T = N*[5 7.5 10 12.5 15 20 25 30 35 40 50 60 75];
R = 0;
P = 0;
p_width = 40;
cycles = 5;

do_processing = 0;

M_RATE = 1000./T*N/4;
for i = 1:length(freq)
    leg_labels{i} = sprintf('%d MHz',freq(i));
end
legt_labels = cell(length(T),1);
for i = 1:length(T)
    legt_labels{i} = sprintf('%1.2f ms',T(i)/N);
end
bins = 2;

NN = [4];%3 4 5 6];


if do_processing == 1
    
mean_std_phase_vtime = zeros(length(freq),length(T));
mean_std_phase_vpixel = zeros(length(freq),length(T));
mean_mag = zeros(length(freq),length(T));

mid_pixel = p_width*p_width/2 +p_width/2;
raw_mid_pixel = zeros(length(T),N);


    for f = 1:length(freq)
        for t = 1:length(T)
            
            matFile = sprintf('%s%d_%d_%d_%d_%d/%d_%d_%d.mat',folder, floor(freq(f)),floor(freq(f)),N,N,T(t),R,P,P);
            load(matFile);
            fprintf('%s\n',matFile);
            
            r = squeeze(raw_data_sub);
            si = size(raw_data_sub);
            for n = 1:length(NN)
                r_resampled = zeros(si(1),NN(n));
                phases = zeros(si(1), N/NN(n), cycles);
                for i = 1:N/NN
                    %i = 1;
                    r_resampled = r(:,i:N/NN(n):end-N/NN+i);
                    for k = 1:cycles
                        %k = 1;
                        rr = r_resampled(:,(k-1)*NN+1:k*NN);
                        ft = fft(rr');
                        ft = ft(2,:);
                        p = angle(ft);
                        phases(:,i,k) = p;
                    end
                    
                end
                siz = size(phases);
                p = reshape(phases,siz(1)*siz(2),siz(3));
                p = cleverUnwrap(p,2*pi);
                mean_std_phase_vtime(f,t) = mean(mean(std(p,0,2)));
            end
            ADC_GAIN = 6/(1+5*((63-adc_gain_left)/63));
            V_MAX = 4;
            ADC_STEPS = 2^16;
            ADC_FACTOR = V_MAX/ADC_STEPS/ADC_GAIN;
            rm = mean(r);
            ft = abs(fft(rm));
            m = abs(ft(cycles+1))/N/2;
            mean_mag(f,t) = m*ADC_FACTOR;
            if freq(f) == freq_for_sat
                raw_mid_pixel(t,:) = r(mid_pixel,1:N);
            end
        end
        
    end
    save([folder 'precision_vs_time'], 'raw_mid_pixel','freq_for_sat','mean_std_phase_vtime','freq','T','leg_labels','mean_mag','ADC_FACTOR');
else
    load([folder 'precision_vs_time']);
end
phase_offset = [0:N-1]*2*pi/N;
t_range = [8 10 11 12];
sat_data = raw_mid_pixel(t_range,:)'*ADC_FACTOR;

PrettifyFigure(16,10,1,0); 
plot(phase_offset,sat_data,'-','linewidth',2);
legend(legt_labels(t_range),'location','best');
grid on;
axis([0 2*pi min(min(sat_data))-0.01 max(max(sat_data))+0.01]);
ylabel('Pixel output voltage, V_A - V_B (V)');
xlabel('Phase offset, \theta (radians)');
print -dtiff -r200 chap4images/saturation_data

%return;

%PrettifyFigure(21,11,1,0); 
PrettifyFigure(16,10,1,0); 
loglog(M_RATE,1000*mean_std_phase_vtime(1:end,:)','-o','linewidth',2);
axis([3 50 1 200]);
legend(leg_labels,'location','southeast');
grid on;
grid minor;
grid minor
ylabel('\sigma_\phi (milliradians)');
xlabel('measurement rate (Hz)');
set(gca, 'Ytick',[1 2:2:10 20:20:100 200],'Xtick',[2:1:10 20:10:100 200]);
%print -dtiff -r200 precision_v_itime
print -dtiff -r200 chap4images/precision_v_itime_16x10

figure;loglog(T,1000./mean_std_phase_vtime','o-');
figure; loglog(T, mean_mag','-o');
figure; semilogx(mean_mag(1:6,1:10)',1./mean_std_phase_vtime(1:6,1:10)','o-');















