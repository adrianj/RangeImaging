% Extracts data from raw .dat files at specified test points.
% Tries to read the set file for paramaters.
% Appends data to .mat file produced by getSetParams

%clear all;
%close all;
set_avi_folder;
setFileName = 'LB310_Jul28_box25_overnight';
%setFileName = 'LB310_Jul22_cap_on';


freq = [2 4 6 8 10 12 14 16 18 19 20 21 22 23 24 26 28 30 32 34 36 38 40 42 44 46 48 50 52 54 56 58 60];% 62 64];
%freq = [4 12 16 20];
leg_labels = cell(length(freq),1);
for i = 1:length(freq)
    leg_labels{i} = sprintf('%1.2f MHz',freq(i));
end
N = 120;
T = N*20;
R = 0;
P = 0;
p_width = 40;
cycles = 5;

do_processing = 0;
not_20 = 0;

bins = 2;

NN = [4];%3 4 5 6];

mean_std_phase_vtime = zeros(length(freq),length(NN));

if do_processing == 1
for f = 1:length(freq)
    

matFile = sprintf('%s/%d_%d_%d_%d_%d/%d_%d_%d.mat',setFileName, floor(freq(f)),floor(freq(f)),N,N,T,R,P,P);
load([avi_folder matFile]);
fprintf('%s\n',matFile);

r = squeeze(raw_data_sub);
si = size(raw_data_sub);
for n = 1:length(NN)
    r_resampled = zeros(si(1),NN(n));
    phases = zeros(si(1), N/NN(n), cycles);
    for i = 1:N/NN
        r_resampled = r(:,i:N/NN(n):end-N/NN+i);
        for k = 1:cycles
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
    mean_std_phase_vtime(f,n) = mean(mean(std(p,0,2)));
end

end
save([avi_folder 'precision_vs_freq'], 'freq','T','N','cycles','leg_labels','mean_std_phase_vtime');
else
    load([avi_folder 'precision_vs_freq'])
end


if not_20 == 1
% Smooth out the 21-23 MHz range...
r_m_i = find(freq==20);
r_m = mean_std_phase_vtime(r_m_i)
r_x_i = find(freq==24);
r_x = mean_std_phase_vtime(r_x_i)
for i = r_m_i+1:r_x_i-1
    mean_std_phase_vtime(i) = r_m + (r_x-r_m)/(r_x_i-r_m_i);
end
range = [1:r_m_i-2 r_m_i r_m_i+2 r_x_i:length(freq)];
mean_std_phase_vtime = mean_std_phase_vtime(range);
freq = freq(range);
end

%PrettifyFigure(21,11,1,0); 
PrettifyFigure(16,10,1,0); 
[ax h1 h2] = plotyy(freq,mean_std_phase_vtime*1000,freq,mean_std_phase_vtime'./freq*150000/2/pi,'semilogy','semilogy');
set(h1,'linewidth',2,'marker','o');
set(h2,'linewidth',2,'marker','s');%, 'color', 'b');
grid on;
%legend('\sigma_\phi','\sigma_d','location','north');

axis(ax(1),[-inf inf 3 100]);
axis(ax(2),[-inf inf 3 100]);

xlabel('Modulation frequency (MHz)');
ylabel('phase standard deviation, \sigma_\phi (milliradians)');
set(get(ax(2),'Ylabel'),'String','distance standard deviation, \sigma_d (mm)');
set(ax(1),'YTick',[3 4:2:10 20:20:100]);
set(ax(2),'YTick',[3 4:2:10 20:20:100]);
set(gca,'Position',[0.09 0.12 0.83 0.76]);

%print -dtiff -r200 sdev_v_freq;
print -dtiff -r200 chap4images/sdev_v_freq_not20;


range = [1:11 14:23];
p8 = mean_std_phase_vtime(4)*1000;
f = [0 freq(range) 100];
p_est = p8*(1+2*(f-8)/100);
PrettifyFigure(16,10,1,0);
plot(freq(range),mean_std_phase_vtime(range)*1000,'o',f,p_est,'--','linewidth',2);
grid on;
axis([0 48 0 12]);
xlabel('Modulation frequency (MHz)');
ylabel('phase standard deviation, \sigma_\phi (milliradians)');
legend('Experimental data','linear approximation','location','northwest');

print -dtiff -r200 chap5images/sdev_v_freq_estimate;

















