function Step9PlotConnectivity(Input, ElectrodesIn, ChosenElectrodesOut, ChosenLocs, FIdx, fs_common)

HeatColor = 'jet';
n_phases = 2;
ChosenIdx=[];
for e=1:length(ChosenElectrodesOut)
Idx = find(strcmp(ChosenElectrodesOut(e),ElectrodesIn));
ChosenIdx(e) = Idx;
end
ChosenData = Input(:, ChosenIdx);
[n_classes, n_chans] = size(ChosenData); 
AllClasses1 = [];
for Class=1:n_classes
    for chan =1:n_chans
        Now = ChosenData{Class, chan};
        n_epochs = size(Now,1);
        
        for p=1:n_phases
            AllEpochs = [];
            for epoch=1:n_epochs
                Epoch = Now{epoch, p};
                if epoch==1 && p==1
                    FIdx = FindFIdx(Epoch, fs_common);
                end
                AllEpochs(epoch) = median(Epoch(FIdx));
            end
            TrialAvg = median(AllEpochs);
            AllClasses1(Class, chan, p) = TrialAvg;
        end
    end
end
figure('units','normalized','outerposition',[0 0 1 1]);  
for p=1:2
    AllClassesR = AllClasses1((4:-1:1),:,p)';
    % - let the input dimensions be n_electrodes x n_classes
    % - The first class is slow, 4th class is ballistic
    % - the output electrodes and their locations are needed
    HMAllClassesReduced_SubPlots(AllClassesR, ChosenLocs, p, n_phases, [0 1]);
end



% Colorbar
cb = colorbar('Ticks', (0:0.1:1));
b =  cb.Position; %gets the positon and size of the color bar
dx = 0.05;
dy = 0.02;
w = 1.75*b(3);
h = 2.4*b(4);
set(cb,'Position',[b(1)+dx b(2)+dy w h])% To change size
Title2 = ['EMG'];
title(cb,Title2);
% text Labels
% 1. Phases
LeftX1 = -5;
TopY1 = 2.15;
BottomY1 = 0.5;
YStep = (TopY1-BottomY1)/(n_phases-1);

Phases = {'[-t, 0]'; '[0,t]';};
for p=1:n_phases
text(LeftX1,(TopY1-(p-1)*YStep), Phases{p}, 'Fontsize', 20, 'Fontweight', 'bold'); 
end


% 2. Classes
TopY2 = 2.35;
LeftX2 = -4.4;
RightX2 = -0.15;
XStep = (RightX2-LeftX2)/(n_classes-1);
Classes = {'Slow'; 'Medium'; 'Fast'; 'Ballistic'};
for c=1:n_classes
text(LeftX2+(c-1)*XStep,TopY2, Classes{c}, 'Fontsize', 20, 'Fontweight', 'bold'); 
end
%



end