function AlignmentPoints = CleanAlignment2(AlignmentPointsAll)
AlignmentPointsAllT = AlignmentPointsAll';
AlignmentPointsAll2 = AlignmentPointsAllT(:);
[sorted, idx] = sort(AlignmentPointsAll2, 'ascend');
DiffS = diff(sorted);
Thresh = 1.3;
for i=1:length(DiffS)-1
    if (DiffS(i) < Thresh) && (DiffS(i+1) < Thresh)
        Idx = i;
        break
    end
end
IdxsOI = idx(Idx:Idx+2); 
n_points = size(AlignmentPointsAll,2);
PulseIdx = floor(IdxsOI/n_points)+1;
AlignmentPoints = [];
for i=1:3
    AlignmentPoints(PulseIdx(i)) = AlignmentPointsAll2(IdxsOI(i));
end
end

