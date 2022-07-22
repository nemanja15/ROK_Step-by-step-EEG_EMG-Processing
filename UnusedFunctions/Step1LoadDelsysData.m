
function SavedData = Step1LoadDelsysData(DataDirectory, TrialNumbers)
    OriginalDirectory = cd;
    % Go to Directory that contains data
    cd(DataDirectory);
    % Load the SS data 
    cd(['Delsys']);
    List = dir;
    for trial=1:length(TrialNumbers)
    FileName = FindFileNameLF_13(List,TrialNumbers(trial));
    Tab=readtable(FileName);
    AllData = table2array(Tab);
    Names1 = Tab.Properties.VariableNames;
    Idxs = [];
    k=1;
    NamesNow = {};
    for t=1:length(UsefulVariables)
        Result = find(strcmp(UsefulVariables(t), Names1));
        if ~isempty(Result)
        NamesNow{k} =  UsefulVariables{t};   
        Idxs(k) = Result;
        k=k+1;
        end
    end
    SelData = [];
    for ii=1:length(Idxs)
        SelData(:,ii) = AllData(:,Idxs(ii));
    end
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
    DelsysData{trial,3} = [fsEMG fsG];
end
        cd ..;
    
    cd(OriginalDirectory);
end