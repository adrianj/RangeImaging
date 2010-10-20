% function countDown(seconds)
% Sets a countdown in minutes, displaying the time remaining as it goes.
% Automatically chooses to show remaining minutes or seconds depending on
% input: minutes for > 600 seconds, else seconds.
% NB - locks up MATLAB, kill with CTRL-C.

function countDown(seconds)

fprintf('Begin Countdown. CTRL-C to kill\n');
t = clock;
fprintf('Current time: %d:%d\n', t(4), t(5));

fprintf('Time Remaining: ');

for i = seconds:-1:1
    if seconds > 600 % display minutes.
        c = fprintf('%d min', ceil(i/60));
    else
        c = fprintf('%d s', i);
    end
    pause(1);
    for k = 1:c
        fprintf('\b');
    end
end
fprintf('0\nCountdown Complete!\n');
fprintf('Current time: %d:%d\n\n', t(4), t(5));