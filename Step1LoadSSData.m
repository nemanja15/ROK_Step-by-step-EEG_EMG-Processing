
function SavedData = Step1LoadSSData(DataDirectory, TrialNumbers)
    OriginalDirectory = cd;
    % Go to Directory that contains data
    cd(DataDirectory);
    % Load the SS data 
    cd(['SS']);
    pathname = cd;
    % List all files in the current folder, in the order of their time stamp
    S = dir(cd); S = S(~[S.isdir]);
    [~,idx] = sort([S.datenum]); S = S(idx);
    SavedData = {};
        % Go through the files list one by one
        for trial=1:length(TrialNumbers)
            % Read the Data and sampling frequency (fs) from the .otb file.
            Data=[];
            filename = S(TrialNumbers(trial)).name;
            [Data, fs] = loadOTB2(filename, pathname);
            % The SyncStation data should have a sampling frequency of 2000
            % Hz. If not there is an error.
            if fs~= 2000
            Error=1
            end
            % We only care about the auxilary inputs since SD card recording
            % is in place. First 128 channels are 0.
            AuxInputs = Data(141:143,:);
            SavedData{1,trial} = single(AuxInputs);
        end
        cd ..;
    
    cd(OriginalDirectory);
end