function SyncedDataOut = CheckDelsysAndOTBLengths(SyncedData, All_fs, fs_EMG)
DurMin = 100000;
for t=1:3
OTBDur = length(SyncedData{t,1})/All_fs(t);
    if OTBDur < DurMin
        DurMin = OTBDur;
    end
end
DelsysData = SyncedData{4,1};
DelsysDur = length(DelsysData{1})/fs_EMG;
DurAll = min([DurMin DelsysDur]); 
for t=1:3
    SyncedDataOut{t,1} = SyncedData{t,1}(:,1:floor(DurAll*All_fs(t)));
end
AdjustedDelsys = DelsysData{1}(1:floor(DurAll*fs_EMG),:);
DelsysData{1} = AdjustedDelsys;
SyncedDataOut{4,1} = DelsysData;
end