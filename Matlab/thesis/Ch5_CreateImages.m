% Create fullscreen images for Thesis Chapter 5.

clear all;
close all;
set_avi_folder
setFileName = [avi_folder 'multifreq'];
width = 128;
height = 60;
p_h = 8; p_w = 8;

getSetParams(setFileName, setFileName);
load(setFileName);
ADC_GAIN = 6/(1+5*((63-adc_gain_left)/63));
V_MAX = 4;
ADC_STEPS = 2^16;
ADC_FACTOR = V_MAX/ADC_STEPS/ADC_GAIN;

part1 = 1;  % 8 MHz images
part2 = 1;  % 40+32 MHz images

if part1 == 1

load([setFileName '/DIST_8_8_240_36000_0']);
dlong_8_8 = mean(DIST_8_8_240_36000_0,2);
mlong_8_8 = mean(MAG_8_8_240_36000_0,2);


load([setFileName '/DIST_8_8_240_12000_0']);
dshort_8_8 = mean(DIST_8_8_240_12000_0,2);
mshort_8_8 = mean(MAG_8_8_240_12000_0,2);


dc = dshort_8_8;
dc(mshort_8_8<40) = 0;
maxd = 12500;%max(dc)+100;
dc(dc==0) = maxd;
mind = min(dc);
maxd = max(dc);

PrettifyFigure(18,10,1,0);
imagesc(reshape(dc,height,width),[0 maxd]);
colormap(jet(256)); hcb = colorbar('location','southoutside');
    axis off;
    text(width/2,77,'Distance ( mm )','horizontalalignment','center');
    set(gca,'Position',[0.012 0.24 0.96 0.75]);
    set(hcb,'XTickMode','manual');
    set(hcb,'XTick',[0:1250:12500]);
print -dtiff -r200 chap5images/scene_dist_8MHz;


% Draw white boxes within magnitude image.
tp_x = [68 50 111 97 23 40 71 57 45 57 80 70 76];
tp_y = [53 53   7  7 28 28 28 28 12 12 12 12  1];
index = zeros(length(tp_x),p_h*p_w);
mc = mshort_8_8*ADC_FACTOR*1000;
minm = min(mc);
maxm = max(mc);
for ttp = 1:length(tp_x)
    i = 1;
    col_i = tp_x(ttp);
    row_i = tp_y(ttp);
    for col = [col_i:col_i+p_w-1]-1
        index(ttp,(i-1)*p_h+1:i*p_h) = [row_i:row_i+p_h-1]+height*col;
        i = i+1;
    end
    mc(index(ttp,:)) = 1000;
end

% draw black borders around white boxes.
mc = reshape(mc,height,width);
for i = 1:length(tp_x)
   mc(tp_y(i):tp_y(i)+7,tp_x(i)) = minm; 
   mc(tp_y(i):tp_y(i)+7,tp_x(i)+7) = minm; 
   mc(tp_y(i),tp_x(i):tp_x(i)+7) = minm;
   mc(tp_y(i)+7,tp_x(i):tp_x(i)+7) = minm;
end



PrettifyFigure(18,10,1,0);
imagesc(log10(mc));
colormap(gray(256)); colorbar('location','southoutside');
%text(width/2,74,'Amplitude, log_1_0(V_A - V_B) ( mV
%)','horizontalalignment','center');
    set(gca,'Position',[0.012 0.24 0.96 0.75]);
text(width/2,77,'Amplitude, log_1_0(V_p) ( mV )','horizontalalignment','center');
axis off;
for i = 1:length(tp_x)
    ns = sprintf('%d',i);
    text(tp_x(i)+3-floor(i/10),tp_y(i)+4,ns,'fontsize',12,'fontweight','bold');
end
  %title('Amplitude 40 MHz');
print -dtiff -r200 chap5images/scene_mag_8MHz_labelled;

end

if part2 == 1
    load([setFileName '/DIST_40_32_240_12000_0']);
    d_40 = cleverUnwrap(DIST_40_32_240_12000_0,150e3/40);
    d_40 = mean(d_40,2);
    m_40 = mean(MAG_40_32_240_12000_0,2);
    load([setFileName '/DIST_32_32_240_12000_0']);
    d_32 = cleverUnwrap(DIST_32_32_240_12000_0,150e3/32);
    d_32 = mean(d_32,2);
    m_32 = mean(MAG_32_32_240_12000_0,2);
    
    fA = 40e6; fB = 32e6;
    MA = 5; MB = 4; MR = MB/MA;
    duA = 150e9/fA; duB = 150e9/fB;
    w = m_40.^2./(m_40.^2+(m_32*MR).^2);
    dE = 150e3/8;
    
    pA = d_40*2*pi/duA;
    pB = d_32*2*pi/duB;
    
    d = findUnambiguous(pA,pB,fA,fB,2*pi,w);
   
    d(d>maxd) = maxd;
    d(d<mind) = mind;
    
    %PrettifyFigure(21,11,1,0); 
    PrettifyFigure(18,8,1,0);
    imagesc(reshape(d_40,height,width),[0 maxd]);
    colormap(jet(256)); hcb = colorbar('location','southoutside');
    text(width/2,74,'Distance ( mm )','horizontalalignment','center');
    axis off;
    %text(width/2,64,'Distance ( mm )','horizontalalignment','center');
    set(gca,'Position',[0.012 0.02 0.96 0.97]);
    %set(gca,'Position',[0.012 0.192 0.96 0.76]);
    %set(hcb,'XTickMode','manual');
    %set(hcb,'XTick',[0:1250:12500]);
    %title('(a)')
    %title('Distance 40 MHz');
    print -dtiff -r200 chap5images/scene_dist_40MHz;
    
    %PrettifyFigure(21,11,1,0); 
    PrettifyFigure(18,8,1,0);
    imagesc(reshape(d_32,height,width),[0 maxd]);
    colormap(jet(256)); 
    %hcb = colorbar('location','southoutside');
    %text(width/2,74,'Distance ( mm )','horizontalalignment','center');
    axis off;
    %text(width/2,64,'Distance ( mm )','horizontalalignment','center');
    set(gca,'Position',[0.012 0.02 0.96 0.97]);
    %set(gca,'Position',[0.012 0.192 0.96 0.76]);
    %set(hcb,'XTickMode','manual');
    %set(hcb,'XTick',[0:1250:12500]);
    %title('(b)');
    %title('Distance 32 MHz');
    print -dtiff -r200 chap5images/scene_dist_32MHz;
    
    PrettifyFigure(18,10,1,0);
    imagesc(reshape(d,height,width),[0 maxd]);
    colormap(jet(256)); 
    hcb = colorbar('location','southoutside');
    axis off;
    text(width/2,77,'Distance ( mm )','horizontalalignment','center');
    set(gca,'Position',[0.012 0.24 0.96 0.75]);
    set(hcb,'XTickMode','manual');
    set(hcb,'XTick',[0:1250:12500]);
    %title('(c)');
    %title('Distance 40 + 32 MHz');
    print -dtiff -r200 chap5images/scene_dist_40_32MHz;
    
end
