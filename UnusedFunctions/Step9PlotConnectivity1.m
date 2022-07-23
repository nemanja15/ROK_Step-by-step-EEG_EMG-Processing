function Step9PlotConnectivity1(Input)
Types = {'Coherence';};
TopX = 0.1;
ConfigsOut = 'Chosen';
ConfigsIn = 'Chosen';
ChosenElectrodesIn = {'Fp1'; 'Fp2'; 'AFz'; 'F3'; 'Fz'; 'F4'; 'FC1'; 'FC2'; 'C3'; 'Cz'; 'C4'; 'CP1'; 'CP2'; 'P3'; 'Pz'; 'P4'; 'EMG';'dE/dt'};
ChosenElectrodesOut = {'Fp1'; 'Fp2'; 'AFz'; 'F3'; 'Fz'; 'F4'; 'FC1'; 'FC2'; 'C3'; 'Cz'; 'C4'; 'CP1'; 'CP2'; 'P3'; 'Pz'; 'P4';};
n_classes = 4;
HeatColor = 'jet';
%%
load('Code/Example_EEG_SS.mat');
AllLocs = EEG.chanlocs; AllLabels = {};
for c=1:64
AllLabels{c,1} = AllLocs(c).labels;
end
clear ChosenLocs;
for e=1:length(ChosenElectrodesOut)
Idx = find(strcmp(ChosenElectrodesOut(e),AllLabels ));
ChosenLocs(e) = AllLocs(Idx);
end

%%
LineColor = [0 0 0];
ConnectedElectrode = 'EMG';
CEIdx = find(strcmp(ConnectedElectrode,ChosenElectrodesIn));
% ConnectedElectrode = 'dE/dt';

% Move to 2nd screen
Text = true;
Lines = true;
n_phases = 2;
for F=2:2
Idxs = (F-1)*4+(1:4);
AllClassesChosen = AllClassesT(:,:,Idxs,1);
AC1 = AllClassesChosen; AC2 = AC1(AC1~=0);
MinAllL = min(AC2);
MaxAllL = max(AC2);
AC0 = FillMatG(AC1);
AC1 = squeeze(AC0(CEIdx,1:18,:));
MaxAllH = max(max(AC1)); MinAllH = min(min(AC1));
figure('units','normalized','outerposition',[0 0 1 1]);  
p=1;
AllClassesReOrdered = AllClassesChosen(:,:,(4:-1:1));
% - The input to this function should be n_electrodes x n_electrodes x 4
% - we only care about the connections between EMG and EEG
% - The first class is slow, 4th class is ballistic
% - the output electrodes and their locations are needed
FCGraphAndHMAllClasses2Reduced_SubPlotsF2(FillMatG(AllClassesReOrdered), TopX, ConfigsOut, ChosenElectrodesOut,  ConfigsIn, ...
ChosenElectrodesIn, ConnectedElectrode, LineColor, p, n_phases,Text, Lines, [0 1], [0 1],ChosenLocs);

AllClassesChosen = AllClassesT(:,:,Idxs,2);
AC1 = AllClassesChosen; AC2 = AC1(AC1~=0);
MinAllL = min(AC2);
MaxAllL = max(AC2);
AC0 = FillMatG(AC1);
AC1 = squeeze(AC0(CEIdx,1:18,:));
MaxAllH = max(max(AC1)); MinAllH = min(min(AC1));
p=2;
AllClassesReOrdered = AllClassesChosen(:,:,(4:-1:1));
FCGraphAndHMAllClasses2Reduced_SubPlotsF2(FillMatG(AllClassesReOrdered), TopX, ConfigsOut, ChosenElectrodesOut,  ConfigsIn, ...
ChosenElectrodesIn, ConnectedElectrode, LineColor, p, n_phases,Text, Lines, [0 1], [0 1],ChosenLocs);
% Colorbar
cb = colorbar('Ticks', (0:0.1:1));
b =  cb.Position; %gets the positon and size of the color bar
dx = 0.05;
dy = 0.02;
w = 1.75*b(3);
h = 2.4*b(4);
set(cb,'Position',[b(1)+dx b(2)+dy w h])% To change size
Title2 = [ConnectedElectrode];
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


end