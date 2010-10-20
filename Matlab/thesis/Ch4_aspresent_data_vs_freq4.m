% Extracts data from raw .dat files at specified test points.
% Tries to read the set file for paramaters.
% Appends data to .mat file produced by getSetParams

clear all;
%close all;
set_avi_folder;
setFileName = 'LB310_Jul23_box25';
%folder = [avi_folder 'LB310_Jul23_box25/'];
folder = [avi_folder 'LB310_Jul22_cap_on/'];


freq = [1 8 12 16 20 24 28 32 36 40 44 48 52 56 60];
%freq = [4 12 16 20];
leg_labels = cell(length(freq),1);
for i = 1:length(freq)
    leg_labels{i} = sprintf('%1.2f MHz',freq(i));
end
N = 4;
T = N*10;
R = 0;
P = 0;
p_width = 60;
do_processing = 0;
bins = 2;

if do_processing == 1

mean_std_phase_vtime = zeros(length(freq),1);
mean_std_phase_vpixel = zeros(length(freq),1);

mean_std_ra_vtime = zeros(length(freq),1);
mean_std_rb_vtime = zeros(length(freq),1);
mean_std_ra_vpixel = zeros(length(freq),1);
mean_std_rb_vpixel = zeros(length(freq),1);

for f = 1:length(freq)
    

matFile = sprintf('%s%d_%d_%d_%d_%d/%d_%d_%d.mat',folder, floor(freq(f)),floor(freq(f)),N,N,T,R,P,P);
load(matFile);

p = squeeze(phase_data_1);
si = size(p);
pp = reshape(p,p_width,p_width,si(2));
pp = pp(27:26+30,16:15+30,:);
ppp = reshape(pp,30*30,si(2));

sp = std(ppp,0,2);
msp = mean(sp);
smp = mean(std(ppp,0,1));
mean_std_phase_vtime(f) = msp;
mean_std_phase_vpixel(f) = smp;

ra = squeeze(raw_data_a);
rb = squeeze(raw_data_b);

mean_std_ra_vtime(f) = mean(std(ra'));
mean_std_rb_vtime(f) = mean(std(rb'));
mean_std_ra_vpixel(f) = mean(std(ra));
mean_std_rb_vpixel(f) = mean(std(rb));

mra = mean(ra);
mrb = mean(rb);
%figure; plot(1:length(mra),mra,1:length(mrb),mrb);
%figure; plot(ra(10,:)-rb(10,:));
ADC_GAIN = 6/(1+5*((63-adc_gain_left)/63));
V_MAX = 4;
ADC_STEPS = 2^16;
ADC_FACTOR = V_MAX/ADC_STEPS/ADC_GAIN;
end
    save([folder 'present_data_vs_freq4'], 'mean_std_ra_vtime','mean_std_rb_vtime','mean_std_phase_vtime','freq','ADC_FACTOR');
else
    load([folder 'present_data_vs_freq4']);
end

%N = 240;
noiseA = mean_std_ra_vtime*ADC_FACTOR*1000000;
noiseB = mean_std_rb_vtime*ADC_FACTOR*1000000;

PrettifyFigure(21,7,1,0); plot(freq,noiseA,'ro-',freq,noiseB,'bs-','linewidth',2);
legend('Pixel A output','Pixel B Output','location','southeast');
xlabel('Modulation frequency ( MHz )');
ylabel('Pixel output standard deviation ( \muV )');
axis([min(freq) max(freq) 500 620]);
grid on;

print -dtiff -r200 chap4images/noise_floor

PrettifyFigure(21,11,1,0); plot(freq,mean_std_phase_vtime,'bo-','linewidth',2);



















