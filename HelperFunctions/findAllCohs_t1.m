function AllCohsOut = findAllCohs_t1(C1, C2, window_length, fs, ForceTaskClass)
ForceTaskDurations = [0.5 1 2 3];
ForceTaskDurationClass = mod(ForceTaskClass,4);
if ForceTaskDurationClass == 0
    ForceTaskDurationClass = 4;
end
ForceTaskDuration = ForceTaskDurations(ForceTaskDurationClass);
noverlap = [];
AllCohsOut = {};
Modes = {'Minus_t'; 'Plus_t';};
n_modes = length(Modes);
switch ForceTaskDuration
    case 3
        % Slow
        t = 3;
        n_fft = 512;
    case 2
        % Medium
        t=2;
        n_fft = 512;
    case 1 
        % Fast
        t=1;
        n_fft = 256;
    case 0.5
        % Ballistic
        t = 0.5;
        n_fft = 128;
end
T = t*fs;
for m=1:n_modes
    switch m
        case 1
            % -t
            idx1 =  (3*window_length/7)-T+1;
            idx2 =  (3*window_length/7);
        case 2
            % +t
            idx1 = (3*window_length/7)+1;
            idx2 = (3*window_length/7)+T;
    end
[CxyNow] = mscohere(C1(idx1:idx2), C2(idx1:idx2), hamming(n_fft), noverlap, n_fft, fs);
AllCohsOut{m} = CxyNow;
end
end