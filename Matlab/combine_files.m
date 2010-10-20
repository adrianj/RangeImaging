%Combines .dat files into 1 larger file.
% Filename should follow format <name>_n.dat where n increments by 1 each time.
% Output file will be <name>_combined.dat
% can choose to ignore first 'ignoreFrames' number of frames from each file.
% Specify the total number of files to combine.

ignoreFrames = 10;
nFiles = 6;
fileIncrement = 125;
dir = 'D:/AVIs/Objects/';
filename = 'Adrian_10fpb_1';
outFilename = [dir filename '_combined.dat'];
outFile = fopen(outFilename, 'w');
width = 160;
height = 120;
taps = 1;
ppf = width*height*taps;  

% raw_data = [[] [] [] [] [] []];
% tp1 = [146 105];
% tp2 = [30 60];
% tp3 = [111 69];
% tp4 = [67 60];
% tp5 = [87 24];
% tp6 = [65 23];
% 
% tp1 = height*tp1(1)+tp1(2);
% tp2 = height*tp2(1)+tp2(2);
% tp3 = height*tp3(1)+tp3(2);
% tp4 = height*tp4(1)+tp4(2);
% tp5 = height*tp5(1)+tp5(2);
% tp6 = height*tp6(1)+tp6(2);


for i = 0:nFiles-1
    inFilename = sprintf('%s%s_%d.dat',dir,filename,i*fileIncrement);
    inFile = fopen(inFilename, 'r');
    frame = 1;
    while(1)
        if (feof(inFile) == 1)
            break;
        end
        d_raw = fread(inFile, ppf, 'uint16');
        if(length(d_raw) ~= ppf)
            break;
        end   
        % ignore first FSAMP samples of each capture.
        if frame > ignoreFrames
            fwrite(outFile, d_raw, 'uint16'); 
            
            if taps == 2
            tap1 = reshape(d_raw(1:2:end),width,height)';
            tap2 = reshape(d_raw(2:2:end),width,height)';
            d_raw = tap1 - tap2;
            else
            d_raw = reshape(d_raw,width,height)';
            end

            d_raw = cast(d_raw, 'double');
            
        
            %poi = [d_raw(tp1) d_raw(tp2) d_raw(tp3) d_raw(tp4) d_raw(tp5) d_raw(tp6)];
        
            %raw_data = [raw_data ; poi];
        end
        frame = frame + 1;
    end
    
    inFile = fclose(inFile);
end

outFile = fclose(outFile);
%save(filename, 'raw_data');
