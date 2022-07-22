function TriggerTimes = MakeSubjectAndTaskSpecificCorrection(subject, r, TriggerTimes)
switch subject
    case 13
        switch r
            case 3
                % Nothing can be done
                TriggerTimes = TriggerTimes;
            case 6
                % change start trigger to 2nd peak
                % leave end trigger alone
                TriggerTimes(r,1) = 7.8305;
                TriggerTimes(r,2) = TriggerTimes(r,2);
        end
    case 14
        switch r
            case 8
                % change start trigger to 3rd peak
                % leave end trigger alone
                TriggerTimes(r,1) = 23.845;
                TriggerTimes(r,2) = TriggerTimes(r,2);
            case 12
                % change start trigger to 3rd peak
                % leave end trigger alone
                TriggerTimes(r,1) = 15.2075;
                TriggerTimes(r,2) = TriggerTimes(r,2);
        end
end

end