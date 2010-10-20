% Reads a file in binary format, and creates a text file of hex characters.
% Each line has 16*taps bits = 4 or 8 characters.
% Assumes binary files have 16 bit values, where least significant byte
% appears first.
% Also assumes file has blocks of nValues (width*height) = (width*height) * 16 bits

clear all;

avi_folder = 'D:/AVIs';

nValues = 128*60;
taps = 1;

%inFile = 'D:/AVIs/test/strutting12.dat';
%outFile = 'D:/AVIs/test/strutting12.hex';

inFile = [avi_folder '/test/testpattern_19k.dat'];
outFile = [avi_folder '/test/testpattern_19k.hex'];

%inFile = [avi_folder '/ham_oct08/block_raw30-1.4-7.dat'];
%outFile = [avi_folder '/ham_oct08/block_raw30-1.4-7.hex'];

%inFile = [avi_folder '/ham_oct08/block_raw30-0.2-7.4.dat'];
%outFile = [avi_folder '/ham_oct08/block_raw30-0.2-7.4.hex'];

inFile = 'D:/AVIs/I2MTC_final/Co250_Jan21_overnight/40_8_3_3_249/0_0_0.dat';
outFile = 'D:/sync/PhD/Documents/Journal/40_8_3_3_249.hex';



fid = fopen(inFile, 'r');
fid_out = fopen(outFile, 'w');

fpoutput=3;
cycles_to_ignore = 2;
ignoreFrames = cycles_to_ignore*fpoutput;
cycles_to_proc = 20;
nFrames = (cycles_to_proc+cycles_to_ignore)*fpoutput;


for frame = 1:nFrames-1
    
    
    
    if feof(fid) == 1
        break
    end

    c = fread(fid, nValues, 'uint16');
    if(length(c) ~= nValues)
        break;
    end
    if frame > ignoreFrames-1
    fprintf('Frame: %d\n', frame);
    %frame = frame + 1;
    
    if taps == 2
        for i = 1:2:nValues
    
            fprintf(fid_out, fixed2hex(c(i), 16, 0));
            fprintf(fid_out, fixed2hex(c(i+1), 16, 0));
            fprintf(fid_out, '\n');
        end
    else
        for i = 1:nValues
            fprintf(fid_out, fixed2hex(c(i), 16, 0));
            fprintf(fid_out, '\n');
        end
    end
    end
end

fclose(fid_out);
fclose(fid);




