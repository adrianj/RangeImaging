% Reads the output from the nios2-console application and extracts the data
% frames.
% Data frames are known by markers before them.
% Start Marker = '*RANGER*'
% Writes 160 * 120 * 4 bytes after start marker.
% No attempt is made to check the correct size of the data frames.

inFile = 'D:\sync\PhD\pmd_nios_output.txt';
outFile = 'D:\sync\PhD\pmd_nios_output.dat';

writing = 0;
n_frames = 0;
start = '12345678';
start_seq = '*RANGER*';

rows = 120;
columns = 160;
bpf = rows*columns*4;   % Bytes per frame.
b_count = 1;

fid = fopen(inFile, 'r');
outfid = fopen(outFile, 'w');

while(1)
    
    if feof(fid) == 1
        break
    end

    c = fread(fid, 1, 'uint8');
    if(writing == 1)
        fwrite(outfid, c, 'uint8');
    end
    b_count = b_count + 1;
    
    start = [start(2:end) c];
    if(strcmp(start, start_seq))
        writing = 1;
        b_count = 0;
    end
    if(b_count == bpf)
        writing = 0;
        n_frames = n_frames + 1;
        fprintf('Frame: %d\n', n_frames);
    end
    
    

    
    
end

fprintf('\n');
fclose(fid);
fclose(outfid);





