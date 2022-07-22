function Output = ComputeRMSofRegions(Input, RegionIdxs)
Output = [];
for r=1:4
    if r>1
        Region = Input(RegionIdxs(:,r),:);
    else
        Region = Input(RegionIdxs(1:20,r),:);
    end
    RMS = squeeze(rms((Region),1));
    Output(r,:) = RMS;
end