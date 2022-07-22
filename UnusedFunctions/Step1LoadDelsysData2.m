
function SavedData = Step1LoadDelsysData2(DataDirectory, TrialNumbers)
    OriginalDirectory = cd;
    % Go to Directory that contains data
    cd(DataDirectory);
    % Load the SS data 
    cd(['Delsys']);
    % List all files in the current folder, in the order of their time stamp
    S = dir(cd); S = S(~[S.isdir]);
    [Name,idx] = sort({S.name}); S = S(idx);

    [~,ind]=sort({xlsFiles.name});
W = xlsFiles(ind);

        % Go through the files list one by one
        for trial=1:length(TrialNumbers)
            % Read the Data and sampling frequency (fs) from the .otb file.
            Data=[];
            [Data, fs] = loadOTB(S(TrialNumbers(trial)).name);
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