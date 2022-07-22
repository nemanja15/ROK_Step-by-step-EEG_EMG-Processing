function [SyncedData, AlignmentPoints] = Step2SynchronizeOTBData(SDCardData, SSData)
%%
% SyncedData will contain synced versions of SD card signals and the force signal 
SyncedData = {};
fs_EEG = 500; fs_HD_EMG = 2000;
All_fs = [fs_EEG fs_HD_EMG];
CommLatency = 33*(10^-3);
StartIdx = 1*fs_EEG;
% 
NIsoTasks = 8; NCycTasks = 5;
EndIdxs = [60*fs_EEG*ones(NIsoTasks, 1); 60*fs_EEG*ones(NCycTasks, 1)];
k=1;
AlignmentPointsAll = [];
for r=1:length(SSData)
    % Put the 3 pulse signals in a cell call Pulses.
    % Resample the HD-EMG and SS signals to 500 Hz (fs of EEG)
    Pulses = {};
    i=1; 
    Pulses{i} = SDCardData{i,r}(66,:);
    i=2; Pulse2 = SDCardData{i,r}(66,:); 
    Pulses{i} = resample(double(Pulse2),1, 4);
    i=3; Pulse3 = SSData{1,r}(2,:);
    Pulses{i} = resample(double(Pulse3),1, 4);
    figure('units','normalized','outerposition',[0 0 0.5 1]);
    FirstPeakIdxs = [];
    tt = ["sd1","sd2","ss"];
    MissingPulses = []; m=1;
    for i=1:3
         Time = (1/fs_EEG)*(1:length(Pulses{i}(1:EndIdxs(r))));
         hold on;
         % Plot the ith pulse signal vs time
         plot(Time, Pulses{i}(1:EndIdxs(r)),'DisplayName', tt(i));
         legend();
         % Calculate the diff
         Diff = abs(diff(Pulses{i}));
         % Find the peak pulse changes using findpeaks on Diff
         [pks, idxs] = findpeaks(Diff(1:EndIdxs(r)), 'MinPeakHeight', 0.5*max(Diff(1:EndIdxs(r))), 'MinPeakDistance', 3*fs_EEG, 'NPeaks',20);
         idxs = sort(idxs, 'ascend');
         idxs(idxs<StartIdx) = [];
        % Plot the peak locations as *s
        plot(Time(idxs), Pulses{i}(idxs), '*');
        if length(idxs)<4
            MissingPulses(m) = i;
            m=m+1;
            continue
        end
        % The pulse time for aligning will be the first peak
        AlignmentPointsAll(i,:) = (1/fs_EEG)*idxs(1:8);   
    end
    if length(MissingPulses)==1
        AlignmentPointsAll(MissingPulses,:) = BorrowPulses(Pulses, MissingPulses, StartIdx, EndIdxs(r),  tt);
    end
        
    AlignmentPoints(:,r) = CleanAlignment2(AlignmentPointsAll);
    % Shift the ith SD card signal by the correct amount, such that the SD 
    % card signal is aligned with the SS signal.
    for i=1:2
        % Find the difference between ith SD card and SyncStation pulses
        Difference = AlignmentPoints(3,r)-AlignmentPoints(i,r);
        % NShift is the number of samples by which to shift (account for
        % the 33 ms delay)
        NShift = floor(Difference*All_fs(i)-CommLatency);
        OldData = SDCardData{i,r};
        NewData = [];
        NewData(1:size(OldData,1),1:NShift) = 0;
        NewData(:,NShift+1:NShift+length(OldData)) = OldData;
        SyncedData{i,r} = single(NewData);
    end
    % The SS signals do not need to be shifted.
    SyncedData{3,r} = single(SSData{1,r});   
end

end