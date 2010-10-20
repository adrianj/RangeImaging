% Look at illumination and sensor modulation waveforms, as well as power
% consumption.


shape_part = 1;
power_part = 0;

if shape_part == 1
    
    freq  =  [1.25 4    8    12   16   20   24   28   32   36   40   44   48   52   56   60   64   68   72   80   88    96];
    id_amp = [2.24 2.24 2.12 2.04 2.76 2.68 3.00 2.68 3.84 2.96 3.52 3.28 2.36 2.80 2.76 2.72];
    id_rms = [1.92 1.93 1.92 1.96 2.00 2.01 2.06 1.99 1.97 1.93 1.89 1.86 1.78 1.75 1.73 1.69];
    id_dcy = [49.8 49.6 49.5 49.0 49.2 47.3 47.3 48.8 45.6 45.4 44.2 43.0 42.6 42.3 44.2 42.9];
    % ic = illumination close (photodiode 1mm away) (mV)
    % id = illumination distant (photodiode 200mm away) (mV)
    % pm = pmd sensor waveform for mod A. (V)
    
    ic_amp = [58.4 59.2 55.2 51.2 60.0 71.2 75.2 72.0 69.6 66.4 68.0 64.0 59.2 56.8 51.2 51.2 50.4 51.2 48.0 54.4 49.6 44.8];
    ic_rms = [46.8 47.3 43.9 44.5 44.0 44.8 45.9 44.2 42.6 40.5 39.0 36.6 35.7 34.9 33.2 32.6 31.9 32.2 31.2 32.0 30.7 28.9];
    ic_dcy = [49.9 49.8 49.1 49.6 47.8 48.8 48.8 49.0 49.3 49.4 49.5 48.5 48.1 45.9 44.4 42.8 42.4 42.2 42.7 46.1 48.4 50.6];
    
    pm_amp = [2.00 2.00 2.00 2.00 2.24 2.32 2.08 2.80 1.20 1.08 1.80 1.40 1.04 1.04 0.84 1.16];
    pm_rms = [1.48 1.48 1.49 1.42 1.41 1.40 1.40 1.44 1.35 1.24 1.05 0.87 0.80 0.84 0.84 0.87];
    pm_dcy = [49.5 48.5 47.2 46.4 44.1 42.1 40.8 47.3 56.7 54.7 40.5 44.2 27.6 77.4 35.6 66.5];
    
    pm_fa =  [9.2 9.24 9.25 9.3 9.3 9.25 9.2  8.55  7.88 6.3 4.6 3.35 2.5 1.88  1.54 1.35]*0.2;   %x200 mV
    id_fa =  [5 4.95  5.18 5.32 5.76 6.18 6.47  6.5  6.38 5.92 5.55 5.06 4.63 4.38  4.17 3.95]*0.2;   %x200 uV
    
    
    
    f = length(pm_amp);
    k = 0.8;
    corr = k*pm_fa.*id_fa(1:f);
    
    m = 0.6;
    n = 10;
    PrettifyFigure(21,11,1,0); ax = plot(freq(1:f),pm_fa, '^m-',freq(1:f),id_fa(1:f),'dy-', freq(1:f),corr,'-ob', freq(1:f),m+n./corr./freq(1:f),'s-','linewidth',2);
    axis([-inf inf 0.2 2]);
    get(ax(4),'color');
    set(ax(4),'color',[0 0.5 0]');
    ylabel('Fundamental Amplitude'); xlabel('Frequency (MHz)');
    legend('Sensor (V)','Photodiode (mV)','Correlation (arbitrary units)','1 / (Correlation x Frequency) (arbitrary units)','location','southwest');
    grid on;
    %set(gca, 'YTick',[0.2 0.5 1 1.2 1.5 2]);
    
    print -dtiff -r200 chap4images/sensor_illumination_v_freq
    
    figure;plot(p_freq,p_dk10,p_freq,p_dk100,p_freq,p_il);
end

if power_part == 1
    
    % Data for power measurements.
    % dk10 is for 10 Hz frame rate, dk100 is for 100 Hz.
    % dk powered at 16 V.
    % illumination powered at 10 V. (16 laser diodes)
    p_freq = [0    1.25 4    8    12   16   20   24   28   32   36   40   44   48   52   56   60   64   68   72   76   80]; % MHz
    p_dk10 = [0.87 0.87 0.91 0.96 1.02 1.07 1.12 1.18 1.25 1.30 1.32 1.33 1.34 1.35 1.35 1.35 1.35 1.32 1.27 1.22 1.18 1.15]; % Amps
    p_il = [0.02 1.28 1.28 1.29 1.30 1.30 1.31 1.32 1.33 1.33 1.34 1.35 1.36 1.37 1.38 1.40 1.41 1.41 1.42 1.42 1.43 1.42]; % Amps
    p_dk100 = [0.87 0.87 0.91 0.95 0.99 1.03 1.06 1.11 1.16 1.21 1.23 1.24 1.25 1.26 1.26 1.26 1.26 1.25 1.22 1.18 1.15 1.13]; % Amps
    p_dk_voltage = 16; % V
    p_il_voltage = 10; % V
    
    p_power_sensor10 = p_dk10*p_dk_voltage;
    p_power_sensor100 = p_dk100*p_dk_voltage;
    p_power_lasers = p_il*p_il_voltage;
    
    PrettifyFigure(16,10,1,0); 
    plot(p_freq,p_power_sensor10,'-o',p_freq,p_power_sensor100,'-o',p_freq,p_power_lasers,'--o','linewidth',2);
    grid on; axis([1.25 80 0 30]);
    ylabel('Power (Watts)');
    xlabel('Modulation frequency (MHz)');
    legend('Sensor @ 10 HZ','Sensor @ 100 Hz','Illumination','location','northwest');
    
    print -dtiff -r200 chap4images\power_pmd
    
    % Data for Waikato Uni Image Intensifier System
    % 'Sensor' comprises the DALSA camera, image intensifier and dds/fpga
    w_freq = [1 1.25 4 8 12 16 20 24 28 32 36 40 44 48 52 56 60 64 68 72 76 80];
    w_cam_current10 = 0.969; % DALSA Camera current in Amps @ 10 Hz
    w_cam_current100 = 1.06; % Amps @ 100 Hz
    w_cam_voltage = 12.1; % V
    w_il_voltage = 8.1; % V
    w_dds_voltage = 12.1; % V
    w_ii_voltage = 80.7; % V  (4 laser diodes)
    
    w_il_current = [519 520 517 511 508 505 500 497 502 510 521 520 519 517 523 526 522 536 545 551 553 565]/1000; % A
    
    w_dds_current10 = [368 371 369 372 374 375 375 371 374 378 378 379 375 372 371 372 375 376 378 376 373 377]/1000;
    w_dds_current100 = [370 374 372 375 377 378 378 374 377 381 381 382 378 375 374 375 379 380 382 379 377 381]/1000;
    
    % These measurements are kind of redundant, and superceded by the Wall
    % Meter measurements.
    w_ii_current10 = [46 48 67 93 120 142 178 171 184 213 258 270 307 307 340 363 364 358 352 361 384 390]/1000; % A
    w_ii_current100 = [35 37 51 71 92 108 136 130 142 162 198 208 236 236 259 281 281 277 269 270 292 301]/1000; % A
    
    wall_meter10 = [21 21 22 23 25 26 28 28 28 29 31 34 35 35 38 37 38 38 37 39 41 45]; % Watts for all image intensifier @ 10 Hz
    wall_meter100 = [21 22 22 22 23 24 26 25 26 27 29 30 31 31 32 33 33 34 33 33 36 35]; % Watts for all image intensifier @ 100 Hz
    
    w_power_sensor10 = w_cam_current10*w_cam_voltage + wall_meter10 + w_dds_current10*w_dds_voltage;
    w_power_sensor100 = w_cam_current100*w_cam_voltage + wall_meter100 + w_dds_current100*w_dds_voltage;
    w_power_lasers = w_il_voltage*w_il_current;

    PrettifyFigure(16,10,1,0); 
    plot(w_freq,w_power_sensor10,'-s',w_freq,w_power_sensor100,'-s',w_freq,w_power_lasers,'--s','linewidth',2);
    grid on; axis([1.25 80 0 70]);
    ylabel('Power (Watts)');
    xlabel('Modulation frequency (MHz)');
    legend('Sensor @ 10 HZ','Sensor @ 100 Hz','Illumination','location','northwest');
    
    print -dtiff -r200 chap4Images\power_waikato
    
    ff = w_freq(2:end);
    w_p = [w_power_lasers(2:end) ; w_power_sensor10(2:end)+w_power_lasers(2:end)];
    p_p = [p_power_lasers(2:end) ; p_power_sensor10(2:end)+p_power_lasers(2:end)];
    
    PrettifyFigure(16,10,1,0); 
    plot(ff,w_p(2,:),'-s',ff,p_p(2,:),'-o','linewidth',2);
    
    grid on; axis([1.25 80 0 70]);
    ylabel('Power (Watts)');
    xlabel('Modulation frequency (MHz)');
    legend('Waikato Total','Victoria Total','location','northwest');
    print -dtiff -r200 chap4Images\power_both
    
end