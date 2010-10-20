% Compare with integration ratio.

% Assume Amplitude is directly relate to T where T is integration
% time. And that sdev is directly proprtional to A.
set_avi_folder;
fA = 40e6;
FBs = [32e6 8e6];

sigmaA_factor = [1.64 1.64];
sigmaB_factor = [1.48 1];


RATIOS = [0:1/20:1];
MAX_SIGMA = 0.06;
N = 10000;

err_nn = zeros(length(FBs),length(RATIOS),5);
sdev_nn = zeros(length(FBs),length(RATIOS),5);
SIGMA_A = zeros(length(FBs),length(RATIOS));
SIGMA_B = zeros(length(FBs),length(RATIOS));
%PrettifyFigure(10,10,1,0);
sim = 1;
nonSim = 1;
do_8 = 0;
    do_40 = 0;
    folder = [avi_folder 'multifreq/'];
    
co_old = get(0,'defaultaxescolororder');
if sim == 1
    for ff = 1:length(FBs)
        fB = FBs(ff);
        fE = gcd(fA,fB);
        dE = 150e9/fE;
        duA = 150e9/fA;
        duB = 150e9/fB;
        MA = fA/fE;
        MB = fB/fE;
        for r = 1:length(RATIOS)
            ratio = RATIOS(r)
            
            actual_d = ones(N,1)*dE/2;
            
            dA = mod(actual_d,duA);
            dB = mod(actual_d,duB);
            
            %AA = 0.001+ratio*MAX_SIGMA;
            %AB = 0.001+(1-ratio)*MAX_SIGMA;
            
            % If 32 MHz is 1.48x 8 MHz, and 40 MHz is 1.64x 8 MHz, then 40
            % MHz is 1.64/1.48x 32 MHz.
            
            sigma_a = MAX_SIGMA*1/(0.001+ratio);
            
            sigma_b = MAX_SIGMA*1/(0.001+(1-ratio));
            
            % These extra lines for thesis
            sigma_a = sigma_a*sigmaA_factor(ff);
            sigma_b = sigma_b*sigmaB_factor(ff);
            
            noiseA = randn(N,1)*sigma_a/2/pi;
            noiseB = randn(N,1)*sigma_b/2/pi;
            pA = dA/duA;
            pB = dB/duB;
            pA_n = mod(pA + noiseA,1);
            pB_n = mod(pB + noiseB,1);
            
            %w = MA*AA/(MA*AA+MB*AB);
            %w2 = MA^2*AA^2/(MA^2*AA^2+MB^2*AB^2);
            w2 = sigma_b^2/(sigma_b^2+(sigma_a*MB/MA)^2);
            w = w2;
            
            SIGMA_A(ff,r) = sigma_a;
            SIGMA_B(ff,r) = sigma_b;
            
            [dd,kA,kB,E] = findUnambiguous(pA,pB,fA,fB,1,0.5);
            [d_1,kA_1,kB_1,E_1] = findUnambiguous(pA_n, pB_n, fA, fB,1,1);
            [d_0,kA_0,kB_0,E_0] = findUnambiguous(pA_n, pB_n, fA, fB,1,0);
            [d_5,kA_5,kB_5,E_5] = findUnambiguous(pA_n, pB_n, fA, fB,1,0.5);
            [d_r,kA_r,kB_r,E_r] = findUnambiguous(pA_n, pB_n, fA, fB,1,w);
            [d_r2,kA_r2,kB_r2,E_r2] = findUnambiguous(pA_n, pB_n, fA, fB,1,w2);
            
            error_nn = actual_d-d_1;
            e_nn = abs(E-E_1)>0.5;
            err_nn(ff,r,1) = sum(e_nn)/N*100;
            sdev_nn(ff,r,1) = std(error_nn(~e_nn));
            %sdev_nn(ff,r,1) = std(error_nn);
            
            error_nn = actual_d-d_0;
            e_nn = abs(E-E_0)>0.5;
            err_nn(ff,r,2) = sum(e_nn)/N*100;
            sdev_nn(ff,r,2) = std(error_nn(~e_nn));
            %sdev_nn(ff,r,2) = std(error_nn);
            
            error_nn = actual_d-d_5;
            e_nn = abs(E-E_5)>0.5;
            err_nn(ff,r,3) = sum(e_nn)/N*100;
            sdev_nn(ff,r,3) = std(error_nn(~e_nn));
            %sdev_nn(ff,r,3) = std(error_nn);
            
            error_nn = actual_d-d_r;
            e_nn = abs(E-E_r)>0.5;
            err_nn(ff,r,4) = sum(e_nn)/N*100;
            sdev_nn(ff,r,4) = std(error_nn(~e_nn));
            %sdev_nn(ff,r,4) = std(error_nn);
            
            error_nn = actual_d-d_r2;
            e_nn = abs(E-E_r2)>0.5;
            err_nn(ff,r,5) = sum(e_nn)/N*100;
            sdev_nn(ff,r,5) = std(error_nn(~e_nn));
            %sdev_nn(ff,r,5) = std(error_nn);
            
        end
    end
    save([folder 'compareRatio_sim'],'err_nn','sdev_nn','SIGMA_A','SIGMA_B');
else
    load([folder 'compareRatio_sim']);
end
    MB = [4 1]'*ones(1,length(RATIOS));
    
    
    
    s = sqrt((MB.*SIGMA_A/2/pi).^2+(MA.*SIGMA_B/2/pi).^2);
    P = (1-erf(1./(2.*s.*sqrt(2))))*100;
    P(2,1:5) = 0
    err = err_nn(:,:,4)';
    x = RATIOS*100;
    err(1:4,2) = 1e-3;
    %PrettifyFigure(16,12,1,0);
    PrettifyFigure(21,11,1,0);
    semilogy(x,err(:,1),'bo',x,err(:,2),'r^',x,P(1,:),'b-',x,P(2,:),'r-','linewidth',2); grid on;
    axis([0 100 0.01 100]); 
    legend('f_A:f_B = 40:32 MHz','f_A:f_B = 40:8 MHz','f_A:f_B = 40:32 MHz theory','f_A:f_B = 40:8 MHz theory','location','north');
    ylabel('Error rate ( % )'); xlabel('Integration Ratio T_A:T_t_o_t_a_l ( % )');
    
    print -dtiff -r200 chap5images/sim_ratio_error;
    
    sdev = reshape(shiftdim(sdev_nn(:,:,3:4),1),length(RATIOS),length(FBs)*2);
    s = sqrt((duB.*SIGMA_A).^2+(duA.*SIGMA_B).^2);
    
    psdev8 = min(min(SIGMA_B))*ones(length(RATIOS),1);
    sdev8 = psdev8*dE/2/pi;
    
    %PrettifyFigure(16,12,1,0);
    PrettifyFigure(21,11,1,0);
    %ax = plot(x,sdev(:,1),'r-o',x,sdev(:,2),'r-^',x,sdev(:,3),'b:o',x,sdev(:,4),'b:^',x,sdev8,'-d','linewidth',2); grid on;
    ax = plot(x,sdev(:,1),'bo:',x,sdev(:,2),'bo-',x,sdev(:,3),'r^:',x,sdev(:,4),'r^-',x,sdev8,'-','linewidth',2); grid on;
    %legend('f_A:f_B = 40:32 MHz, w = 50%','f_A:f_B = 40:32 MHz, w = variable','f_A:f_B = 40:8 MHz, w = 50%','f_A:f_B = 40:8 MHz, w = variable','location','north');
    legend('f_A:f_B = 40:32 MHz, w = 50%','f_A:f_B = 40:32 MHz, w = variable','f_A:f_B = 40:8 MHz, w = 50%','f_A:f_B = 40:8 MHz, w = variable','f_A = 8 MHz only','location','north');
    ylabel('\sigma_d ( mm )');xlabel('Integration Ratio T_A:T_t_o_t_a_l ( % )');
    axis([0 100 10 400]); grid on;
    set(ax(5),'Color',co_old(4,:));
    print -dtiff -r200 chap5images/sim_ratio_sdev;
    %print -dtiff -r200 int_ratio_sdev;
    
    %PrettifyFigure(16,12,1,0); plot(x,SIGMA_A(1,:),'ro-',x,SIGMA_B(1,:),'b^-','linewidth',2);
    PrettifyFigure(21,11,1,0);  ax = plot(x,SIGMA_A(2,:),'bo-',x,SIGMA_B(1,:),'r^-',x,SIGMA_B(2,:),'cd-','linewidth',2);
    legend('\sigma_p(40 MHz)','\sigma_p(32 MHz)','\sigma_p(8 MHz)','location','north');
    %legend('\sigma_p_A','\sigma_p_B','location','north');
    axis([min(x) max(x) 0 1]); grid on;
    set(ax(3),'Color',co_old(4,:));
    ylabel('\sigma_p ( radians )');xlabel('Integration Ratio T_A:T_t_o_t_a_l ( % )');
    print -dtiff -r200 chap5images/sim_ratio_phase;

if nonSim == 1
    
    
    
    
    fA = 40e6; fB = 32e6; MA = 5; MB = 4; duA = 150e9/fA; duB = 150e9/fB;
    dE = 150e9/gcd(fA,fB);
    load ([folder 'DIST_BENCHMARK']);
    load ([folder 'DIST_40_32_5_100_0']);
    width = 128; height = 60;
    
    [ppf,frames] = size(DIST_40_32_5_100_0);
    RATIOS = [round(0:256/20:255) 255];
    %RATIOS = [round(0:256/10:255) 255];
    
    % Test point 6 = [38:53,25:43]
    % Test point 8 = [56:67,25:39]
    
    index = [];
    p_h = 16; p_w = 12;
    figure; imagesc(reshape(log10(m_benchmark),height,width));
    for col = [56:56+p_w-1]-1
        index = [index [25:25+p_h-1]+height*col];
    end
    
    d_bench = d_benchmark(index)*ones(1,frames);
    e_bench = e_benchmark(index)*ones(1,frames);
    e_bench_8 = d_benchmark(index)*ones(1,frames)*5/dE;
    if do_40 == 1
        d_40 = zeros(length(RATIOS),p_h*p_w,frames);
        d_32 = zeros(length(RATIOS),p_h*p_w,frames);
        d5_40_32 = zeros(length(RATIOS),p_h*p_w,frames);
        d_40_32 = zeros(length(RATIOS),p_h*p_w,frames);
        e_40_32 = zeros(length(RATIOS),p_h*p_w,frames);
        s_40_32 = zeros(length(RATIOS),p_h*p_w);
        m_40_32 = zeros(length(RATIOS),p_h*p_w,frames);
        m_32 = zeros(length(RATIOS),p_h*p_w,frames);
        s = zeros(p_h*p_w,1);
        
        
        e5_40_32 = zeros(length(RATIOS),p_h*p_w,frames);
        s5_40_32 = zeros(length(RATIOS),p_h*p_w);
        
        for r = 1:length(RATIOS)
            fprintf('%d\n',RATIOS(r));
            s40 = sprintf('%s/DIST_40_32_5_100_%d',folder,RATIOS(r));
            s32 = sprintf('%s/DIST_32_40_5_100_%d',folder,RATIOS(r));
            m40 = sprintf('%s/MAG_40_32_5_100_%d',folder,RATIOS(r));
            m32 = sprintf('%s/MAG_32_40_5_100_%d',folder,RATIOS(r));
            load(s40);
            
            
            %for i = 1:frames
            eval(['d = ' s40 '(index,:); d_40(r,:,:) = d(:,:);']);
            eval(['d = ' s32 '(index,:); d_32(r,:,:) = d(:,:);']);
            eval(['d = ' m40 '(index,:); m_40_32(r,:,:) = d(:,:);']);
            eval(['d = ' m32 '(index,:); m_32(r,:,:) = d(:,:);']);
            %end
            w = squeeze(m_40_32(r,:,:)*MA ./ (m_40_32(r,:,:)*MA+m_32(r,:,:)*MB));
            pA = squeeze(d_40(r,:,:))/duA; pB = squeeze(d_32(r,:,:))/duB;
            
            [d ka kb ee] = findUnambiguous(pA,pB,fA,fB,1,w);
            err = abs(e_bench-ee)>0.5;
            e_40_32(r,:,:) = err;
            d_40_32(r,:,:) = d;
            % Filter out errors for finding sdev.
            for i = 1:p_h*p_w
                temp_d = d(i,:);
                temp_e = err(i,:);
                s(i) = std(temp_d(temp_e~=1));
            end
            s_40_32(r,:) = s;
            
            w2 = 0.5;%squeeze(m_40_32(r,:,:).^2*MA^2 ./ (m_40_32(r,:,:).^2*MA^2+m_32(r,:,:).^2*MB^2));
            
            [d ka kb ee] = findUnambiguous(pA,pB,fA,fB,1,w2);
            err = abs(e_bench-ee)>0.5;
            e5_40_32(r,:,:) = err;
            d5_40_32(r,:,:) = d;
            % Filter out errors for finding sdev.
            for i = 1:p_h*p_w
                temp_d = d(i,:);
                temp_e = err(i,:);
                s(i) = std(temp_d(temp_e~=1));
            end
            s5_40_32(r,:) = s;
            clear('*_5_100_*');
        end
        
        sdev_40_32 = s_40_32;
        error_40_32 = squeeze(sum(e_40_32,3))/frames*100';
        sdev5_40_32 = s5_40_32;
        error5_40_32 = squeeze(sum(e5_40_32,3))/frames*100';
        save([folder 'COMPARE_RATIOS_40_32'],'sdev_40_32','error_40_32','sdev5_40_32','error5_40_32','d_40','d_32','m_40_32','m_32');
    end
    
    %%%%%%%%%%%%%%%%%%%
    if do_8 == 1
        fA = 40e6; fB = 8e6; MA = 5; MB = 1; duA = 150e9/fA; duB = 150e9/fB;
        dE = 150e9/gcd(fA,fB);
        dd_40 = zeros(length(RATIOS),p_h*p_w,frames);
        d_8 = zeros(length(RATIOS),p_h*p_w,frames);
        d_40_8 = zeros(length(RATIOS),p_h*p_w,frames);
        d5_40_8 = zeros(length(RATIOS),p_h*p_w,frames);
        e_40_8 = zeros(length(RATIOS),p_h*p_w,frames);
        s_40_8 = zeros(length(RATIOS),p_h*p_w);
        m_40 = zeros(length(RATIOS),p_h*p_w,frames);
        m_8 = zeros(length(RATIOS),p_h*p_w,frames);
        s = zeros(p_h*p_w,1);
        
        
        e5_40_8 = zeros(length(RATIOS),p_h*p_w,frames);
        s5_40_8 = zeros(length(RATIOS),p_h*p_w);
        
        for r = 1:length(RATIOS)
            fprintf('%d\n',RATIOS(r));
            s40 = sprintf('DIST_40_8_5_100_%d',RATIOS(r));
            s8 = sprintf('DIST_8_40_5_100_%d',RATIOS(r));
            m40 = sprintf('MAG_40_8_5_100_%d',RATIOS(r));
            m8 = sprintf('MAG_8_40_5_100_%d',RATIOS(r));
            load(s40);
            
            
            %for i = 1:frames
            eval(['d = ' s40 '(index,:); dd_40(r,:,:) = d(:,:);']);
            eval(['d = ' s8 '(index,:); d_8(r,:,:) = d(:,:);']);
            eval(['d = ' m40 '(index,:); m_40(r,:,:) = d(:,:);']);
            eval(['d = ' m8 '(index,:); m_8(r,:,:) = d(:,:);']);
            %end
            w = squeeze(m_40(r,:,:)*MA ./ (m_40(r,:,:)*MA+m_8(r,:,:)*MB));
            pA = squeeze(dd_40(r,:,:))/duA; pB = squeeze(d_8(r,:,:))/duB;
            
            [d ka kb ee] = findUnambiguous(pA,pB,fA,fB,1,w);
            err = abs(e_bench_8-ee)>0.5;
            e_40_8(r,:,:) = err;
            d_40_8(r,:,:) = d;
            % Filter out errors for finding sdev.
            for i = 1:p_h*p_w
                temp_d = d(i,:);
                temp_e = err(i,:);
                s(i) = std(temp_d(temp_e~=1));
            end
            s_40_8(r,:) = s;
            
            w2 = 0.5;%squeeze(m_40(r,:,:).^2*MA^2 ./ (m_40(r,:,:).^2*MA^2+m_8(r,:,:).^2*MB^2));
            [d ka kb ee] = findUnambiguous(pA,pB,fA,fB,1,w2);
            err = abs(e_bench_8-ee)>0.5;
            e5_40_8(r,:,:) = err;
            d5_40_8(r,:,:) = d;
            % Filter out errors for finding sdev.
            for i = 1:p_h*p_w
                temp_d = d(i,:);
                temp_e = err(i,:);
                s(i) = std(temp_d(temp_e~=1));
            end
            s5_40_8(r,:) = s;
            clear('*_5_100_*');
        end
        
        
        
        sdev_40_8 = s_40_8;
        error_40_8 = squeeze(sum(e_40_8,3))/frames*100';
        sdev5_40_8 = s5_40_8;
        error5_40_8 = squeeze(sum(e5_40_8,3))/frames*100';
        save([folder 'COMPARE_RATIOS_40_8'], 'sdev_40_8','error_40_8','sdev5_40_8','error5_40_8','dd_40','d_8','m_40','m_8');
        
    end
    load([folder 'COMPARE_RATIOS_40_32']);
    load([folder 'COMPARE_RATIOS_40_8']);
    x = 100-RATIOS*100/255;
    du40 = 150e9/40e6; du32 = 150e9/32e6; du8 = 150e9/8e6;
    sd_40 = std(d_40,0,3)*2*pi/du40;
    sd_32 = std(d_32,0,3)*2*pi/du32;
    sd_8 = std(d_8,0,3)*2*pi/du8;
    PrettifyFigure(21,11,1,0);  ax1 = errorbar(x,mean(sd_40,2),std(sd_40,0,2),'bo-','linewidth',2);
    hold on; ax2 = errorbar(x,mean(sd_32,2),std(sd_32,0,2),'r^-','linewidth',2);
    hold on; ax3 = errorbar(x,mean(sd_8,2),std(sd_8,0,2),'cd-','linewidth',2);
    legend('\sigma_p(40 MHz)','\sigma_p(32 MHz)','\sigma_p(8 MHz)','location','north');
    %legend('\sigma_p_A','\sigma_p_B','location','north');
    axis([min(x) max(x) 0 1]); grid on;
    set(ax3,'Color',co_old(4,:));
    ylabel('\sigma_p ( radians )');xlabel('Integration Ratio T_A:T_t_o_t_a_l ( % )');
    print -dtiff -r200 chap5images/exp_ratio_phase;
    
    
    
    sdm_40 = mean(sd_40,2);
    sdm_32 = mean(sd_32,2);
    sdm_8 = mean(sd_8,2);
    
    se = zeros(size(P));
    se(2,:) = sqrt((sdm_40*1/2/pi).^2+(sdm_8*5/2/pi).^2);
    se(1,:) = sqrt((sdm_40*4/2/pi).^2+(sdm_32*5/2/pi).^2);
    
    sdp_40 = mean(sd_40,2)+std(sd_40,0,2);
    sdp_32 = mean(sd_32,2)+std(sd_32,0,2);
    sdp_8 = mean(sd_8,2)+std(sd_8,0,2);
    sdn_40 = mean(sd_40,2)-std(sd_40,0,2);
    sdn_32 = mean(sd_32,2)-std(sd_32,0,2);
    sdn_8 = mean(sd_8,2)-std(sd_8,0,2);
    
    se = zeros(size(P));
    se(2,:) = sqrt((sdm_40*1/2/pi).^2+(sdm_8*5/2/pi).^2);
    se(1,:) = sqrt((sdm_40*4/2/pi).^2+(sdm_32*5/2/pi).^2);
    
    sep = zeros(size(P));
    sep(2,:) = sqrt((sdp_40*1/2/pi).^2+(sdp_8*5/2/pi).^2);
    sep(1,:) = sqrt((sdp_40*4/2/pi).^2+(sdp_32*5/2/pi).^2);
    
    sen = zeros(size(P));
    sen(2,:) = sqrt((sdn_40*1/2/pi).^2+(sdn_8*5/2/pi).^2);
    sen(1,:) = sqrt((sdn_40*4/2/pi).^2+(sdn_32*5/2/pi).^2);
    
    sdm_40 = mean(sd_40,2);
    sdm_32 = mean(sd_32,2);
    sdm_8 = mean(sd_8,2);
    
    se = zeros(size(P));
    se(2,:) = sqrt((sdm_40*1/2/pi).^2+(sdm_8*5/2/pi).^2);
    se(1,:) = sqrt((sdm_40*4/2/pi).^2+(sdm_32*5/2/pi).^2);
    
    Pt = 100*(1-erf(1./(2*sqrt(2)*se)));
    Pp = 100*(1-erf(1./(2*sqrt(2)*sep)));
    Pn = 100*(1-erf(1./(2*sqrt(2)*sen)));
    Pp(2,end-5:end) = 0.00001;
    Pn(2,end-5:end) = 0.00001;
    
    
    PrettifyFigure(21,11,1,0);
    semilogy(x,mean(error_40_32,2),'bo-',x,mean(error_40_8,2),'r-^','linewidth',2);%x,Pn(1,:),'b-',x,Pn(2,:),'r-',...
        %x,Pp(1,:),'b-',x,Pp(2,:),'r-','linewidth',2); 
        grid on;
    %hold on; ax = errorbar(x,Pt(1,:),Pp(1,:),Pn(1,:),'dc');
    %set(gca,'YScale','log');
    axis([0 100 0.01 100]); 
    legend('f_A:f_B = 40:32 MHz','f_A:f_B = 40:8 MHz','f_A:f_B = 40:32 MHz theory','f_A:f_B = 40:8 MHz theory','location','north');
    ylabel('Error rate ( % )'); xlabel('Integration Ratio T_A:T_t_o_t_a_l ( % )');
    
    print -dtiff -r200 chap5images/exp_ratio_error_point8;
    
    %figure; semilogy(RATIOS,sdev,'.',RATIOS,sdev5,'.');
    
    sd_8_min = mean(sd_8(end,:))*ones(length(x));
    sdev_8 = sd_8_min*dE/2/pi;
    
    PrettifyFigure(21,11,1,0);  errorbar(x,mean(sdev5_40_32,2),std(sdev5_40_32,0,2),'bo:','linewidth',2);
    hold on; errorbar(x,mean(sdev_40_32,2),std(sdev_40_32,0,2),'bo-','linewidth',2);
    hold on; errorbar(x,mean(sdev5_40_8,2),std(sdev5_40_8,0,2),'r^:','linewidth',2);
    hold on;errorbar(x,mean(sdev_40_8,2),std(sdev_40_8,0,2),'r^-','linewidth',2);
    hold on; ax3 = plot(x,sdev_8,'c-','linewidth',2);
    set(ax3,'Color',co_old(4,:));
    axis([min(x) max(x) 10 500]); grid on;
    ylabel('\sigma_d ( mm )');xlabel('Integration Ratio T_A:T_t_o_t_a_l ( % )');
    legend('f_A:f_B = 40:32 MHz, w = 50%','f_A:f_B = 40:32 MHz, w = variable','f_A:f_B = 40:8 MHz, w = 50%','f_A:f_B = 40:8 MHz, w = variable','f_A = 8 MHz only','location','north');
    
    print -dtiff -r200 chap5images/int_ratio_sdev_point8;
    
    m_bench = m_benchmark(index);
    %figure; imagesc(reshape(m_benchmark,height,width)); colormap(jet(256)); colorbar;
    %figure; imagesc(reshape(m_bench,p_h,p_w)); colormap(jet(256)); colorbar;
    return;
    
        %%%%%% This part for I&M Journal paper.
    x = 100-RATIOS*100/255;
    PrettifyFigure(16,12,1,0);  semilogy(x,mean(error_40_32,2),'ro-',x,mean(error_40_8,2),'bo:','linewidth',2);
    axis([min(x) max(x) 0.01 100]); grid on;
    legend('f_A:f_B = 40:32 MHz','f_A:f_B = 40:8 MHz','location','north');
    ylabel('Error rate ( % )'); xlabel('Integration Ratio T_A:T_t_o_t_a_l ( % )');
    print -dtiff -r200 chap5images/int_ratio_error_point8;
    
    du40 = 150e9/40e6; du32 = 150e9/32e6; du8 = 150e9/8e6;
    sd_40 = std(d_40,0,3)*2*pi/du40;
    sd_32 = std(d_32,0,3)*2*pi/du32;
    sd_8 = std(d_8,0,3)*2*pi/du8;
    PrettifyFigure(16,12,1,0);  set(gca,'colororder',[0 0 1 ; 0 0.5 0 ; 1 0 0]);
    plot(x,mean(sd_40,2),'-o',x,mean(sd_32,2),'^-',x,mean(sd_8,2),'-s','linewidth',2);
    %errorbar(x,mean(sd_40,2),std(sd_40,0,2),'r-o','linewidth',2);
    %hold on; errorbar(x,mean(sd_32,2),std(sd_32,0,2),'b^-','linewidth',2);
    %hold on; errorbar(x,mean(sd_8,2),std(sd_8,0,2),'-s','linewidth',2,'color',[0 0.5 0]);
    axis([min(x) max(x) 0 1]); grid on;
    ylabel('\sigma_p ( radians )');xlabel('Integration Ratio T_A:T_t_o_t_a_l ( % )');
    legend('40 MHz','32 MHz','8 MHz','location','north');
    
    print -dtiff -r200 chap5images/int_ratio_phase_point8;
    
    PrettifyFigure(16,12,1,0);  errorbar(x,mean(sdev5_40_32,2),std(sdev5_40_32,0,2),'bo:','linewidth',2);
    hold on; errorbar(x,mean(sdev_40_32,2),std(sdev_40_32,0,2),'bo-','linewidth',2);
    hold on; errorbar(x,mean(sdev5_40_8,2),std(sdev5_40_8,0,2),'r^:','linewidth',2);
    hold on;errorbar(x,mean(sdev_40_8,2),std(sdev_40_8,0,2),'r^-','linewidth',2);
    hold on; ax3 = plot(x,sdev_8,'c-','linewidth',2);
    set(ax3,'Color',co_old(4,:));
    axis([min(x) max(x) 10 500]); grid on;
    ylabel('\sigma_d ( mm )');xlabel('Integration Ratio T_A:T_t_o_t_a_l ( % )');
    legend('f_A:f_B = 40:32 MHz, w = 50%','f_A:f_B = 40:32 MHz, w = variable','f_A:f_B = 40:8 MHz, w = 50%','f_A:f_B = 40:8 MHz, w = variable','location','north');
    
    print -dtiff -r200 chap5images/int_ratio_sdev_point8;
    
end








