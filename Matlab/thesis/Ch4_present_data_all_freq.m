% Extracts data from raw .dat files at specified test points.
% Tries to read the set file for paramaters.
% Appends data to .mat file produced by getSetParams

clear all;
%close all;
set_avi_folder;
folder = [avi_folder 'LB310_Jul28_box25_overnight/'];
%setFileName = 'LB310_Jul22_cap_on';

freq = [1 2 4 6 8 10 12 14 16 18 20 22 24 26 28 30 32 34 36 38 40 42 44 46 48 50 52 54 56 58 60 62 64];% 66 68 70];
%freq = [1 4 10 20 30 40 50];
leg_labels = cell(length(freq),1);
for i = 1:length(freq)
    leg_labels{i} = sprintf('%1.2f MHz',freq(i));
end
N = 120;
cycles = 5;
T = N*40;
R = 0;
P = 0;
p_width = 40;

do_processing = 1;
do_part1 = 1;
do_part2 = 1;

bins = 7;

if do_processing == 1
    
    mean_raw_data = zeros(length(freq),N*cycles);
    mean_freq_mag = zeros(length(freq),bins);
    mean_freq_mags = zeros(length(freq),bins-1);
    mean_freq_phase = zeros(1,length(freq));
    
    for f = 1:length(freq)
        
        
        matFile = sprintf('%s%d_%d_%d_%d_%d/%d_%d_%d.mat',folder, floor(freq(f)),floor(freq(f)),N,N,T,R,P,P);
        load(matFile);
        mrd = squeeze(raw_data_sub);% + raw_data_sub(:,1,N+1:2*N))/2;
        
        %figure; plot(mrd');
        %s = sprintf('%d',freq(f)); title(s);
        %mrd = mrd(:,1:N);
        %d = reshape(mrd,p_width,p_width,N);
        
        %d = d(27:26+30,16:15+30,:);
        %figure; imagesc(d(:,:,1));
        %figure; imagesc(reshape(mean(mrd,2),56,56));
        %dd = reshape(d,30*30,N);
        mrd = -mean(mrd);
        mean_raw_data(f,:) = mrd;
        %         if N == 240
        %             mrd_padded = mrd;
        %         else
        %             c = 160;
        %             for i = 240:-1:1
        %                 if mod(i,3)==0
        %                     mrd_padded(i)=mrd(c);
        %                 else
        %                     mrd_padded(i) = mrd(c);
        %                     c = c-1;
        %                 end
        %
        %             end
        %         end
        %         mean_raw_data(f,:) = mrd_padded;
        
        ft = fft(mrd);
        fts = abs(ft(1+cycles:cycles:bins*cycles+1))/N;
        % scale ft so that fundamental = 1
        ftss = fts/fts(1);
        mean_freq_mag(f,:) = fts;
        mean_freq_mags(f,:) = ftss(2:end);
        
        %figure; plot(dd);
        %figure; plot(mrd);
        %ra = squeeze(raw_data_a);
        %rb = squeeze(raw_data_b);
        %mra = mean(ra);
        %mrb = mean(rb);
        %figure; plot(1:length(mra),mra,1:length(mrb),mrb);
        %figure; plot(mra-mrb);
        %figure; imagesc(d(:,:,end))
        
        mean_freq_phase(f) = angle(ft(1+cycles));
        
        
        %figure; plot(mean(mrd));
        
    end
    ADC_GAIN = 6/(1+5*((63-adc_gain_left)/63));
    V_MAX = 4;
    ADC_STEPS = 2^16;
    ADC_FACTOR = V_MAX/ADC_STEPS/ADC_GAIN;
    %mean_raw_data(end,:) = (mean_raw_data(end,:) + 0.4/ADC_FACTOR)*ADC_FACTOR;
    save([folder 'precision_data_all_freq'], 'freq','T','N','cycles','leg_labels','mean_freq_phase','ADC_FACTOR','mean_raw_data','mean_freq_mag','mean_freq_mags');
else
    load([folder 'precision_data_all_freq']);
end

phase_offset = [0:N*cycles-1]*2*pi/N;


mrd = zeros(length(freq),N);
for i = 1:cycles
    mrd = mrd + mean_raw_data(:,N*(cycles-1)+1:N*cycles)
end

mrd = mrd/cycles*ADC_FACTOR;

if do_part1 == 1
    PrettifyFigure(21,11,1,0); plot(mrd','linewidth',2);
    %PrettifyFigure(21,11,1,0); plot(phase_offset,mean_raw_data','linewidth',2);
    legend(leg_labels,'location','best');
    grid on;
    xlabel('Phase Offset, \theta (radians)');
    ylabel('Mean Pixel Output Voltage, V_A - V_B (V)');
    %axis([0 2*pi -0.2 0.5]);
    
    %print -dtiff -r200 waveform_v_freq
    mfm = abs(fft(mrd'));
    mfm = mfm(2,:)/N*2;
    
    PrettifyFigure(21,11,1,0); [ax h1 h2] = plotyy(freq,mfm,freq,1./mfm./freq,'semilogy','semilogy');
    set(h1,'linewidth',2,'marker','o');
    set(h2,'linewidth',2,'marker','s');%, 'color', 'b');
    grid on;
    %legend('Correlation','1 / (Correlation x Frequency)','location','northeast');
    axis(ax(1),[-inf inf 0.01 0.4]);
    axis(ax(2),[-inf inf 0.1 4]);
    
    xlabel('frequency (MHz)');
    ylabel('Fundamental amplitude (V)');
    set(get(ax(2),'Ylabel'),'String','1 / (amplitude x frequency)  (V ^-^1 MHz^-^1)');
    set(ax(1),'YTick',[0.01 0.02:0.02:0.1 0.2:0.2:0.4]);
    set(ax(2),'YTick',[0.1 0.2:0.2:1 2:2:4]);
    print -dtiff -r200 chap4images/correlation_v_freq
    
    
    mfp = -mean_freq_phase;
    mfp(mfp<0)=mfp(mfp<0)+2*pi;
    expected_phase = 2.5*freq/150*2*pi;
    phase_error = expected_phase-mfp;
    
    % Fit a polynomial to the error.
    c = [-0.4593   35.9196 -391.1065 -295.8675]/10000;
    poly = c(1)*freq.^3 + c(2)*freq.^2 + c(3)*freq + c(4);
    
    PrettifyFigure(21,11,1,0); plot(freq,expected_phase,'r-',freq,mfp,'bo-',freq,phase_error,'ms',freq,poly,'r:','linewidth',2);
    legend('expected phase','measured phase','phase error','cubic fit','location','northwest');
    axis([min(freq) max(freq) -0.2 2*pi+0.1]);
    ylabel('phase, \phi (radians)'); xlabel('Frequency (MHz)');
    grid on;
    print -dtiff -r200 chap4images/freq_v_phase
    %figure; plot(freq,distance, freq, 150./freq.*expected_phase/2/pi);
    %return;
    range = [3:13 15:22];
    figure; plot(freq(range),phase_error(range));
    
    distance = 150./freq.*mfp/2/pi;
    d_calib = 150./freq.*(mfp+poly)/2/pi;
    
    PrettifyFigure(21,11,1,0); plot(freq,distance,freq,d_calib);
end;

%PrettifyFigure(21,11,1,0); bar(freq,log10(1./mean_freq_mags));
%legend('2nd Harmonic','3rd Harmonic','4th Harmonic','5th Harmonic','6th Harmonic');

%figure; plot(freq,mean_freq_phase);

% process range using smaller N.
%mrd = mean_raw_data(:,:);

newN = [3 4 5 6 8 12];

    new_freq = [1 10 40];
    new_freq = [1 2:2:20 24:2:46];
    
    new_freqi = zeros(length(new_freq),1);
    for i = 1:length(new_freq)
        new_freqi(i) = find(freq==new_freq(i));
    end
    mrd = mrd(new_freqi,:);
    freq = new_freq;
    leg_labels = cell(length(freq),1);
    for i = 1:length(freq)
        leg_labels{i} = sprintf('%1.2f MHz',freq(i));
    end

%c = [-0.4593   35.9196 -391.1065 -295.8675]/10000;
%poly = c(1)*freq.^3 + c(2)*freq.^2 + c(3)*freq + c(4);
expected_phase = 2.5*freq/150*2*pi;
%calib = poly-expected_phase;

rms_error = zeros(length(freq),length(newN));
bins = 13;
ft = abs(fft(mrd'));
ph = angle(fft(mrd'));
ph = ph(2:bins+2,:);
ft = ft(2:bins+2,:);
for i = 1:length(freq)
    ft(:,i) = ft(:,i)/ft(1,i);
end
ft = ft*100;
ft(ft<0.0105) = 0.0105;
PrettifyFigure(21,12,1,0); bar(2:bins,log10(ft(2:bins,:)),'basevalue',-2.5);
axis([1.5 13.5 -2 1.2]);
YTickLabels = [0.01 0.02:0.02:0.1 0.2:0.2:1 2:2:10];
Yticks = log10(YTickLabels);
set(gca,'YTick', Yticks,'YTickLabel',YTickLabels);
legend(leg_labels,'location','northeast');
grid on;
xlabel('Harmonic number');
ylabel('Harmonic amplitude (% of fundamental)');

%print -dtiff -r200 harmonic_amplitudes

PrettifyFigure(21,25,1,0);
output_allN = zeros(N,length(freq),length(newN));

subtract = ph(1,:);

for n = 1:length(newN)
    
    output = zeros(N,length(freq));
    
    
    for i = 1:N
        m = [mrd(:,i+1:end)  mrd(:,1:i)];
        d = m(:,1:N/newN(n):end);
        f = fft(d');
        %figure; plot(abs(fft(d)));
        p = 2*pi*i/N-angle(f(2,:));
        p = p+subtract;
        %p(p<0) = p(p<0)+2*pi;
        p(p>pi) = p(p>pi)-2*pi;
        p(p>pi) = p(p>pi)-2*pi;
        p(p<-pi) = p(p<-pi)+2*pi;
        output(i,:) = p;
    end
    %figure; plot(output);
    rms_error(:,n) = std(output);
    subplot(3,2,n); plot([0:N-1]*2*pi/N,1000*output,'linewidth',2);
    axis([0 2*pi -80 80]);
    grid on;
    ti = sprintf('N = %d', newN(n)); title(ti);
    ylabel('phase error (milliradians)');
    xlabel('phase offset (radians)');
    if n ~= 2
        legend(leg_labels,'location','northwest');
    end
    output_allN(:,:,n) = output;
end
%print -dtiff -r200 phase_error_v_N

po = [0:N-1]'*2*pi/N;
o4 = output_allN(:,1,2);

%PrettifyFigure(21,11,1,0);
%subplot(1,2,1); plot(po,o4+po,'linewidth',2);
%axis([0 2*pi -0.1 2*pi]);
%subplot(1,2,2); plot(po,o4,'linewidth',2);
legn_labels = cell(length(newN),1);
    for i = 1:length(newN)
        legn_labels{i} = sprintf('N = %d',newN(i));
    end
    
%PrettifyFigure(21,11,1,0); 
PrettifyFigure(16,10,1,0); 
semilogy(freq,1000*rms_error,'-o','linewidth',2);
legend(legn_labels,'location','southwest');
axis([-inf inf 0.2 60]);
set(gca,'YTick',[0.2:0.2:1 2:2:10 20:20:60]);
grid on;
xlabel('Frequency (MHz)');
ylabel('RMS Phase Error (milliradians)');

print -dtiff -r200 chap4images/rms_phase_error_v_N
%print -dtiff -r200 rms_phase_error_v_N_16x10















