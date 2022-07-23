function HMAllClassesReduced_SubPlots(AllClassesR, ChosenLocs, sub_row, n_rows, MinMaxH)
n_classes = 4;
hold on;
subplot = @(m,n,p) subtightplot (m, n, p, [0.02 0.02], [0.02 0.1], [0.02 0.1]);
for c = 1:n_classes
    subplot(n_rows, n_classes, ((sub_row-1)*(n_classes)+c));
    TopoPlotR(abs(AllClassesR(:,c)), ChosenLocs, MinMaxH);
end
end