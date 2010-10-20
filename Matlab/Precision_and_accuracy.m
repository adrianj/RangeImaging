% Simulating phase measurement and finding precision and accuracy.
Ns = [3:10];

mean_RMS = zeros(length(Ns),1);
mean_SDV = zeros(length(Ns),1);
total_int_time = 500000;
readout_time = 3000;
res = 10000;
I_max = 1000;     % number of phase steps
K_max = 3;    % number
SNR_shot_db = 100;
SNR_others_db = 100;
% The original triangular waveform.
tri_original = ([0:2/(res):1-2/(res) 1:-2/(res):2/(res)]-0.5);
% This for a more bandwidth limited triangle wave.
%tri_original = sin(2*pi*[0:res-1]/res);
%for i = 3:2:20
%    i^2
%    tri_original = tri_original + (-1)^(floor(i/2))*sin(i*2*pi*[0:res-1]/res)/(i+2)^2;
%end
% Add in some fairly random even order harmonics.
%for i = 1:10
%    r = (floor(rand*5)*2)+6
%    tri_original = tri_original + (-1)^(floor(r/2))*sin(r*2*pi*[0:res-1]/res)/r^4;
%end
tri_fft = fft(tri_original);
tri_fft = tri_fft(2:floor(res/2));
% estimate how each sample set aliases this signal
bins = zeros(length(Ns),1);
for i = 1:length(Ns)
    for j = 1:50
       if Ns(i) * j < length(tri_fft)
           bin = Ns(i)*j;
           p1 = tri_fft(bin+1);
           n1 = tri_fft(bin-1);
           bins(i) = bins(i) + p1 + n1;
           %fprintf('i=%d\tj=%d\tNs(i)=%d\tNs(i)*j=%d\tp1=%d\tn1=%d\n',i,j,Ns(i),Ns(i)*j,p1,n1);
           
       end
    end
end
fprintf('\n');
bins_mag = abs(bins);
bins_phase = atan2(imag(bins),real(bins));
%figure; stem(Ns, bins_mag); title('Expected RMS error (mag)');
%figure; stem(Ns, bins_phase); title('Expected RMS error (phase)');
%figure; plot(tri_original);
%return;
for n = 1:length(Ns)
    N = Ns(n);
    fprintf('N = %d\n', N);
    
    time = [0:2*pi/res:2*pi-2*pi/res];   % basically in radians
    %tri_no_noise = ([0:2/(res):1-2/(res) 1:-2/(res):2/(res)]-0.5)*amplitude;
    %tri_power = sqrt(sum(tri_no_noise.^2)/res);
    int_time = total_int_time / N - readout_time;
    % Calculate noise sources
    
    SNR_shot = (10^(SNR_shot_db/20))*int_time / sqrt(int_time);   
    SNR_others = 10^(SNR_others_db/20);
    amplitude = int_time/10; % This affects quantisation. 10 is arbitrary.
    
    c = cos(2*pi*[0:N-1]/N);
    s = sin(2*pi*[0:N-1]/N);
    phase_RMS = zeros(K_max,1);
    error_0 = zeros(K_max,1);
    for K = 1:K_max % K is the number of repititions
        
        
        tri_original_power = std(tri_original,1);
        % some noise sources scale WITH amplitude, added first.
        % These ARE affected by integration time.
        noise_shot = randn(1,length(tri_original))*tri_original_power/SNR_shot;
        tri_post_int = tri_original + noise_shot;
        % Multiple signal by integration time
        tri_post_int = tri_post_int * amplitude;
        % Then add noise sources that aren't dependent on anything.
        tri_post_power = std(tri_post_int,1);%sqrt(sum(tri_post_int.^2)/res);
        noise_others = randn(1,length(tri_post_int))*tri_post_power/SNR_others;
        tri_pre_quant = tri_post_int + noise_others;
        % Finally quantise the signal
        tri = floor(tri_pre_quant);
     
        phase_offset = zeros(I_max,1);
        phase_radians = zeros(I_max,1);
        phase_res = zeros(I_max,1);
        phase_error = zeros(I_max,1);
        re = phase_error;
        im = phase_error;
        
        for I = 1:I_max %  I is the number of phase increments.
            
            phase_offset(I) = floor((I-1)*res/I_max);
            
            
            if phase_offset(I) > 0 && phase_offset(I) < length(tri)
                tri_new = [tri(phase_offset(I):end) tri(1:phase_offset(I)-1)];
            else
                tri_new = tri;
            end
            dat = zeros(N,1);
            for i = 0:N-1
                dat(i+1) = tri_new(floor(i*res/N)+1);
            end
            
            re(I) = -c*dat;
            im(I) = s*dat;
            ph = atan2(im(I),re(I));
            if ph < 0
                ph = ph + 2*pi;
            end
            phase_radians(I) = ph;
            phase_error(I) = phase_radians(I) - phase_offset(I)*2*pi/res - pi/2;
            
        end % I
        phase_error(phase_error>pi) = phase_error(phase_error>pi)-2*pi;
        phase_error(phase_error<-pi) = phase_error(phase_error<-pi)+2*pi;
        phase_RMS(K) = std(phase_error,1);
        %figure; plot(phase_offset*2*pi/res, phase_error); axis([0 2*pi -0.1 0.1]);
        %fprintf('N=%d\tK=%d\tE0=%d\n',N,K,phase_error(1));
        error_0(K) = phase_error(10);
    end % K
    %fprintf('\n');
    %figure; plot(error_0);
    mean_SDV(n) = std(error_0);
    %figure; plot(phase_RMS);
    mean_RMS(n) = mean(phase_RMS);
    
    if N == 4
        phase_error = phase_error - phase_error(1);
        h=PrettifyFigure(15,6.5, 1,0); plot(phase_offset*2*pi/res, phase_error*1000,'k'); xlabel('Actual phase (radians)'); ylabel('Phase error (mradians)');
        asdf = std(phase_error*1000, 1)
        axis([0 2*pi -80 80]);
    end
    
    %figure; plot(tri);
    %figure; plot(noise);
end % n
%figure; plot(phase_error);

PrettifyFigure(20,12, 1,0); bar(Ns,mean_RMS*1000); xlabel('Frames per cycle, N'); ylabel('RMS phase error (mradians)'); axis([2.4 10.6 0 55]); colormap([0 0.8 0.8]);
%figure; stem(Ns,mean_SDV); title('Mean SDV');