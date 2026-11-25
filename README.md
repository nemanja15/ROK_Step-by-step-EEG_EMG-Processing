# Rewritten-EEG_EMG-Code
This repo consists of a top-level .mlx file for each subject.
The subject .mlx file will generate the required connectivity results for that subject.
The following is an example of a MATLAB .mlx file for a particular subject (FDA013).
All subjects' .mlx files contain such explanations and clarifications.
```
% Written by Rory O'Keeffe on 07/19/22 @ MERIIT Lab, ECE Dept, NYU Tandon.
```
**Pre-Xmas Data Processing Pipeline for FDA**

Step 1: Loading Raw Data 
Insert the raw data directory below. 
```
clear all;
DataDirectory = 'D:\OneDrive\Documents\GitHub\EEG\FDA Data\FDA014';
```
Specify the **file trial numbers** in the correct order. The order of isometric trials should be 20%, 0.5s, 20%, 1s, ...60%, 3s. Check the isometric trial numbers carefully as they are randomized. The order of the cycling trials will be 0 turns, 1.5 turns, 3 turns,  4.5 turns, 6 turns. These are not randomized so numbers are sequential. The trial numbers for each subject are available at the Google Spreadsheet below:
https://docs.google.com/spreadsheets/d/1WKzZdX0CGqx-LiZJC8p2msoUgvE--3WIlVS5Bx37PbU/edit#gid=594835701
```
TrialNumbersIso = [6 7 5 8 4 3 2]; 
TrialNumbersCyc = [9:12 14];
TrialNumbers = [TrialNumbersIso TrialNumbersCyc];
```
**Load** the SD card data using the Step1 function with the data directory and trial numbers as inputs. The output should be a 2 x 13 cell. The dimensions of each element of the cell are NumberOfChannels (68) x NumberOfTimePoints. The first 64 are the channel signals and the last 4 are some auxiliary channels.
```
SDCardData = Step1LoadSDCardData(DataDirectory, TrialNumbers);
```
**Load** the SS data. The trial numbers for this subject will be the same as above (see spreadsheet). The output should be a 1 x 13 cell. The dimensions of each element of the cell are NumberOfChannels (3) x NumberOfTimePoints. There are 3 auxiliary input channels of interest: (1) Delsys trigger input, (2) SyncStation pulse signal and (3) Force signal.
```
SSData = Step1LoadSSData(DataDirectory, TrialNumbers);
```

**Load** the Delsys data. For the trial numbers, we want to use the end numbers in the Delsys file (e.g. if 1_10.csv, we want 10). For this subject, the end numbers of interest are simply TrialNumbers-1. Delsys CSV files contains many useless column variables (e.g. a time vector that is the same for all Avanti sensors). We only care about some pre-defined 'Useful Variables', so we selece these. The output cell DelsysData consists of the sensor data (row 1), the sensor names (row 2) and sampling frequencies (row 3). Each column of DelsysData is a task.
```
TrialNumbersD = TrialNumbers-1; TrialNumbersD(8:12) = [10:13 15];
load('Useful Column Variables.mat')
DelsysData = Step1LoadDelsysData1(DataDirectory,TrialNumbersD, UsefulVariables);
```

**Step 2: Synchronizing Data**

Sync the OTB data. The difference between the Sync Se and the SyncStation pulses is used to align the SD card data signals (EEG and EMG) with SyncStation data signals (Force). The output SyncedOTBData contains the synced SD card and force signals.
```
[SyncedOTBData, AlignmentPoints] = Step2SynchronizeOTBData(SDCardData, SSData);
```

Sync the Delsys Data with OTB data using the Delsys trigger. The output AllSyncedData contains the synced elements of SyncedOTBData and Delsys signals (four modalities, EEG. HD-EMG, force and Delsys {EMG, IMU, gonios}).
subject = 14;
AllSyncedData = Step2SynchronizeDelsysData(SyncedOTBData, DelsysData, subject);
close all;

Step 3: Resampling Data
Resample all the data to a common sampling frequency. Here we choose fs_EEG (500 Hz) as the common sampling frequency. 
```
fs_EEG = 500; fs_HDEMG = 2000; 
All_OTB_fs = [fs_EEG fs_HDEMG fs_HDEMG]; fs_common = fs_EEG;
ResampledData = Step3ResampleData(AllSyncedData, fs_common, All_OTB_fs);
```
Step 4: Band-Filtering Data
Filter all signals into a common frequency range. This feature can be adjusted later, to have different ranges for different modalities. For now, since we are focusing on corticomuscular connectivity, EEG and EMG can have the same band-filtering. 
```
BandOfInterest = [0.5 10];
FilteredData = Step4FilterData(ResampledData, BandOfInterest, fs_common);
```
Step 5: Epoch Data
For isometric tasks, use the force signals to epoch. For cycling tasks, use the Delsys signals (goniometer). The processing will be different depending on whether we are using force signal or goniometer to epoch, so the task indexes are needed as input.
```
ForceTaskIdx = 1:7; OtherTaskIdx = 8:12;
EpochedData = Step5EpochData(FilteredData, ForceTaskIdx, OtherTaskIdx, fs_common);
```
Step 6: Laplacian Spatial Filtering
Apply Laplacian spatial filtering to the EEG. The processing will be different depending on if we are using force signal or goniometer to epoch, so the task indexes are needed. The locations of all electrodes are needed for the Laplacian spatial filtering. The configuration of the Laplacian filtering applied to the current electrode will depend on the current electrode and available surroudning electrodes. There are three possible configurations: +, L, or T. 
```
LapData = Step6LapFilterData(EpochedData, ForceTaskIdx, OtherTaskIdx, Locations);
LapData = EpochedData;
```

Step 7: Prepare for Connectivity Calculations
HD-EMG can be averaged across channels. We can choose to compute the median across four regions such that the channels dimension is reduced from 64 to 4 (commented out below). Or we can simply choose to compute one median across all 64 channels such that the channels dimension is reduced to 1.
Choose modalities for the connectivity calculation. For now, we choose EEG and HD-EMG (modalities 1 and 2).
Choose the desired EEG channels. For now, we choose all 64 EEG channels.
```
HDEMGChannelReductionMethod = 'AllToOne'; 
ModalitiesIdx = [1 2];
EEGChannelIdx = 1:64;
PreparedData = Step7PrepareForConnectivity(LapData, ForceTaskIdx, OtherTaskIdx, ModalitiesIdx, EEGChannelIdx, HDEMGChannelReductionMethod);

% HDEMGChannelReductionMethod = 'AllToFour'; 
% load('RegionIdxs.mat')
% PreparedData = Step7PrepareForConnectivity(LapData, ForceTaskIdx, OtherTaskIdx, ModalitiesIdx, EEGChannelIdx, HDEMGChannelReductionMethod, RegionIdxs);
```
Step 8: Compute Connectivity
Compute the desired method of connectivity (coherence, power correlation, mutual information). 
For computing the connectivity for isometric tasks, it makes more sense to consider a window of (+/-T)s rather than the default window duration (-3,4)s, particularly when the task duration (T) is short. 
The ConnectivityOptions matrix sets the modalities between which we want to compute connectivity. For CMC {EEG (1) with HD-EMG(2)}, we set ConnectivityOptions = [1 2]. If we want to add intra-cortical connectivity, we will add another row as follows: ConnectivityOptions = [1 2; 1 1]. If we want to have just EEG-Delsys connectivity, ConnectivityOptions = [1 3]. Each connectivity modality will be stored in a separate cell in the output. For now, we just want CMC with HD-EMG so ConnectivityOptions = [1 2].
The output AllCoherences has 3 layers of cells. The first layer separates the connectivity modalties with dimensions size(ConnectivityOptions,1) x 1. The second layer has dimensions of NClasses x NChannels1 x NChannels2, where NClasses is the number of force task classes (here = 8) and NChannelsX is the number of channels in ModalityX (here NChannels1 = 64 and NChannels2 = 1). The third layer has dimensions of NEpochs x 2 (we consider connectivity before AND after movement, -T and +T). Each element of the third layer is a coherence vector of length NFrequencyComponents. 
```
% IsometricMode = 'FullWindow';
IsometricMode = 'PlusMinusT';
ConnectivityOptions = [1 2];
ForceTaskDurations = [0.5 1 2 3 0.5 1 3];
ForceTaskClasses = [1:6 8];
AllCoherences = Step8ComputeCoherence(PreparedData, ConnectivityOptions, ForceTaskIdx, ForceTaskClasses, OtherTaskIdx, IsometricMode, fs_common);
```
Step 9: Plot Results
Plot the results:
Plot isometric task (1:8) results for CMC.
```
CMC = AllCoherences{1};
Step9PlotConnectivity(CMC(1:8, :, :));
```

