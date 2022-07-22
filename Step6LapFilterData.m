function LapFilteredData = Step6LapFilterData(Input,  ForceTaskIdx, OtherTaskIdx, Locations)
for task = 1:ForceTaskIdx
    EEGNow = Input{1, task};
    n_epochs = size(EEGNow,3);
    for epoch = 1:n_epochs
        LapFilteredNow = LapFilter64(EEGNow(1:64, :, epoch), Locations);
    end
end

end