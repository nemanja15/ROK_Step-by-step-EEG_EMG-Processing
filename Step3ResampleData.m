function ResampledData = Step3ResampleData(Input, fs_common, All_fs)

% 1st element of output: EEG  is not resampled
ResampledData = {};
ResampledData(1,:) = Input(1,:);

% 2nd and 3rd elements of output
% HD-EMG and SyncStation are resampled by downsample of 4. so the formula
% calculates p = 1 and q = 4.
for t=2:3
    for r=1:length(Input)
        DataNow = Input{t,r};
        Ratio = All_fs(t)/fs_common;
        if mod(Ratio,1)==0
            p = 1; q = Ratio;
        end
        n_chans=size(DataNow,1); ResampledNow = [];
        for c=1:n_chans
            ResampledNow(c,:) = resample(double(DataNow(c,:)), p, q);
        end
        ResampledData{t,r} = ResampledNow;
    end
end

% 4th element of output:
% Delsys resampling. The resampling factors are different for each of 
% EMG (p1, q1) and gonio (p2, q2)
% Resample each sensor signal with the appropriate p and q
Factor = 10^3;
for r=1:length(Input)  
    All_Delsys_fs = Input{4,r}{3};
    for f=1:length(All_Delsys_fs)
        fs_now = All_Delsys_fs(f);
        Ratio = fs_now/fs_common;
        if Ratio > 1
            if mod(Ratio,1)~=0
                p1 = Factor; q1 = round(Ratio*Factor);
            end
        else
            InvRatio = 1/Ratio;
            p2 = round(InvRatio*Factor); q2 = Factor;
        end
    end 
    DataNow = Input{4,r}{1}; ResampledNow = []; SensorsNow = Input{4,r}{2};
    EMGIdx = find(contains(SensorsNow, 'EMG'));
    for c=1:length(EMGIdx)
        ResampledNow(:,EMGIdx(c)) = resample(double(DataNow(:,EMGIdx(c))), p1, q1);
    end
    GoniIdx = find(contains(SensorsNow, 'Goni'));
    if ~isempty(GoniIdx)
        Clipped = ClipVectorFromEnd(DataNow(:,GoniIdx(1)));
        DataNowG = DataNow(1:length(Clipped), GoniIdx);
        ResampledNowG= [];
        for c=1:length(GoniIdx)
            ResampledNowG(:,c) = resample(double(DataNowG(:,c)), p2, q2);
        end

        if length(ResampledNowG) ~= length(ResampledNow)
            Ratio = length(ResampledNowG)/length(ResampledNow);
            if Ratio > 1
                if mod(Ratio,1)~=0
                    p = Factor; q = round(Ratio*Factor);
                end
            else
                InvRatio = 1/Ratio;
                p = round(InvRatio*Factor); q = Factor;
            end
            ResampledNowG1=[];
            for c=1:length(GoniIdx)
                ResampledNowG1(:,c) = resample(double(ResampledNowG(:,c)), p, q);
            end
            if length(ResampledNowG1) ~= length(ResampledNow)
                if length(ResampledNowG1) > length(ResampledNow)
                    ResampledNow(:,GoniIdx) = ResampledNowG1(1:length(ResampledNow),:);
                else
                    ResampledNow(1:length(ResampledNowG1),GoniIdx) = ResampledNowG1;
                end
            
            end
%             
        end
    end
    ResampledData{4,r}{1} = ResampledNow; ResampledData{4,r}{2} = SensorsNow;
end

end