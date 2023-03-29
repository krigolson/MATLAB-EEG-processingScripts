%% KLab ERP ActiChamp Processing Script by Mat and Olav
% Used to compare effects of different preprocessing pipelines on EEG data
% quality. 

% Simply pass in data from the eyes-open eyes-closed task, input which
% pipeline you want to run, and compare measures of data quality. 

%% Prepare Data
% clear memory, close all windows, clear command window
clear
close all
clc

% specifcy the path to the data and the data filename
pathName = '/Users/mathewhammerstrom/Documents/GitHub/MATLAB-EEG-processingScripts/Cognitive_Assessment_Baseline';
fileName = 'Cognitive_Assessment_Baseline_1042.vhdr';

% change to location where data is
cd(pathName);

% load the data
EEG = doLoadBVData(pathName,fileName);

% Determine start and stop points of EO and EC
for counter = 1:length(EEG.event)
    if strcmp(EEG.event(counter).type,'S  1')
        eyesOpenStart = EEG.event(counter).latency;
    elseif strcmp(EEG.event(counter).type,'S  3')
        eyesCloseStart = EEG.event(counter).latency;
    elseif strcmp(EEG.event(counter).type,'S  2')
        eyesOpenEnd = EEG.event(counter).latency;   
    elseif strcmp(EEG.event(counter).type,'S  4')
        eyesCloseEnd = EEG.event(counter).latency;
    end
end

%% Pre-process Data: Pipeline Comparison
% Determine which analysis pipeline you want to run:

pipeLine = 1;

if pipeLine == 1 % "Traditional" pipeline
    [EEG] = doRereference(EEG,{'TP9','TP10'},'ALL',EEG.chanlocs);  %Rereference to mastoids
    [EEG] = doFilter(EEG,0.1,30,4,60,250); %Filter data
    
    [EEG] = doICA(EEG,1); % Run a fast ICA
    [EEG] = doRemoveEyeComponents(EEG); %Use IC Label to remove blinks

elseif pipeLine == 2 % Simplified PREP Pipeline
    [EEG, output, time] = doPrepPipeline(EEG); %PREP does its own noise removal and rereferencing
    
    [EEG] = doICA(EEG,1);
    [EEG] = doRemoveEyeComponents(EEG);

elseif pipeLine ==3 % Add in a filter before a PREP Pipeline
    [EEG] = doFilter(EEG,0.1,30,4,60,250); % Compare what happens when you filter before PREP
    [EEG] = doICA(EEG,1);
    [EEG] = doRemoveEyeComponents(EEG);
    [EEG, output, time] = doPrepPipeline(EEG);
end

%% Pre-process Data: Normal steps for post-noise/blink removal
% Open up two variables for eyes open and eyes closed
EEGEO = EEG;
EEGEC = EEG;

% Alter the EEG data to only include Eyes Open (EO)
EEGEO.data(:,eyesOpenEnd:end) = []; %Remove all data after end of EO
EEGEO.data(:,1:eyesOpenStart) = []; %Remove all data before EO
EEGEO.pnts = size(EEGEO.data,2); %Fix the pnts variable to reflect the new data dimensions
EEGEO.xmax = 1/EEGEO.srate*EEGEO.pnts; %Fix the xmax variable

% Complete the pre-processing steps 
[EEGEO] = doTemporalEpochs(EEGEO,1000,100); % Create multiple one-second epochs 
[EEGEO] = doArtifactRejection(EEGEO,'Difference',150); % Artifact rejection, only using difference here
[EEGEO] = doRemoveEpochs(EEGEO,EEGEO.artifact.badSegments,0); % Remove components 
[FFTEO] = doFFT(EEGEO,{'S  1'}); % Run FFT on new segments you created 

% Repeat the above steps for Eyes Closed (EC)
EEGEC.data(:,eyesCloseEnd:end) = [];
EEGEC.data(:,1:eyesCloseStart) = [];
EEGEC.pnts = size(EEGEC.data,2);
EEGEC.xmax = 1/EEGEC.srate*EEGEC.pnts;

[EEGEC] = doTemporalEpochs(EEGEC,1000,100);
[EEGEC] = doArtifactRejection(EEGEC,'Difference',150);
[EEGEC] = doRemoveEpochs(EEGEC,EEGEC.artifact.badSegments,0);
[FFTEC] = doFFT(EEGEC,{'S  1'});

% Plot the data at channel Pz to check alpha effect
plot(1:30,FFTEO.data(13,1:30))
hold on;
plot(1:30,FFTEC.data(13,1:30))
hold on;
legend;

%% Compare data quality 
chanArtifacts(:,1) = EEGEC.channelArtifactPercentages(:,:);
chanArtifacts(:,2) = EEGEO.channelArtifactPercentages(:,:);

