% KLab ERP ActiChamp Processing Script by Mat and Olav

% clear memory, close all windows, clear command window
clear
close all
clc

% specifcy the path to the data and the data filename
pathName = '/Users/krigolson/Documents/GitHub/MATLAB-EEG-processingScripts/Cognitive_Assessment_Baseline';
fileName = 'Cognitive_Assessment_Baseline_1043.vhdr';

% change to location where data is
cd(pathName);

% load the data
EEG = doLoadBVData(pathName,fileName);

EEG = doFilter(EEG,0.1,30,2,60,EEG.srate);

%EEG = doICA(EEG,1);

%EEG = doRemoveEyeComponents(EEG);

%[EEG, output, time] = doPrepPipeline(EEG);

EEG = doRereference(EEG,{'TP9','TP10'},{'ALL'},EEG.chanlocs);

EEG = doTemporalEpochs(EEG,1000,100);

EEG = doArtifactRejection(EEG,'Difference',150);

EEG = doRemoveEpochs(EEG,EEG.artifact.badSegments,0);

FFT = doFFT(EEG,{'S  1'});