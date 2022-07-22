function AlignmentPoints = CleanAlignment(AlignmentPoints10)

for k=1:10
    AlignmentPoints = [];
    for t=1:3
        AlignmentPoints(t) = AlignmentPoints10{t}(k);
    end
    error_flag=0;
    if (AlignmentPoints(3) > AlignmentPoints(2)) && (AlignmentPoints(3) > AlignmentPoints(1))
    else
        error_flag=1;
        continue
    end
    if ((AlignmentPoints(3) - AlignmentPoints(2)) > 2)  && ((AlignmentPoints(3) - AlignmentPoints(1)) > 2)
        error_flag=1;
    else
    end
    if error_flag==0
        break;
    end
end
if error_flag==1
    AlignmentPoints2 = CleanAlignment1(AlignmentPoints10);
end
end