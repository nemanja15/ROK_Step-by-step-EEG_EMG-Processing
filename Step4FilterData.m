function FilteredData = Step4FilterData(Input, BandOfInterest, fs)
fcH = BandOfInterest(1);
FCH = fcH/(fs/2);
[num1, den1] = butter(5, FCH, 'high');
fcL = BandOfInterest(2);
FCL = fcL/(fs/2);
[num2, den2] = butter(5, FCL, 'low');
FilteredData = {};
for r=1:length(Input)
    % 1 and 2: Filter EEG and HD-EMG
    for t=1:2
        Signals = (Input{t,r}); n_chans = size(Signals,1);
        Filtered = [];
        for c=1:n_chans
            % HPF
            Filtered1 = filtfilt(num1, den1, double(Signals(c, :)));
            % LPF
            Filtered(c,:) = filtfilt(num2, den2, Filtered1);
        end
        FilteredData{t,r} = Filtered;
    end
    t=3;
%    3. Do not filter the force for now. Will filter as part of epoching.
    FilteredData{t,r} = Input{t,r};
    % 4. Filter Delsys
    t=4;
    Signals = Input{t,r}{1}'; n_chans = size(Signals,1);
    Filtered = [];
    for c=1:n_chans
        % HPF
        Filtered1 = filtfilt(num1, den1, double(Signals(c, :)));
        % LPF
        Filtered(c,:) = filtfilt(num2, den2, Filtered1);
    end
    FilteredData{t,r}{1} = Filtered;
    FilteredData{t,r}{2} = Input{t,r}{2};
end
end