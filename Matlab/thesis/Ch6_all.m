% Reads a file in binary format, and creates a text file of hex characters.
% Each line has 16*taps bits = 4 or 8 characters.
% Assumes binary files have 16 bit values, where least significant byte
% appears first.
% Also assumes file has blocks of nValues (width*height) = (width*height) * 16 bits

clear all;
close all;
set_avi_folder;% = 'D:/AVIs/I2MTC_final/Lb310_Jul30_box25/';

nValues = 64*40;

do_hex_write = 0;
do_processing_raw = 0;
do_processing_phase = 0;
do_proc_sim_hw = 1;



N=60;
Nd = 3;
Nr = N/Nd;
f=10;

folder = [avi_folder 'Lb310_Jul30_box25/'];

% Test data for VHDL Simulation
outFile = sprintf('%s%d_%d_%d_%d_%d.hex',folder, f,f,N,N,3000);
matFile = sprintf('%s%d_%d_%d_%d_%d/0_0_0_TC6.mat',folder, f,f,N,N,3000);



cycles_to_proc = 23;

Ts = [1000 1200 1500 2000 2400 3000];
cycles_to_ignore = 1;
ignoreFrames = cycles_to_ignore*N;
nFrames = (cycles_to_proc+cycles_to_ignore)*N;
nPixels = 19200/Nr/length(Ts);


if do_processing_raw == 1
    
    all_raw_frames = zeros(nPixels,cycles_to_proc*N,length(Ts));
    
    for t = 1:length(Ts)
        
        inFile = sprintf('%s%d_%d_%d_%d_%d/0_0_0.dat',folder, f,f,N,N,Ts(t));
        inFile_r1 = sprintf('%s%d_%d_%d_%d_%d/0_0_0_r1.dat',folder, f,f,N,N,Ts(t));
        
        fid = fopen(inFile, 'r');
        fid_r1 = fopen(inFile_r1, 'r');
        raw_count = 1;
        for frame = 1:nFrames
            
            
            
            if feof(fid) == 1
                break
            end
            
            c = fread(fid, nValues, 'uint16');
            if(length(c) ~= nValues)
                break;
            end
            c_r1 = fread(fid_r1, nValues, 'uint16');
            d = c-c_r1;
            d = d(1:nPixels);
            
            if frame > ignoreFrames
                all_raw_frames(:,raw_count,t) = d;
                fprintf('Frame: %d\n', frame);
                %frame = frame + 1;
                
                
                raw_count = raw_count + 1;
            end
        end
        fclose(fid);
        
    end
    l = cycles_to_proc*N;
    h = numel(all_raw_frames)/l;
    all_raw_frames = reshape(shiftdim(all_raw_frames,1),l,h);
    framesNr = zeros(l/Nd,h*Nd);
    for i = 1:Nd
        framesNr(:,(i-1)*h+1:i*h) = all_raw_frames(i:Nd:end,:);
    end
    figure; plot(framesNr);
    l = l/Nd; h = h*Nd;
    
    save(matFile, '-append','Ts','cycles_to_proc','all_raw_frames', 'N','nValues','nPixels','Nr','framesNr','l','h');
else
    load(matFile);
    
end



if do_processing_phase == 1
    load(matFile);
    phases = zeros(l/Nr,h);
    amps = phases;
    
    c_lut = cos(2*pi*[0:Nr-1]/Nr);
    s_lut = sin(2*pi*[0:Nr-1]/Nr);
    
    for cy = 1:cycles_to_proc
        d = framesNr((cy-1)*Nr+1:cy*Nr,:);
        re = d'*c_lut';
        im = d'*s_lut';
        phases(cy,:) = -atan2(im,re);
        amps(cy,:) = 2/Nr*sqrt(im.^2+re.^2);
        fprintf('Cycle: %d\n',cy);
    end
    
    std_phase = squeeze(std(phases));
    mean_amp = squeeze(mean(amps));
    
    save(matFile, '-append','phases','amps','std_phase','mean_amp','c_lut','s_lut');
else
    load(matFile);
end



if do_hex_write == 1
    fid_out = fopen(outFile, 'w');
    [frames,pixels] = size(pmd19k_frames);
    for f = 1:frames
        for p = 1:pixels
            fprintf(fid_out, fixed2hex(pmd19k_frames(f,p), 16, 0));
            fprintf(fid_out, '\n');
        end
        
    end
    
    
    fclose(fid_out);
    
end

if do_proc_sim_hw == 1
    load(matFile);
    
    % Flatten pmd19k_frames to be only Nr elements long, with 19k x Nd high
    l = nPixels*length(Ts)*cycles_to_proc*Nd;
    framesNd = reshape(framesNr,Nr,l);
    
    cc = cos(2*pi*[0:Nr-1]/Nr);
    ss = sin(2*pi*[0:Nr-1]/Nr);
    d_in = bit_fix(framesNd,16,0);
    re_m = d_in'*cc';
    im_m = d_in'*ss';
    phase_m = -atan2(im_m,re_m);
    amp_m = 2/Nr*sqrt(im_m.^2+re_m.^2);
    %figure; plot(amp_m,abs(phase_m),'.');
    
    %ignore overflow, ie, do not truncate top
    % only truncate bottom end
    Bas = 10:16;
    
    phase_hw = zeros(l,length(Bas));
    
    for b = 1:length(Bas)
        Ba = Bas(b);
        Bmax = 16+ceil(log2(Nr));
        B_adp = Ba-Bmax;
        [Ba,Bmax,B_adp,Bmax+B_adp]
        
        cc = cos(2*pi*[0:Nr-1]/Nr);
        ss = sin(2*pi*[0:Nr-1]/Nr);
        cc = bit_fix(cc,0,Ba);
        ss = bit_fix(ss,0,Ba);
        %figure; plot(cc);
        
        re_h = floor(d_in'*cc');
        im_h = floor(d_in'*ss');
        %figure; plot(im_h,re_h,'.');
        re_h = bit_fix(re_h,Bmax,B_adp);
        im_h = bit_fix(im_h,Bmax,B_adp);
        %figure; plot(im_h,re_h,'.');
        phase_h = -atan2(im_h,re_h);
        phase_h = bit_fix(phase_h,3,Ba-2);
        
        phase_hw(:,b) = phase_h;
        
    end
    save(matFile, '-append','phase_hw','phase_m','amp_m','Bas','l');
else
    load(matFile);
end

xa = [0:1000]/1000*0.1;
mx = zeros(length(xa),length(Bas));

for i = 1:length(Bas)
    d = abs(phase_m-phase_hw(:,i));
    %figure; plot(amp_m,d,'.');
    %axis([-inf inf 0.0001 0.1]); grid on;
    
    for k = 1:length(xa)
        mx(k,i) = sum(d<=xa(k));
    end
end

PrettifyFigure(16,10,1,0);semilogx(1000*xa,mx/l*100,'linewidth',2);

mx_m = zeros(length(xa),1);
d = std_phase;
for  k = 1:length(xa)
    mx_m(k) = sum(d<=xa(k));
end
hold on;semilogx(1000*xa,mx_m/length(d)*100,'k--','linewidth',2);
leg_labels = cell(length(Bas)+1,1);
for i = 1:length(Bas)
    leg_labels{i} = sprintf('Ba = %d',Bas(i));
end
leg_labels{end} = '\sigma_\phi'
legend(leg_labels,'location','southeast')
grid on;
axis([-inf inf -0.1 100.5]);
ylabel('% of pixels with \Delta_\phi < x');
xlabel('\Delta_\phi (milliradians)');

print -dtiff -r200 chap6images/error_vs_ba

PrettifyFigure(16,10,1,0);
semilogx(1000*xa,mx_m/length(d)*100,'b-','linewidth',2);
grid on;
axis([0.6 6 -0.1 100.5]);
set(gca, 'Xtick',[0.6:0.1:1 2:1:6]);
ylabel('% of pixels with \sigma_\phi < x');
xlabel('\sigma_\phi (milliradians)');

print -dtiff -r200 chap6images/sdev_vs_npixels

sp = std_phase*1000;

PrettifyFigure(16,10,1,0);
y = mean(sp(mean_amp>(mean(mean_amp)*1.5)));
y = [y y];
x = [0 max(mean_amp)*1.2];
semilogy(mean_amp,sp,'b.','linewidth',2);
grid on;
axis([min(mean_amp)-100 max(mean_amp)+100 0.2 10]);
set(gca, 'Ytick',[0.2:0.2:1 2:2:10]);
ylabel('\sigma_\phi (milliradians)');
xlabel('A (adc counts)');

print -dtiff -r200 chap6images/sdev_vs_amp

PrettifyFigure(16,10,1,0);
subplot(1,2,1); semilogy(amp_m,abs(phase_hw(:,1)-phase_m)*1000,'.');
axis([min(mean_amp)-100 max(mean_amp)+100 0.1 100]);
grid on;
set(gca, 'Xtick',[2000:2000:10000]);
ylabel('\Delta_\phi (milliradians)');
legend('Ba = 10','location','northeast');
subplot(1,2,2); semilogy(amp_m,abs(phase_hw(:,end)-phase_m)*1000,'.r');
axis([min(mean_amp)-100 max(mean_amp)+100 0.1 100]);
grid on;
set(gca, 'Xtick',[2000:2000:10000]);
text(-1000,0.05,'A (adc counts)');
legend('Ba = 16','location','northeast');

print -dtiff -r200 chap6images/error_Ba8and14


snr = 2*pi/0.001;
snr_db = 20*log10(snr);
Br_required = ceil(log2(snr));
snr_i = sqrt(2)*snr/2/pi/sqrt(Nr);

snr = 2*pi*snr_i*sqrt(Nr)/sqrt(2);

snr_i_db = 20*log10(snr_i);

B_expected = log2(snr_i);
Ba_expected = B_expected + log2(Nr^2/pi);
Ba_used = floor(Ba_expected)

% Resource usage statistics
Bits = [6:22];
ALMs = [266 306 345 385 424 466 501 539 577 611 651 687 688 689 690 691 692];
ALMs_Cordic =   floor(ALMs.*[0.74:0.01:0.9]);
ALMs_Cordic(end-4:end) = ALMs_Cordic(end-5);
RAM = Bits*2*128*160/1024;
PrettifyFigure(16,10,1,0); plot(Bits, ALMs, '-o', Bits,ALMs_Cordic, '-o', Bits, RAM, '-x','linewidth',2);
grid on;
legend('Total Logic (ALMs)','CORDIC Logic (ALMs)','Block RAM (kbits)','location','northwest');
axis([7.7 22.3 0 1000]); %text(14.8,200,'DSP=3'); text(8,200,'DSP=2'); text(2.3,550,'DSP=0');
xlabel('accumulator bit width'); ylabel('Resource count');
print -dtiff -r200 chap6images/FPGA_resources

max_ram = 5499*1024;
Ba_used = 15; Br_required = 13;
required_RAM = (Ba_used*2+Br_required*2)*128*160/1024
RAM_pc = required_RAM/max_ram*100


