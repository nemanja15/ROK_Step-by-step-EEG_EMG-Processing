function PreparedData = Step7PrepareForConnectivity(Input, ForceTaskIdx, OtherTaskIdx, ModalitiesIdx, EEGChannelIdx, HDEMGChannelReductionMethod, RegionIdxs)
PreparedData={};
% if EEG is chosen (1), we need to add it while selecting appropriate channels 
if ~isempty(intersect(ModalitiesIdx, 1))
    for task = ForceTaskIdx
        PreparedData{1, task} = Input{1,task}(EEGChannelIdx, :, :);
    end
    for task = OtherTaskIdx
        TaskNow = Input{1,task};
        TaskNowOut = {};
        for epoch = 1:length(TaskNow)
            TaskNowOut{epoch} = TaskNow{epoch}(EEGChannelIdx, :);
        end
        PreparedData{1, task} = TaskNowOut;
    end
end


% If HD-EMG modality (2) is chosen, we probably need to do some channel dimension
% reduction
if ~isempty(intersect(ModalitiesIdx, 2))
    for task = ForceTaskIdx
        HDEMGTaskNow = Input{2,task};
        switch HDEMGChannelReductionMethod
            case 'AllToOne'
                Avg = squeeze(median(HDEMGTaskNow(1:64, :, :), 1));
            case 'AllToFour'
                n_epochs = size(HDEMGTaskNow,3); Avg = [];
                for epoch=1:n_epochs
                Avg = ComputeRMSofRegions(HDEMGTaskNow(1:64, :, epoch), RegionIdxs);
                end
        end
        PreparedData{2, task} = Avg;
    end
    for task = OtherTaskIdx
        HDEMGTaskNow = Input{2,task};
        TaskNowOut = {};
        for epoch = 1:length(HDEMGTaskNow)
            EpochNow = HDEMGTaskNow{epoch}(1:64, :);
            switch HDEMGChannelReductionMethod
            case 'AllToOne'
                Avg = median(EpochNow(1:64, :), 1);
            case 'AllToFour'
                Avg = ComputeRMSofRegions(EpochNow(1:64, :), RegionIdxs);
            end
            TaskNowOut{epoch} = Avg;
        end
        PreparedData{2, task} = TaskNowOut;
    end
end



end