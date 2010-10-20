% h = PrettifyFigure(width, height, setDefaults, AxesLineStyleOrder)
% Makes a figure look pretty, with a standard size and background colour
% width = width of figure in cm (set to 0 for Full Screen)
% height = ... you figure it out...
% setDefaults = 0 to assign default marker styles {'o','s','d','^','v','<','>','x','*'}, linewidths (2), and line styles {'-','--',':','-.'}.
% AxesLineStyleOrder is a vector specifying LineStyles, default (set to 0) = ':o|:^|:s|:v|:<|:>|:p|:h'
% returns the figure handle.
% Example: h = PrettifyFigure(8, 6, 0, 0), gives figure 8x6 cm size, default marker styles, default line styles.
function h = PrettifyFigure(width, height, setDefaults, AxesLineStyleOrder)
figHandle = figure;
set(figHandle, 'Units', 'centimeters');

fs = 10;
if setDefaults == 0
    fs = 12;
end

if width == 0
    set(figHandle, 'Units', 'pixels');
    scrsz = get(0,'ScreenSize');
    set(figHandle,'Position',scrsz);
    set(figHandle, 'Units', 'centimeters');
else
    set(figHandle,'Position',[1 2 width height]);
    w = 1/(0.62*width-0.1);
    %w = 0.055
    h = 1/(0.82*height-0.35);
    %h = 0.035
    set(0,'DefaultAxesPosition',[w h 1-1.3*w 1-1.3*h]);
end
set(0, 'DefaultFigureColor','w');


if AxesLineStyleOrder == 0
    AxesLineStyleOrder = ':o|:^|:s|:v|:<|:>|:p|:h';
end
set(figHandle,'DefaultAxesLineStyleOrder',AxesLineStyleOrder);
set(figHandle, 'PaperPositionMode', 'auto');

if setDefaults == 0
    set(0,'DefaultLineLineWidth',1.5);
    set(0, 'DefaultLineMarkerSize',6);
    set(0, 'DefaultAxesFontSize',fs);
    set(0, 'DefaultTextFontSize',fs);
    set(figHandle,'DefaultAxesColorOrder',[0 0 0]);
    set(figHandle,'DefaultAxesLineStyleOrder',AxesLineStyleOrder);
    
else
    set(0,'DefaultLineLineWidth','remove');
    set(0, 'DefaultLineMarkerSize','remove');  
    set(0, 'DefaultAxesFontSize','remove');
    set(0, 'DefaultTextFontSize','remove');
    set(figHandle,'DefaultAxesLineStyleOrder','remove');
end

h = figHandle;

end

