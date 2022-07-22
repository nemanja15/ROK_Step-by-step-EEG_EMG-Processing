function AllCoherences = Step8ComputeCoherence(Input, ConnectivityOptions, ForceTaskIdx, ForceTaskClasses, OtherTaskIdx, IsometricMode, fs)
AllCoherences = {};
for k=1:size(ConnectivityOptions, 1)
    Coherences = {};
    % 1. Force tasks
    for task = ForceTaskIdx
        TaskNow = Input(:,task);
        Modality1a = TaskNow{ConnectivityOptions(k,1)};
        Modality2a = TaskNow{ConnectivityOptions(k,2)};
        Modality1 = []; Modality2 = []; 
        if size(Modality1a, 3) == 1
            n_channels1 = 1;
            n_epochs = size(Modality1, 2);
            Modality1(1, :, :) = Modality1a;
        else
            n_channels1 = size(Modality1a,1);
            n_epochs = size(Modality1a, 3);
            Modality1 = Modality1a;
        end
        if size(Modality2a, 3) == 1
            n_channels2 = 1;
            Modality2(1, :, :) = Modality2a;
        else
            n_channels2 = size(Modality2a,1);
            Modality2 = Modality2a;
        end
        
        for chan1 = 1:n_channels1
            for chan2 = 1:n_channels2
                EpochCoherences = {};
                for epoch = 1:n_epochs
                    EpochNowCh1 = Modality1(chan1, :, epoch);
                    EpochNowCh2 = Modality2(chan2, :, epoch);
                    if length(EpochNowCh2)~=length(EpochNowCh1)
                        LengthMismatch = 1
                        return
                    else
                        window_length = length(EpochNowCh1);
                    end
                    switch IsometricMode
                        case 'PlusMinusT'
                         EpochCoherences(epoch, 1:2) = findAllCohs_t1(EpochNowCh1, EpochNowCh2, window_length, fs, ForceTaskClasses(task));
                            
                    end
                end
                Coherences{ForceTaskClasses(task), chan1, chan2} = EpochCoherences;
            end
        end
    end
    % 2. Other Tasks
    AllCoherences{k} = Coherences;
end
end