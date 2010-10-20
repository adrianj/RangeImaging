% Reads a file in hexadecimal text format, and creates a binary file.
% Each input line has 32 bits = 8 characters.
% Outputs binary files of 16 bit values, where least significant byte
% appears first.
% Assumes file has blocks of 72 kB (1 frame) = 8192 lines 9 chars each

clear all;

avi_folder = 'D:/AVIs';

taps = 2;
nLines = 160*120;

%inFile = [avi_folder '/test/strutting4_rng.hex'];
%outFile = [avi_folder '/test/strutting4_rng.dat'];

inFile = [avi_folder '/test/rangerRiviera.hex'];
outFile = [avi_folder '/test/rangerRiviera.dat'];

%inFile = [avi_folder '/test/testpattern_19k.hex'];
%outFile = [avi_folder '/test/testpattern_19k.dat'];


fid = fopen(inFile, 'r');
fid_out = fopen(outFile, 'w');

frame = 1;
nFrames = 20;

if taps == 1
    new_frame = zeros(nLines, 1);
else
    new_frame = zeros(nLines*2, 1);
end
fprintf('\n');

for n = 1:nFrames
    
    
    
    if feof(fid) == 1
        break
    end

    [c,count] = fscanf(fid, '%s', nLines);
    if(count ~= nLines)
        break;
    end
    fprintf('Frame: %d\n', frame);
    
    frame = frame + 1;
    if taps == 2
        for i = 1:nLines*2
           new_frame(i) = cast(hex2fixed(c(i*4-3:i*4),16,0) ,'int16'); 
        end
        fwrite(fid_out, new_frame, 'int16');
    else
        for i = 1:nLines
           new_frame(i) = cast(hex2fixed(c(i*4-3:i*4),16,0) ,'int16'); 
        end
        fwrite(fid_out, new_frame, 'int16');
    end
    

end

figure; imagesc(new_frame);

fclose(fid_out);
fclose(fid);




