% Processing for IEEE Sensors conference paper - Multi Frequency
% Disambiguation

clear all;

% Start by figuring out unambiguous range with 40 and 33 MHz.
% Test points only.
load 'fm40'
proc40 = proc_data1;

load 'fm33'
proc33 = proc_data1;
proc_data1 = proc40;
proc_data2 = proc33;
M = 6;
N = 5;
max_distance = 22500;
c = 299792458;    % Speed of light.
weight = 0;
fpb1 = 4;
fpb2 = 4;
fm1 = 40e6;
fm2 = 100e6/3;

proc_data_db = [[] [] [] [] [] []];

for i = 1:256
dd_1 = proc_data1(i,:);
dd_2 = proc_data2(i,:);


r = ones(size(dd_1))*max_distance;
difference = r + c/(2*fm1);
pass = r;

d_2 = dd_2;

for n = 1:M
    
    d_1 = dd_1;
    
    for m = 1:N
        pass = (abs(d_1 - d_2) < difference) & d_1 < max_distance & d_2 < max_distance;
        difference = difference + abs(d_1 - d_2) .* pass - difference .* pass;
        weighted_r = (d_1 .* pass * weight) + (d_2 .* pass * (1-weight));
        r = r + weighted_r - r .* pass;
        d_1 = d_1 + c*500/fm1;
    end
    
    d_2 = d_2 + c*500/fm2;
    
end
proc_data_db = [proc_data_db ; r];
end

mean_db = mean(proc_data_db);
stdev_db = std(proc_data_db);

save('fm40_33x4.mat','proc_data*','mean*','labels','d_actual','std*','fm*','fpb*');

clear all;

% Compile graphs of standard deviations and means for various methods.
load('fm40_33x6');
stdev(:,1) = stdev_db;
mean(:,1) = mean_db;
load('fm40_33x4');
stdev(:,2)= stdev_db;
mean(:,2) = mean_db;
load('fm6x4');
stdev(:,3) = stdev1;
stdev(1,3) = NaN;   % point was saturating
mean(:,3) = mean1;
mean(1,3) = NaN;
x = d_actual/1000;


%fig = figure(1);
PrettifyFigure(figure(1));
plot(x,stdev(:,1),'-o',x,stdev(:,2),':*',x,stdev(:,3),'-.x'); 
legend('(1)','(2)','(3)', 'location','northwest');
%title('Standard deviation for distances up to 10 m');
xlabel('distance (m)'); ylabel('standard deviation (mm)');

PrettifyFigure(figure);%figure('Position',[0 scrsz(4)/2.5 scrsz(3)/3.5 scrsz(4)/3.5]);
%set(fig,'color',[1 1 1]);
plot(x,mean(:,1)-d_actual','-o',x,mean(:,2)-d_actual',':*',x,mean(:,3)-d_actual','-.x');
legend('(1)','(2)','(3)', 'location','southwest');
%title('mean distance error for distances up to 10 m');
xlabel('distance (m)'); ylabel('error (mm)');
