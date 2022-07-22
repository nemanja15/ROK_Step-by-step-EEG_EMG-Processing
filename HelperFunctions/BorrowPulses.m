function AlignmentPointsNow = BorrowPulses(Pulses, MissingPulseIdx, StartIdx, EndIdx, tt)
if MissingPulseIdx == 1
    WorkingPulseIdx = 2;
else
    WorkingPulseIdx = 1;
end
fs_EEG = 500;
PulseW = Pulses{WorkingPulseIdx};
PulseM = Pulses{MissingPulseIdx};
Adjusted = [];
mu = [0.425];
sigma = [0.01];
Lat = repmat(mu,1) + randn(1,1)*sigma
Fits =length(PulseM)-floor(fs_EEG*Lat); 
Adjusted = PulseW(floor(fs_EEG*Lat)+1:end);
Length = length(Adjusted);
Length2 = length(PulseM)-Length;
Adjusted(Length+1:length(PulseM)) = zeros(Length2,1);
% Time1 = (1/fs_EEG)*(1:length(PulseW));
% Time2 = (1/fs_EEG)*(1:length(Adjusted));
% figure('units','normalized','outerposition',[0 0 0.5 1]);
% plot(Time2,Adjusted); hold on;
% plot(Time1,PulseW);
Pulses{MissingPulseIdx} = Adjusted;

i = MissingPulseIdx;
Time = (1/fs_EEG)*(1:length(Pulses{i}(1:EndIdx)));
hold on;
plot(Time, Pulses{i}(1:EndIdx),'DisplayName', tt(i));
legend();
Diff = abs(diff(Pulses{i}));
[pks, idxs] = findpeaks(Diff(1:EndIdx), 'MinPeakHeight', 0.5*max(Diff(1:EndIdx)), 'MinPeakDistance', 3*fs_EEG, 'NPeaks',20);
idxs = sort(idxs, 'ascend');
idxs(idxs<StartIdx) = [];
plot(Time(idxs), Pulses{i}(idxs), '*');
AlignmentPointsNow = (1/fs_EEG)*idxs(1:8);       
end