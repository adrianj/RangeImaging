%function [ width, height, pixels ] = extract_avi( avi_filename )
% avi_filename is the name of the movie file, minus its .avi extenension.
% It is assumed that the .set file has the same name, and is in the same
% location.
% width is the number of pixels wide.
% height is the number of pixels high
% Writes a .dat file of the video as 16 bit pixels, with 2 taps.
% Tap 1 represents the left of image, tap 2 the right, although in .dat
% file data is interspersed as 'tap1(1) tap2(1) tap1(2) tap2(2) ...'

clear all;
avi_folder = 'D:\AVIs';
avi_filename = [avi_folder '\AdrianD\adrian-01'];
%avi_filename = [avi_folder '\Realtimes\strutting13-045-20-dnl-01'];
out_filename = [avi_folder '\AdrianD\adrian.dat'];

% Number of frames to extract.
N = 330;
binning = 1;
width = 512;
flip_vertical = 1;

fi = aviinfo([avi_filename '.avi']);
sss = loadsetparms([avi_filename '.Set']);

fps = sss.actual_frame_rate;
frames_per_beat = fps / 29;

width = fi.Width;
height = fi.Height;
nFrames = min(fi.NumFrames, N);

outFile = fopen(out_filename, 'w');

for n = 1:nFrames
    
    test = aviread([avi_filename '.avi'], n);

    frame = test.cdata;
    frame = frame(1:binning:end, 1:binning:end);
    
    % Interleave the taps
    new_frame = zeros(height/binning, width/binning);
    
    
    for j = 1:(width/2)/binning
        new_frame(:,j*2-1) = frame(:,j);
        new_frame(:,j*2) = frame(:,j+width/2/binning);
    end


    %figure; image(new_frame);

    fwrite(outFile, new_frame', 'int16');
    fprintf('Frame: %d\n', n);
end

outFile = fclose(outFile);
