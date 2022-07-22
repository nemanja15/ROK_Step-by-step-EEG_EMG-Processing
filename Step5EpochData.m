function EpochedData = Step5EpochData(Input, ForceTaskIdx, OtherTaskIdx, fs_common)



% 1. Use force signal to epoch isometric tasks
% Filter the force signal in best range ([0.05, 2.5] Hz) for finding task limits
fc = 2.5; order = 4; [b,a] = butter(order,fc/(fs_common/2), 'low');
fc = 0.05; order = 2; [b0,a0] = butter(order,fc/(fs_common/2), 'high');
Thresh=0.125; 

for task = ForceTaskIdx
    % Process the force signal
    AllDataNow = Input(:, task);
    ForceNow = AllDataNow{3}(3,:);
    ForceNow = filtfilt(b0,a0,-double(ForceNow));
    ForceNow = filtfilt(b,a,ForceNow);
    ForceNow = ForceNow-mean(ForceNow);
    ForceNow = ForceNow-min(ForceNow); ForceNow=ForceNow/max(ForceNow);
    Time = (1/fs_common)*(1:length(ForceNow));
    figure('units','normalized','outerposition',[0 0 1 1]);
    Baseline = ForceNow(1);
    ForceNow=ForceNow-Baseline;
    % The force signal has been processed. Use it to find the Peaks.
    Input{3,task}(3,:) = ForceNow;
    plot(Time, ForceNow, 'Linewidth', 2)
    [PeaksL, LocsL] = findpeaks(ForceNow, 'MinPeakHeight', 0.4*max(ForceNow), 'MinPeakDistance', 8*fs_common, 'NPeaks',18);
    hold on;
    plot(Time(LocsL), PeaksL, 'x', 'Linewidth',2);
    StartTimes = [];
    set(gca, 'Fontsize',20);
    xlabel('Time (s)');
    ylabel('Force');
    % Use the Peaks to find the epoch times (StartTimes: time when force 
    % passed the threshold
    for L=1:length(PeaksL)
        PeakLocNow = LocsL(L);
        for t=PeakLocNow:-1:0
            if (ForceNow(t)-mean(ForceNow))<Thresh*(PeaksL(L)-mean(ForceNow))
                StartTimes(L) = t;
                break;
            end
        end
    end
    plot(Time(StartTimes), ForceNow(StartTimes), 'o', 'Linewidth',2);
    legend('Force Trace', 'Peak Force', 'Movement Onset');
    text(Time(5000), 0.9*max(ForceNow), [num2str(length(PeaksL)) ' Trials'], 'Fontsize', 24, 'HorizontalAlignment', 'center'); 
    % The epoch times have been found. Epoch each signal using the times.
    for t=1:3
        NotEpochedDataNow = Input{t,task};
        EpochedDataNow = [];
        for epoch=1:length(StartTimes)
            Idx0 = StartTimes(epoch); 
            Idx1a = Idx0-(fs_common*3)+1;
            Idx1 = max([1 Idx1a]);
            Idx2a = Idx0+(fs_common*4); 
            Idx2 = min([length(NotEpochedDataNow) Idx2a]);
            EpochIdx = Idx1:Idx2;
            EpochedDataNow(:, 1:length(EpochIdx), epoch) = NotEpochedDataNow(:, EpochIdx);
        end
        EpochedData{t, task} = EpochedDataNow;
    end
    t=4;
    NotEpochedDataNow = Input{t,task}{1};
    EpochedDataNow = [];
    for epoch=1:length(StartTimes)
        Idx0 = StartTimes(epoch); 
        Idx1a = Idx0-(fs_common*3)+1;
        Idx1 = max([1 Idx1a]);
        Idx2a = Idx0+(fs_common*4); 
        Idx2 = min([length(NotEpochedDataNow) Idx2a]);
        EpochIdx = Idx1:Idx2;
        EpochedDataNow(:, 1:length(EpochIdx), epoch) = NotEpochedDataNow(:, EpochIdx);
    end
    EpochedData{t, task}{1} = EpochedDataNow;
    EpochedData{t, task}{2} = Input{t,task}{2};
end

% 2. Use goniometer signal to epoch cycling and other tasks
fc = 0.05; order = 2; [b0,a0] = butter(order,fc/(fs_common/2), 'high');
for task = OtherTaskIdx
    AllDataNow = Input(:, task);
    SensorsNow = AllDataNow{4}{2};
    GoniIdx = find(contains(SensorsNow, 'Goni'));
    GoniNow = AllDataNow{4}{1}(GoniIdx,:);
    GoniNow = filtfilt(b0,a0,double(GoniNow'));
    Time = (1/fs_common)*(1:length(GoniNow));
    figure('units','normalized','outerposition',[0 0 1 1]);
    subplot(2,1,1)
    plot(Time, GoniNow(:,[1 2]), 'Linewidth', 2);
    hold on;
    [PeaksL, LocsL] = findpeaks(GoniNow(:,2), 'MinPeakHeight', 0.4*max(GoniNow(:,2)), 'MinPeakDistance', 1*fs_common, 'NPeaks',60);
    plot(Time(LocsL), PeaksL, 'x', 'Linewidth',2);
    title('Goni L');
    set(gca, 'Fontsize',20); xlabel('Time (s)'); ylabel('Angle');
    subplot(2,1,2)
    plot(Time, GoniNow(:,[3 4]), 'Linewidth', 2);
    hold on;
    [PeaksR, LocsR] = findpeaks(GoniNow(:,4), 'MinPeakHeight', 0.4*max(GoniNow(:,4)), 'MinPeakDistance', 1*fs_common, 'NPeaks',60);
    plot(Time(LocsR), PeaksR, 'x', 'Linewidth',2);
    title('Goni R');
    set(gca, 'Fontsize',20); xlabel('Time (s)'); ylabel('Angle');
    % use right goniometer, 2nd axis (red signal on bottom) for epoching
    EpochTimes=LocsR;
    % Epoch OTB signals
    for t=1:3
        NotEpochedDataNow = Input{t,task};
        EpochedDataNow = {};
        for epoch=1:length(EpochTimes)-1
            Idx1 = EpochTimes(epoch); Idx2 = EpochTimes(epoch+1)-1; 
            EpochIdx = Idx1:Idx2;
            EpochedDataNow{epoch,1} = NotEpochedDataNow(:, EpochIdx);
        end
        EpochedData{t, task} = EpochedDataNow;
    end
    % Epoch Delsys signals
    t=4;
    NotEpochedDataNow = Input{t,task}{1};
        EpochedDataNow = {};
        for epoch=1:length(EpochTimes)-1
            Idx1 = EpochTimes(epoch); Idx2 = EpochTimes(epoch+1)-1; 
            EpochIdx = Idx1:Idx2;
            EpochedDataNow{epoch,1} = NotEpochedDataNow(:, EpochIdx);
        end
        EpochedData{t,task}{1} = EpochedDataNow;
        EpochedData{t,task}{2} = Input{t,task}{2};
end

end