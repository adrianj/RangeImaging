% Extracts data from raw .dat files at specified test points.
% Tries to read the set file for paramaters.
% Appends data to .mat file produced by getSetParams

clear all;
%close all;
set_avi_folder;
folder = [avi_folder 'LB310_Jul28_box25_overnight/'];



freq = [1 4 10 20 30 40];
freq_for_sat = 4;
leg_labels = cell(length(freq),1);
N = 120;
NN = [3 4 6 8 12];
M_RATE = 1000/60;
T_TOTAL = 60;   %16.67 Hz
%T_TOTAL = 240;   % 4.167 Hz
R = 0;
P = 0;
p_width = 40;
cycles = 5;

do_processing = 1;

for i = 1:length(freq)
    leg_labels{i} = sprintf('%d MHz',freq(i));
end
legn_labels = cell(length(NN),1);
for i = 1:length(NN)
    legn_labels{i} = sprintf('%d ms',NN(i));
end


if do_processing == 1
    
mean_std_phase_vtime = zeros(length(freq),length(NN));
mean_std_phase_vpixel = zeros(length(freq),length(NN));
mean_mag = zeros(length(freq),length(NN));



    for f = 1:length(freq)
        for n = 1:length(NN)
            T = T_TOTAL*N/NN(n);
            if T_TOTAL > 200 && NN(n) == 3
                T = 9000;
            end
            matFile = sprintf('%s%d_%d_%d_%d_%d/%d_%d_%d.mat',folder, floor(freq(f)),floor(freq(f)),N,N,T,R,P,P);
            load(matFile);
            fprintf('%s\n',matFile);
            
            r = squeeze(raw_data_sub);
            si = size(raw_data_sub);
                r_resampled = zeros(si(1),NN(n));
                phases = zeros(si(1), N/NN(n), cycles);
                for i = 1:N/NN(n)
                    %i = 1;
                    r_resampled = r(:,i:N/NN(n):end-N/NN(n)+i);
                    for k = 1:cycles
                        %k = 1;
                        rr = r_resampled(:,(k-1)*NN(n)+1:k*NN(n));
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
    save([folder 'precision_vs_N'], 'mean_std_phase_vtime','freq','NN','M_RATE','leg_labels','mean_mag','legn_labels');
else
    load([folder 'precision_vs_N'])
end


PrettifyFigure(21,11,1,0); semilogy(NN,1000*mean_std_phase_vtime','-o','linewidth',2);
axis([3 12 1 100]);
legend(leg_labels,'location','best');
grid on;
ylabel('\sigma_\phi (milliradians)');
xlabel('frames per measurement, N');
set(gca, 'Ytick',[1 2:2:10 20:20:100],'Xtick',NN);
tif_file = sprintf('chap4images/precision_v_N_T%d.tif',T_TOTAL);
print('-dtiff','-r200',tif_file);










