
function DelsysData = Step1LoadDelsysData1(DataDirectory, TrialNumbers, UsefulVariables)
    DelsysData = {};
    OriginalDirectory = cd;
    % Go to Directory that contains data
    cd(DataDirectory);
    % Load the SS data 
    cd(['Delsys']);
    List = dir;
    for trial=1:length(TrialNumbers)
        % Find the correct file for the given trial number idx
        FileName = FindFileNameLF_14(List,TrialNumbers(trial));
        % Load the data
        Tab=readtable(FileName);
        AllData = table2array(Tab);
        % Check the column names
        Names1 = Tab.Properties.VariableNames;
        
        % Find the columns which have names matching pre-defined 'useful 
        % variables'. Half of columns have time vectors which we don't need.
        UsefulIdxs = []; k=1; NamesNow = {};
        for t=1:length(UsefulVariables)
            Result = find(strcmp(UsefulVariables(t), Names1));
            if ~isempty(Result)
            NamesNow{k} =  UsefulVariables{t};   
            UsefulIdxs(k) = Result;
            k=k+1;
            end
        end
        % Extract the useful columns (SelData)
        SelData = [];
        for ii=1:length(UsefulIdxs)
            SelData(:,ii) = AllData(:,UsefulIdxs(ii));
        end
        % the DelsysData cell contains useful data and corresponding sensor name
        DelsysData{trial,1} = single(SelData);
        DelsysData{trial,2} = NamesNow;
        % Sampling Frequencies
        fsEMG = round(1/AllData(2,1),4);
        fs2 = round(1/AllData(2,end-13),4);
        if fs2~= fsEMG
            fsG=fs2;
        else
            fsG=[];
        end
        % Save also the EMG and gonio sampling frequencies to the DelsysData cell 
        DelsysData{trial,3} = [fsEMG fsG];
    end
    cd(OriginalDirectory);
    DelsysData = DelsysData';
end