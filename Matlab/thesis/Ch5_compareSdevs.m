% Compare with integration ratio.

% Assume Amplitude is directly relate to T where T is integration
% time. And that sdev is directly proprtional to A.
set_avi_folder;
fA = 40e6;
FBs = [32e6 8e6];

folder = [avi_folder 'multifreq/'];

RATIOS = [0:1/20:1];
MAX_SIGMA = 9.999;
N = 10000;

err_nn = zeros(length(FBs),length(RATIOS),5);
sdev_nn = zeros(length(FBs),length(RATIOS),5);
SIGMA_A = zeros(length(FBs),length(RATIOS));
SIGMA_B = zeros(length(FBs),length(RATIOS));
sim = 1;
nonSim = 1;
do_8 = 0;
do_40 = 0;

if sim == 1
    N = 10000;
    fE = 8e6;
    dE = 150e9/fE;
    
    MMA = [5 2 5 1];
    MMB = [4 1 1 1];
    
    MMR = MMB./MMA;
    sE = 10.^[0.8:0.05:3]; %sdev in mrad
    sdevs = zeros(length(sE),length(MMA)*2);
    errr = sdevs;
    
    diff_plot_done = 0;
    
    for s = 1:length(sE)
        s8 = sE(s)/1000/2/pi;
        
        for f = 1:length(MMA)
            MA = MMA(f);
            MB = MMB(f);
            MR = MMR(f);
            fA = fE*MA;
            fB = fE*MB;
            duA = dE/MA;
            duB = dE/MB;
            
            d = (0.25+rand(1,N)*0.5)*dE;
            d = dE/4:dE/N/2:3*dE/4-dE/N/2;
            
            pA = mod(d,duA)/duA;
            pB = mod(d,duB)/duB;
            
            percent_increase = 2;
            % Scale sdevs for each frequency based on 8MHz + 2%/MHz
            sA = s8*(1+(fA-fE)*percent_increase/100/1e6);
            sB = s8*(1+(fB-fE)*percent_increase/100/1e6);
            
            noiseA = randn(1,N)*sA;
            noiseB = randn(1,N)*sB;
            pnA = mod(pA+noiseA,1);
            pnB = mod(pB+noiseB,1);
            
            w = sB^2/(sB^2 + sA^2*MR^2);
            
            dd = findUnambiguous(pnA,pnB,fA,fB,1,w);
            if f == length(MMA)
                dd = pnA*duA;
            end
            
            err = abs(d-dd);
            err_n = err>duA/2 & err<dE-duA/2;
            diff = d-dd;
            diff_err_free = diff(~err_n);
            %if sum(err_n)>0
            %    figure; plot(err);
            %end
            
            sdevs(s,f*2-1) = std(diff);%_err_free);
            errr(s,f*2-1) = sum(err_n)/N*100;
            
            % Now use formula to estimate it
            sd = dE/MA/MB*sqrt((w*sA*MB)^2+((1-w)*sB*MA)^2);
            if f == length(MMA)
                sd = sA*duA;
            end
            sdevs(s,f*2) = sd;
            
             
            
            serror = sqrt((sA*MB)^2+(sB*MA)^2);
            perror = 1 - erf(1/(2*sqrt(2)*serror));
            errr(s,f*2) = perror*100;
            if sum(err_n(1:200))>2 && diff_plot_done == 0 && sE(s) > 190
                PrettifyFigure(21,11,1,0); plot(diff(1:200));
                xlabel('sample number');
                ylabel('distance measurement error (mm)');
                print -dtiff -r200 chap5images/sim_error_example;
                sE(s)
                diff_plot_done = 1;
            end
        end
        
    end
    dE = 150e3/8;
        Reasonable_sp8 = 0.1;
        
        Reasonable_sp40 = Reasonable_sp8 * (1+(40-8)*percent_increase/100);
        Reasonable_sp16= Reasonable_sp8 * (1+(16-8)*percent_increase/100);
        Reasonable_sp32 = Reasonable_sp8 * (1+(32-8)*percent_increase/100);
        Reasonable_sd8 = Reasonable_sp8 * dE/2/pi;
        Reasonable_sd40_8 = dE/sqrt((5/Reasonable_sp40*2*pi)^2+(1/Reasonable_sp8*2*pi)^2);
        Reasonable_sd40_32 = dE/sqrt((5/Reasonable_sp40*2*pi)^2+(4/Reasonable_sp32*2*pi)^2);
        w40_32 = Reasonable_sp32.^2/(Reasonable_sp32^2+(Reasonable_sp40*4/5)^2);
        w40_8 = Reasonable_sp8.^2/(Reasonable_sp8^2+(Reasonable_sp40*1/5)^2);
        
        Reasonable_sd40_8 = dE/5*sqrt((w40_8*Reasonable_sp40/2/pi*1)^2 + ((1-w40_8)*Reasonable_sp8/2/pi*5)^2);
        Reasonable_sd40_32 = dE/5/4*sqrt((w40_32*Reasonable_sp40/2/pi*4)^2 + ((1-w40_32)*Reasonable_sp32/2/pi*5)^2);
    
    PrettifyFigure(21,11,1,0);
    %set(0,'DefaultAxesColorOrder','remove');
    leg_labels = cell(length(MMA)*2,1);
    for i = 1:length(MMA)
        leg_labels{i} = sprintf('%d:%d MHz simulation',fE*MMA(i)/1e6,fE*MMB(i)/1e6);
        leg_labels{i+length(MMA)} = sprintf('%d:%d MHz theory',fE*MMA(i)/1e6,fE*MMB(i)/1e6);
    end
    leg_labels{length(MMA)} = '8 MHz simulation';
    leg_labels{2*length(MMA)} = '8 MHz theory';
    co_old = get(0,'defaultaxescolororder');
    set(0,'DefaultAxesColorOrder',co_old(1:length(MMA),:));
    loglog(sE,sdevs(:,1),'o',sE,sdevs(:,3),'s',sE,sdevs(:,5),'^',sE,sdevs(:,7),'d',sE,sdevs(:,2),'-',sE,sdevs(:,4),'-',sE,sdevs(:,6),'-',sE,sdevs(:,8),'-','linewidth',2);
    axis([7 1000 4 5000]);
    ylabel('distance standard deviation, \sigma_d (mm)');
    xlabel('phase standard deviation, \sigma_p, for equivalent 8 MHz measurement (milliradians)');
    legend(leg_labels,'location','southeast');
    grid on;
    
    print -dtiff -r200 chap5images/sdev_sim_phase_v_distance;
    % Graph of phase sdev vs distance sdev for different MA:MB
    
    set(0,'DefaultAxesColorOrder',co_old(1:length(MMA)-1,:));
    PrettifyFigure(21,11,1,0);
    loglog(sE,errr(:,1),'o',sE,errr(:,3),'s',sE,errr(:,5),'^',sE,errr(:,2),'-',sE,errr(:,4),'-',sE,errr(:,6),'-','linewidth',2);
    axis([40 inf 0.01 100]);
    grid on;
    leg_labels = cell((length(MMA)-1)*2,1);
    for i = 1:length(MMA)-1
        leg_labels{i} = sprintf('%d:%d MHz simulation',fE*MMA(i)/1e6,fE*MMB(i)/1e6);
        leg_labels{i+length(MMA)-1} = sprintf('%d:%d MHz theory',fE*MMA(i)/1e6,fE*MMB(i)/1e6);
    end
    legend(leg_labels,'location','northwest');
    xlabel('phase standard deviation, \sigma_p, for equivalent 8 MHz measurement (milliradians)');
    ylabel('error rate (%)');
    set(0,'DefaultAxesColorOrder',co_old);
    print -dtiff -r200 chap5images/erate_sim_v_phase;
    
    
end
if nonSim == 1
    
    
    
    
    fA = 40e6; fB = 32e6; MA = 5; MB = 4; duA = 150e9/fA; duB = 150e9/fB;
    dE = 150e9/gcd(fA,fB);
    load([folder 'DIST_BENCHMARK']);
    load([folder 'DIST_40_32_5_100_0']);
    width = 128; height = 60;
    
    figure; imagesc(reshape(d_benchmark,height,width));
    figure; imagesc(reshape(m_benchmark,height,width));
    %figure; imagesc(DIST_40_32_5_100_0);
    [ppf,frames] = size(DIST_40_32_5_100_0);
    RATIOS = [0 128 255];
    
    % Test point 6 = [38:53,25:43]
    % Test point 8 = [56:67,25:39]
    %tp_distance_actual = [2501 2501 2501 2501 3745 3745 3745 3745 5005 5005 5005 5005 6253 6253 6253 6253 7499 7499 8752 8752 11300 11300];
    
    %tp_x = [67 75 52 44 111 111 97 97 23 23 40 40 71 71 57 57 45 57 80 70 73 81];
    %tp_y = [53 53 53 53   3  11  3 11 26 34 26 34 25 33 25 33 12 12 12 12  1  1];
    tp_x = [68 50 111 97 23 40 71 57 45 57 80 70 76];
    tp_y = [53 53   7  7 28 28 28 28 12 12 12 12  1];
    tp_distance_actual = [2501 2501 3745 3745 5005 5005 6253 6253 7499 7499 8752 8752 11300];
    
    p_h = 8; p_w = 8;
    index = zeros(length(tp_x),p_h*p_w);
    %d_bench = index;
    %e_bench = index;
    %im = reshape(MAG_40_32_5_100_0(:,1),60,128);
    %figure; imagesc(im(1:end-20,1:end))
    for ttp = 1:length(tp_x)
        i = 1;
        col_i = tp_x(ttp);
        row_i = tp_y(ttp);
        for col = [col_i:col_i+p_w-1]-1
            index(ttp,(i-1)*p_h+1:i*p_h) = [row_i:row_i+p_h-1]+height*col;
            i = i+1;
        end
        %figure; imagesc(reshape(DIST_40_32_5_100_0(index(ttp,:),1),p_h,p_w))
        %mean(mean(DIST_40_32_5_100_0(index(ttp,:),1)))
        
        %d_bench(ttp,:) = d_benchmark(index(ttp,:));
        %e_bench(ttp,:) = e_benchmark(index(ttp,:));
        
    end
    d_bench = tp_distance_actual'*ones(1,frames);
    
    
    %d_bench = d_benchmark(index)*ones(1,frames);
    %e_bench = e_benchmark(index)*ones(1,frames);
    %e_bench_8 = d_benchmark(index)*ones(1,frames)*5/dE;
    if do_40 == 1
        d_40 = zeros(length(RATIOS),p_h*p_w,frames,length(tp_x));
        d_32 = d_40;
        d5_40_32 = d_40;
        p_40_32 = d_40;
        p_32_40 = d_40;
        d_40_32 = d_40;
        
        s_40_32 = zeros(length(RATIOS),p_h*p_w,length(tp_x));
        e_40_32 = d_40;
        m_40_32 = d_40;
        m_32 = d_40;
        s = zeros(p_h*p_w,1);
        
        
        fA = 40e6;
        fB = 32e6;
        duA = 150e9/fA;
        duB = 150e9/fB;
        
        
        e5_40_32 = zeros(length(RATIOS),p_h*p_w,frames);
        s5_40_32 = zeros(length(RATIOS),p_h*p_w);
        
        for r = 1:length(RATIOS)
            fprintf('%d\n',RATIOS(r));
            s40 = sprintf('%s/DIST_40_32_5_100_%d',folder,RATIOS(r));
            s32 = sprintf('%s/DIST_32_40_5_100_%d',folder,RATIOS(r));
            m40 = sprintf('%s/MAG_40_32_5_100_%d',folder,RATIOS(r));
            m32 = sprintf('%s/MAG_32_40_5_100_%d',folder,RATIOS(r));
            load(s40);
            
            
            for ttp = 1:length(tp_x)
                ttp_s = sprintf('%d',ttp);
                eval(['d = ' s40 '(index(' ttp_s ',:),:); d_40(r,:,:,' ttp_s ') = d(:,:);']);
                eval(['d = ' s32 '(index(' ttp_s ',:),:); d_32(r,:,:,' ttp_s ') = d(:,:);']);
                eval(['d = ' m40 '(index(' ttp_s ',:),:); m_40_32(r,:,:,' ttp_s ') = d(:,:);']);
                eval(['d = ' m32 '(index(' ttp_s ',:),:); m_32(r,:,:,' ttp_s ') = d(:,:);']);
                
                w = (squeeze(m_40_32(r,:,:,ttp))*MA).^2 ./ ((squeeze(m_40_32(r,:,:,ttp))*MA).^2 + ((squeeze(m_32(r,:,:,ttp))*MB).^2));
                pA = squeeze(d_40(r,:,:,ttp))/duA; pB = squeeze(d_32(r,:,:,ttp))/duB;
                
                p_40_32(r,:,:,ttp) = pA*2*pi;
                p_32_40(r,:,:,ttp) = pB*2*pi;
                
                [d ka kb ee] = findUnambiguous(pA,pB,fA,fB,1,w);
                e_b = ones(size(d))*tp_distance_actual(ttp);
                err = abs(d-e_b)>duA/2;
                e_40_32(r,:,:,ttp) = err;
                d_40_32(r,:,:,ttp) = d;
                
                s_40_32(r,:,ttp) = std(d,0,2);
            end
            e = squeeze(sum(e_40_32(r,:,:,:),2));
            figure; plot(e');
            clear('*_5_100_*');
        end
        
        sdev_40_32 = s_40_32;
        error_40_32 = squeeze(sum(e_40_32,3))/frames*100';
        sdev5_40_32 = s5_40_32;
        error5_40_32 = squeeze(sum(e5_40_32,3))/frames*100';
        save([folder 'COMPARE_SDEVS_40_32'], 'sdev_40_32','error_40_32','sdev5_40_32','error5_40_32','d_40','d_32','m_40_32','m_32','p_40_32','p_32_40');
    end
    
    %%%%%%%%%%%%%%%%%%%
    if do_8 == 1
        dd_40 = zeros(length(RATIOS),p_h*p_w,frames,length(tp_x));
        d_8 = d_40;
        d5_40_8 = d_40;
        p_40_8 = d_40;
        p_8_40 = d_40;
        d_40_8 = d_40;
        
        s_40_8 = zeros(length(RATIOS),p_h*p_w,length(tp_x));
        e_40_8 = d_40;
        m_40_8 = d_40;
        m_8 = d_40;
        s = zeros(p_h*p_w,1);
        
        fA = 40e6;
        fB = 8e6;
        duA = 150e9/fA;
        duB = 150e9/fB;
        
        
        
        
        e5_40_8 = zeros(length(RATIOS),p_h*p_w,frames);
        s5_40_8 = zeros(length(RATIOS),p_h*p_w);
        
        for r = 1:length(RATIOS)
            fprintf('%d\n',RATIOS(r));
            s40 = sprintf('%s/DIST_40_8_5_100_%d',folder,RATIOS(r));
            s8 = sprintf('%s/DIST_8_40_5_100_%d',folder,RATIOS(r));
            m40 = sprintf('%s/MAG_40_8_5_100_%d',folder,RATIOS(r));
            m8 = sprintf('%s/MAG_8_40_5_100_%d',folder,RATIOS(r));
            load(s40);
            
            
            for ttp = 1:length(tp_x)
                ttp_s = sprintf('%d',ttp);
                eval(['d = ' s40 '(index(' ttp_s ',:),:); d_40_8(r,:,:,' ttp_s ') = d(:,:);']);
                eval(['d = ' s8 '(index(' ttp_s ',:),:); d_8(r,:,:,' ttp_s ') = d(:,:);']);
                eval(['d = ' m40 '(index(' ttp_s ',:),:); m_40_8(r,:,:,' ttp_s ') = d(:,:);']);
                eval(['d = ' m8 '(index(' ttp_s ',:),:); m_8(r,:,:,' ttp_s ') = d(:,:);']);
                
                w = (squeeze(m_40_8(r,:,:,ttp))*MA).^2 ./ ((squeeze(m_40_8(r,:,:,ttp))*MA).^2 + ((squeeze(m_8(r,:,:,ttp))*MB).^2));
                pA = squeeze(d_40_8(r,:,:,ttp))/duA; pB = squeeze(d_8(r,:,:,ttp))/duB;
                
                p_40_8(r,:,:,ttp) = pA*2*pi;
                p_8_40(r,:,:,ttp) = pB*2*pi;
                
                [d ka kb ee] = findUnambiguous(pA,pB,fA,fB,1,w);
                e_b = ones(size(d))*tp_distance_actual(ttp);
                err = abs(d-e_b)>duA/2;
                e_40_8(r,:,:,ttp) = err;
                d_40_8(r,:,:,ttp) = d;
                
                s_40_8(r,:,ttp) = std(d,0,2);
            end
            e = squeeze(sum(e_40_8(r,:,:,:),2));
            figure; plot(e');
            
            clear('*_5_100_*');
        end
        
        
        sdev_40_8 = s_40_8;
        error_40_8 = squeeze(sum(e_40_8,3))/frames*100';
        sdev5_40_8 = s5_40_8;
        error5_40_8 = squeeze(sum(e5_40_8,3))/frames*100';
        save([folder 'COMPARE_SDEVS_40_8'], 'sdev_40_8','error_40_8','sdev5_40_8','error5_40_8','d_40_8','d_8','m_40_8','m_8','p_40_8','p_8_40');
        
    end
    load([folder 'COMPARE_SDEVS_40_32']);
    load([folder 'COMPARE_SDEVS_40_8']);
    
    
    p_40_32_full = squeeze(p_40_32(2,:,:,:));
    p_40_32_full = cleverUnwrap(reshape(shiftdim(p_40_32_full,2),p_h*p_w*length(tp_x),frames),2*pi)';
    m_40_32_full = squeeze(m_40_32(2,:,:,:));
    m_40_32_full = reshape(shiftdim(m_40_32_full,2),p_h*p_w*length(tp_x),frames)';
    
    p_40_8_full = squeeze(p_40_8(2,:,:,:));
    p_40_8_full = cleverUnwrap(reshape(shiftdim(p_40_8_full,2),p_h*p_w*length(tp_x),frames),2*pi)';
    m_40_8_full = squeeze(m_40_8(2,:,:,:));
    m_40_8_full = reshape(shiftdim(m_40_8_full,2),p_h*p_w*length(tp_x),frames)';
    
    p_32_40_full = squeeze(p_32_40(2,:,:,:));
    p_32_40_full = cleverUnwrap(reshape(shiftdim(p_32_40_full,2),p_h*p_w*length(tp_x),frames),2*pi)';
    m_32_40_full = squeeze(m_32(2,:,:,:));
    m_32_40_full = reshape(shiftdim(m_32_40_full,2),p_h*p_w*length(tp_x),frames)';
    
    p_8_40_full = squeeze(p_8_40(2,:,:,:));
    p_8_40_full = cleverUnwrap(reshape(shiftdim(p_8_40_full,2),p_h*p_w*length(tp_x),frames),2*pi)';
    m_8_40_full = squeeze(m_8(2,:,:,:));
    m_8_40_full = reshape(shiftdim(m_8_40_full,2),p_h*p_w*length(tp_x),frames)';
    
    
    w = squeeze((m_40_32_full*5).^2 ./ ((m_40_32_full*5).^2 + (m_32_40_full*4).^2));
    d_40_32_du = findUnambiguous(p_40_32_full,p_32_40_full,40e6,32e6,2*pi,w);
    w_40_32 = mean(mean(w));
    
    psd_40_32 = std(p_40_32_full);
    psd_32_40 = std(p_32_40_full);
    dsd_40_32 = std(d_40_32_du);
    
    [psd_32_40,i_32_40] = sort(psd_32_40);
    psd_40_32i = psd_40_32(i_32_40);
    [psd_40_32,i_40_32] = sort(psd_40_32);
    ds_40_32 = dsd_40_32(i_32_40);
    
    %figure; plot(psd_32_40,psd_40_32);
    %figure; plot(psd_32_40,ds_40_32,'o');
    
    w = squeeze((m_40_8_full*5).^2 ./ ((m_40_8_full*5).^2 + (m_8_40_full*1).^2));
    d_40_8_du = findUnambiguous(p_40_8_full,p_8_40_full,40e6,8e6,2*pi,w);
    w_40_8 = mean(mean(w));
    
    d_8_40_du = p_8_40_full*150e3/8/2/pi;
    
    psd_40_8 = std(p_40_8_full);
    psd_8_40 = std(p_8_40_full);
    dsd_40_8 = std(d_40_8_du);
    dsd_8_40 = std(d_8_40_du);
    %figure; plot(ds_8);
    
    
    [psd_8_40,i_8_40] = sort(psd_8_40);
    %psd_40_8 = psd_40_8(i);
    [psd_40_8,i_40_8] = sort(psd_40_8);
    ds_40_8 = dsd_40_8(i_8_40);
    ds_8_40 = dsd_8_40(i_8_40);
    
    psd_40_32 = psd_40_32*1000;
    psd_32_40 = psd_32_40*1000;
    psd_40_8 = psd_40_8*1000;
    psd_8_40 = psd_8_40*1000;
    
    
    
    
    % figure; plot(psd_8,psd_32_40);
    scale = 0.34628;
    %r = [1:length(psd_8_40)/2];
    r = [1:length(psd_8_40)];
    
    pp_40_32 = psd_40_32;
    pp_32_40 = psd_32_40;
    pp_40_8 = psd_40_8;
    pp_8_40 = psd_8_40;
    %pp_40_32 = (psd_40_32+12.579)/2.1395;
    pp_32_40 = (psd_32_40)/1.30;
    pp_40_8 = (psd_8_40)/1.64;
    %pp_8_40 = (psd_8_40);
    %pp_8 = psd_8;
    
    PrettifyFigure(21,11,1,0); a = plot(psd_8_40(r),psd_40_32(r),'ob',psd_8_40(r), psd_32_40(r),  '^r', psd_8_40(r),psd_8_40(r), 'dc',...
        0:100,[0:100]*1.64,'-b',0:100,[0:100]*1.3,'-r','linewidth',2);
    set(a(3),'Color',co_old(4,:));
    legend('40 MHz','32 MHz','8 MHz','8 MHz x1.64','8 MHz x1.30','location','northwest');
    grid on;
    xlabel('\sigma_p(8 MHz)  (milliradians)');
    ylabel('\sigma_p(f)  (milliradians)');
    axis([0 100 0 170]);
    print -dtiff -r200 chap5images/exp_phase8_vs_phaseF;

    
    dt_8 = psd_8_40*dE/2/pi/1000;
    
    dt_40_32 = dE./sqrt((5./psd_8_40*2*pi*1000).^2 + (4./psd_8_40*2*pi*1000).^2);
    
    
    
    
    PrettifyFigure(21,11,1,0); a = loglog(pp_32_40,ds_40_32,'ob',pp_8_40,ds_40_8,'^r',pp_8_40,ds_8_40,'dc',sE,sdevs(:,2),'-b',sE,sdevs(:,6),'-r',sE,sdevs(:,8),'-c','linewidth',2);
    set(a(3),'Color',co_old(4,:));
    set(a(6),'Color',co_old(4,:));
    grid on;
    legend('40:32 MHz','40:8 MHz','8 MHz','40:32 MHz theory','40:8 MHz theory','8 MHz theory','location','southeast');
    axis([7 1000 4 5000]);
    ylabel('distance standard deviation, \sigma_d (mm)');
    xlabel('phase standard deviation, \sigma_p, for equivalent 8 MHz measurement (milliradians)');
    print -dtiff -r200 chap5images/sdev_exp_phase_v_distance;
    
    d_actual = tp_distance_actual;
    for i = 1:p_h*p_w-1
        d_actual = [d_actual tp_distance_actual];
    end
    err_40_32_full = d_40_32_du;
    err_40_8_full = d_40_8_du;
    for i = 1:frames
        err_40_32_full(i,:) = d_40_32_du(i,:)-d_actual;
        err_40_8_full(i,:) = d_40_8_du(i,:)-d_actual;
    end
    
    e_40_32_full = abs(err_40_32_full)>duA;
    e_40_8_full = abs(err_40_8_full)>duA;
    %e_40_32_full = squeeze(e_40_32(2,:,:,:));
    %e_40_32_full = cleverUnwrap(reshape(shiftdim(e_40_32_full,2),p_h*p_w*length(tp_x),frames),2*pi)';
    
    esum_40_32 = sum(e_40_32_full)/frames*100; esums_40_32 = esum_40_32(i_32_40);
    
    %e_40_8_full = squeeze(e_40_8(2,:,:,:));
    %e_40_8_full = cleverUnwrap(reshape(shiftdim(e_40_8_full,2),p_h*p_w*length(tp_x),frames),2*pi)';
    esum_40_8 = sum(e_40_8_full)/frames*100; esums_40_8 = esum_40_8(i_40_8);
    
    PrettifyFigure(21,11,1,0); loglog(pp_32_40,esums_40_32,'bo',pp_32_40,esums_40_8,'r^',sE,errr(:,2),'-b',sE,errr(:,6),'-r','linewidth',2);
    axis([40 inf 0.01 100]);
    grid on;
    legend('40:32 MHz','40:8 MHz','40:32 MHz theory','40:8 MHz theory','location','northwest');
    xlabel('phase standard deviation, \sigma_p, for equivalent 8 MHz measurement (milliradians)');
    ylabel('error rate (%)');
    print -dtiff -r200 chap5images/erate_exp_v_phase;
   
    
    
    
end





