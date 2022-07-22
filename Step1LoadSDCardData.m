
function SavedData = Step1LoadSDCardData(DataDirectory, TrialNumbers)
    OriginalDirectory = cd;
    % Go to Directory that contains data
    cd(DataDirectory);
    SavedData={};
    % Load the SD card data one by one
    for i=1:2
        % Go to the ith SD card
        cd(['SD ' num2str(i)]);
        % List all files in the current folder, in the order of their time stamp
        S = dir(cd); S = S(~[S.isdir]);
        [~,idx] = sort([S.datenum]); S = S(idx);
        % Go through the files one by one
        for trial=1:length(TrialNumbers)
            % Read the Data and sampling frequency (fs) from the .bio file.
            Data=[];
            [Data, fs] = Open_BIO_File_OTB1(S(TrialNumbers(trial)).name);
            % Before we had BrainVision, SD card 1 was always in EEG mode, 
            % so fs = 500 and SD card 2 had a sampling frequency of 2000 Hz (EMG
            % mode). If not those sampling frequencies, there is an error
            if i==1 && fs~= 500
                Error=1
            elseif (i==2) && fs~= 2000
                Error=1
            end
            % Save the data as single to save space
            SavedData{i,trial} = single(Data);
        end
        cd ..;
    end
    cd(OriginalDirectory);
end