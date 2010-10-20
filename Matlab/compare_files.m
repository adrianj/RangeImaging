% Compares two input files and locates differences between them.
% Particularly for .dat files of binary ranger frames, and error frame is
% shown in a graph.

%close all;
%clear all;

%inFile1 = 'D:/AVIs/test/rangerHardware.dat';
inFile1 = 'D:/AVIs/test/rangerRiviera.dat';
inFile2 = 'D:/AVIs/test/rangerMatlab.dat';
%inFile2 = 'D:/AVIs/test/rangerRiviera.dat';
fid1 = fopen(inFile1, 'r');
fid2 = fopen(inFile2, 'r');
errors = 0;
frames = 0;
ppf = 16384;


fprintf('\n');

while(1)
    
    if (feof(fid1) == 1 || feof(fid2) == 1)
        break
    end
    
    c1 = fread(fid1, 16384, 'uint16');
    c2 = fread(fid2, 16384, 'uint16');
    if(length(c1) ~= 16384 || length(c2) ~= 16384)
        break;
    end
    dat1 = c1 * 2*pi/65536;
    dat2 = c2 * 2*pi/65536;

%     for i = 1:ppf
%         if dat1(i) - dat2(i) > 2^13
%             diff(i) = dat1(i) - dat2(i) + 2^14;
%         elseif dat1(i) - dat2(i) < -2^13
%             diff(i) = dat1(i) - dat2(i) - 2^14;
%         else
%             diff(i) = dat1(i) - dat2(i);
%         end
%     end
%            
    diff = dat1 - dat2;
    
    error = diff*2*pi/65536;
    frames = frames + 1;
    %if(max(diff) > 10 || min(diff) < -10)
        errors = errors + 1;
        s = sprintf('Matlab Frame %d', frames);
        
        figure; title(s);
        subplot(3,1,1); plot(dat2); title(s);
        subplot(3,1,2); plot(diff); title('error');
        subplot(3,1,3); plot(dat1); title('Raw data from Hardware');
        
        %figure; plot(dat1);
        %figure; plot(dat2);

    %end
    
end

fprintf('Number of frames with errors: %d out of %d\n', errors, frames);


fid1 = fclose(fid1);
fid2 = fclose(fid2);