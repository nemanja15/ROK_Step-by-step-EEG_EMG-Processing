function [SyncedData] = Step2SynchronizeDelsysData(SyncedOTBData, DelsysData, subject)

if length(DelsysData) ~=  length(SyncedOTBData)
    NTasksMismatchError = 1
    return
else
    n_tasks = length(DelsysData);
end
fs_HDEMG=2000; fs_EEG = 500;
All_fs = [fs_EEG fs_HDEMG fs_HDEMG];
TriggerTimes=[]; LengthMismatchFlag=[];
for r=1:n_tasks
    % extract the Delsys trigger input signal 
    TriggerSig = SyncedOTBData{3,r}(1,:);
    TriggerSig = TriggerSig/max(TriggerSig);
    figure('units','normalized','position',[0.25 0.2 0.5 0.5]);
    Time = (1/fs_HDEMG)*(1:length(TriggerSig));
    % plot the on and off Delsys trigger locations as *s
    subplot(2,1,1)
    plot(Time, TriggerSig, 'Linewidth',2);
    hold on;
    Diff = abs(diff(TriggerSig));
    Diff = Diff/max(Diff);
    Time(end) = [];
    plot(Time, Diff, 'Linewidth',2);
    [pks, idxs] = findpeaks(Diff, 'MinPeakHeight', 0.33*max(Diff), 'MinPeakDistance', 1*fs_HDEMG, 'NPeaks',10);
    plot(Time(idxs), TriggerSig(idxs), '*','Linewidth', 1, 'MarkerSize', 14); 
    
    % TriggerTimes contains the on (1) and off (2) trigger times
    TriggerTimes(r,1) = Time(idxs(1)); 
    if length(idxs)>1
    TriggerTimes(r,2) = Time(idxs(end)); 
    end 
    % Plot an EMG sensor (right soleus is useful)
    subplot(2,1,2)
    ClippedSensor1 = ClipVectorFromEnd(DelsysData{1,r}(:,1));
    EMGDataNow = DelsysData{1,r}(1:length(ClippedSensor1),:);
    SensorsNow = DelsysData{2,r};
    SIdx = find(contains(SensorsNow, {'TAL'}));
    fs_EMG = DelsysData{3,r}(1);
    Time = (1/fs_EMG)*(1:length(EMGDataNow));
    plot(Time, EMGDataNow(:,SIdx), 'Linewidth',2);
    EMGDur = Time(end);
    TrigDur = TriggerTimes(r,2)-TriggerTimes(r,1);
    DiffDur = abs(EMGDur-TrigDur)/TrigDur;
    % the time between on and off trigger signals needs to be
    % approx. equal to the length of Delsys sensor signal.
    
    if DiffDur>0.02
        TriggerTimes = MakeSubjectAndTaskSpecificCorrection(subject, r, TriggerTimes); 
        EMGDur = Time(end);
        TrigDur = TriggerTimes(r,2)-TriggerTimes(r,1);
        DiffDur = abs(EMGDur-TrigDur)/TrigDur;
        if DiffDur>0.02
            LengthMismatchFlag(r)=1;
        end
    end
    for t1=1:3
    TimeIdxs = floor(TriggerTimes(r,:)*All_fs(t1));
    OldData = SyncedOTBData{t1,r};
    if TimeIdxs(2) > length(OldData)
        T2Min = 10000;
        for t2=1:3
            OldData = SyncedOTBData{t2,r};
            T2N = (length(OldData)/All_fs(t2));
            if T2N<T2Min
                T2Min = T2N;
            end
        end
        TriggerTimes(r,2) = T2Min;
        
    end
        OldData = SyncedOTBData{t1,r};
        TimeIdxs = floor(TriggerTimes(r,:)*All_fs(t1));
        SyncedData{t1,r} = OldData(:,TimeIdxs(1):TimeIdxs(2));
    end   
    SyncedData{4,r} = DelsysData(:,r);
    SyncedData(1:4,r) = CheckDelsysAndOTBLengths(SyncedData(:,r), All_fs, fs_EMG);
end
end
