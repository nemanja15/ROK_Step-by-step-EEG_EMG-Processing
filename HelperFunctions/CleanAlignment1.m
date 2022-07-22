function AlignmentPoints = CleanAlignment1(AlignmentPointsAll)

for k=1:length(AlignmentPointsAll)
    AlignmentPoints = [];
    for t=1:3
        AlignmentPoints(t) = AlignmentPointsAll{t}(k);
    end
    
    if (AlignmentPoints(3) > AlignmentPoints(2)) && (AlignmentPoints(3) > AlignmentPoints(1))
        error_flag1=0; 
        break
    else
        error_flag1=1;
        continue
    end
end
if error_flag1==1
    AlignmentPointsAll{3}(1) = [];
    for k=1:length(AlignmentPointsAll)-1
        AlignmentPoints = [];
        for t=1:3
            AlignmentPoints(t) = AlignmentPointsAll{t}(k);
        end
        if (AlignmentPoints(3) > AlignmentPoints(2)) && (AlignmentPoints(3) > AlignmentPoints(1))
            error_flag1=0; 
            break
        else
            error_flag1=1;
            continue
        end
    end
end

error_flag2=0;

if ((AlignmentPoints(3) - AlignmentPoints(2)) > 2)  || ((AlignmentPoints(3) - AlignmentPoints(1)) > 2)
        error_flag2=1;
else
end
if error_flag2==1
    AlignmentPoints = [];
    for t=1:3
        AlignmentPoints(t) = AlignmentPointsAll{t}(1);
    end
    if ((AlignmentPoints(3) - AlignmentPoints(2)) > 2)
        AlignmentPoints(2) = AlignmentPointsAll{2}(2);
    end
    if ((AlignmentPoints(3) - AlignmentPoints(1)) > 2)
        AlignmentPoints(1) = AlignmentPointsAll{1}(2);
    end   
end
if ((AlignmentPoints(3) - AlignmentPoints(2)) > 2)  || ((AlignmentPoints(3) - AlignmentPoints(1)) > 2)
        error_flag2=1;
else
        error_flag2=0;
end
if error_flag1==1 || error_flag2==1
    error_flag=1
end