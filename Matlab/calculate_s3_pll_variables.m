% For calculating PLL variables for Stratix III Kit.
% Assume (force it to be) that f1 > f2.
% All divisions round down.

f1 = 40;
f2 = 33.4;
inclk = 50;
fpb1 = 5;
fpb2 = 2.5;

% Start by assuming m1 = 24 (VCO1 = 1200 MHz)
m1 = 24;
VCO1 = m1*inclk;
c1 = floor(VCO1/f1);

% Now find VCO2 such that count2 = n.count1 and 600 < VCO2 < 1200
% Recall, VC02 = f2 * count2
VCO2 = 0;
c2 = 0;
while VCO2 <= 600
    c2 = c2 + c1;
    VCO2 = c2 * f2;
end



% Now m2 = VCO2 / inclk;
m2 = floor(VCO2 / inclk);
VCO2 = inclk * m2;

f1_actual = VCO1/c1;
f2_actual = VCO2/c2;

fprintf('m1: %d\tc1: %d\tVCO1: %d\nm2: %d\tc2: %d\tVCO2: %d\n',m1, c1, VCO1, m2, c2, VCO2);
fprintf('f1 actual: %3.3f\tf2 actual: %3.3f\n', f1_actual, f2_actual);

% Calculate phase steps and phase scales

phase_step_1 = c1/fpb1*8;
phase_step_2 = c2/fpb2*8;
phase_scale_1 = floor(2^16/c1);
phase_scale_2 = floor(2^16/c2);
fprintf('steps/cycle1: %d\tsteps/cycle2: %d\n', c1*8, c2*8);
fprintf('step1: %d\tscale1: %d\nstep2: %d\tscale2: %d\n', phase_step_1, phase_scale_1, phase_step_2, phase_scale_2);

if c2 > 255
    fprintf('Frequency combination not possible. c2 too large');
end