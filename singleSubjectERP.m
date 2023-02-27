% KLab ERP ActiChamp Processing Script by Mat and Olav

% clear memory, close all windows, clear command window
clear
close all
clc

% specifcy the path to the data and the data filename
pathName = '/Users/krigolson/Desktop/Cognitive_Assessment_Baseline';
fileName = 'Cognitive_Assessment_Baseline_1040.vhdr';

% change to location where data is
cd(pathName);

% load the data
EEG = doLoadBVData(pathName,fileName);

%[EEG1, output, time] = doPrepPipeline(EEG);

EEG1 = EEG;

EEG2 = EEG1;

%EEG = doFilter(EEG,0.1,30,2,60,EEG.srate);
%EEG1 = doFilter(EEG1,0.1,30,2,60,EEG1.srate);
%EEG2 = doFilter(EEG2,0.1,30,2,60,EEG2.srate);

%EEG = doRereference(EEG,{'TP9','TP10'},{'ALL'},EEG.chanlocs);
%EEG1 = doRereference(EEG1,{'TP9','TP10'},{'ALL'},EEG1.chanlocs);
%EEG2 = doRereference(EEG2,{'TP9','TP10'},{'ALL'},EEG2.chanlocs);

EEG = doSegmentData(EEG,{'S202','S203'},[-200 800]);
EEG1 = doSegmentData(EEG1,{'S202','S203'},[-200 800]);
EEG2 = doSegmentData(EEG2,{'S202','S203'},[-1000 2000]);

EEG2 = doICA(EEG2,1);
EEG2 = doRemoveEyeComponents(EEG2);

EEG2 = doSegmentData(EEG2,{'S202','S203'},[-200 800]);

EEG = doBaseline(EEG,[-200 0]);
EEG1 = doBaseline(EEG1,[-200 0]);
EEG2 = doBaseline(EEG2,[-200 0]);

EEG = doArtifactRejection(EEG,'Difference',150);
EEG1 = doArtifactRejection(EEG1,'Difference',150);
EEG2 = doArtifactRejection(EEG2,'Difference',150);

EEG = doRemoveEpochs(EEG,EEG.artifact.badSegments,0);
EEG1 = doRemoveEpochs(EEG1,EEG1.artifact.badSegments,0);
EEG2 = doRemoveEpochs(EEG2,EEG2.artifact.badSegments,0);

ERP = doERP(EEG,{'S202','S203'},0);
ERP1 = doERP(EEG1,{'S202','S203'},0);
ERP2 = doERP(EEG2,{'S202','S203'},0);

time = ERP.times;

subplot(2,3,1);
plot(time,ERP.data(13,:,1));
hold on;
plot(time,ERP.data(13,:,2));

subplot(2,3,2);
plot(time,ERP1.data(13,:,1));
hold on;
plot(time,ERP1.data(13,:,2));

subplot(2,3,3);
plot(time,ERP2.data(13,:,1));
hold on;
plot(time,ERP2.data(13,:,2));

subplot(2,3,4);
bar(EEG.channelArtifactPercentages);

subplot(2,3,5);
bar(EEG1.channelArtifactPercentages);

subplot(2,3,6);
bar(EEG2.channelArtifactPercentages);




