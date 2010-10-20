% Draw graphs of processed info.
% To refresh: data is in the form (<pixel/16>,<test point>,<frame num>)
clear all;
load dc50;

% First take average of raw data from 16 pixel points (dimension 2)
raw_data_mean = squeeze(mean(raw_data,2));

