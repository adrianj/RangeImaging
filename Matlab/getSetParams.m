% Extracts setting parameters from .set file.
% Expects the full path of the filename, excluding .set extension.
% Output mat file also excludes the .mat extension.
% Returns 1 if successful, -1 if not.
function r = getSetParams(givenFilename, matFile)
%givenFilename = 'D:/AVIs/test/modFreq_vs_DC/60_45_45';
inFilename = [givenFilename '.set'];
inFile = fopen(inFilename,'r');

r = 1;

% Default values - in case set file does not allocate them
fm1 = 40e6;
fm2 = 40e6;
fpb1 = 4;
fpb2 = 4;
integration_time = 0.1;
fps = 0.1;
nFrames = 1000;
mod_ratio = 0;
adc_gain_left = 0;
adc_gain_right = 0;
adc_offset_left = 0;
adc_offset_right = 0;
duty_cycle_camera = 50;
duty_cycle_laser = 50;
phase_step1 = 0;
phase_step2 = 0;
phase_step_init1 = 0;
phase_step_init2 = 0;
fpoutput = 0;
pll_m_count1 = 120;
pll_m_count2 = 120;
pll_c_count1_hi = 15;
pll_c_count1_lo = 15;
pll_c_count2_hi = 15;
pll_c_count2_lo = 15;

if inFile < 0
    r = -1;
else
    
    while(1)
        if (feof(inFile) == 1)
            break;
        end
        s = fgets(inFile);
        [label,value] = strread(s,'%s%f','delimiter',' ');
        if strcmp(label,'MF1') fm1 = value*1000000; end
        if strcmp(label,'MF2') fm2 = value*1000000; end
        if strcmp(label,'FPB1') fpb1 = value; end
        if strcmp(label,'FPB2') fpb2 = value; end
        if strcmp(label,'FPOUTPUT') fpoutput = value; end
        if strcmp(label,'INTTIME') integration_time = value/1000000; end
        if strcmp(label,'FRAMETIME') fps = 1000000/value; end
        if strcmp(label,'NCAPTURES') nFrames = value; end
        if strcmp(label,'MODRATIO') mod_ratio = value; end
        if strcmp(label,'ADCOLEFT') adc_offset_left = value; end
        if strcmp(label,'ADCORIGHT') adc_offset_right = value; end
        if strcmp(label,'ADCGLEFT') adc_gain_left = value; end
        if strcmp(label,'ADCGRIGHT') adc_gain_right = value; end
        if strcmp(label,'DCCAMERA') duty_cycle_camera = value; end
        if strcmp(label,'DCLASER') duty_cycle_laser = value; end
        if strcmp(label,'PHASESTEP1') phase_step1 = value; end
        if strcmp(label,'PHASESTEP2') phase_step2 = value; end
        if strcmp(label,'PHASESTEPINIT1') phase_step_init1 = value; end
        if strcmp(label,'PHASESTEPINIT2') phase_step_init2 = value; end
        if strcmp(label,'PLLMCOUNT1') pll_m_count1 = value; end
        if strcmp(label,'PLLMCOUNT2') pll_m_count2 = value; end
        if strcmp(label,'PLLCOUNT1_HI') pll_c_count1_hi = value; end
        if strcmp(label,'PLLCOUNT1_LO') pll_c_count1_lo = value; end
        if strcmp(label,'PLLCOUNT2_HI') pll_c_count2_hi = value; end
        if strcmp(label,'PLLCOUNT2_LO') pll_c_count2_lo = value; end
    end
    
    inFile = fclose(inFile);
end

if fpoutput == 0 fpoutput = fpb1; end

save(matFile, 'f*','int*','nF*','adc*','duty*','mod*','phase*','pll_*');
