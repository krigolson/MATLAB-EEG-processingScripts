function EEG = doRemoveEyeComponents(EEG)

    [EEG] = iclabel(EEG, 'default'); %Automatic Inverse ICA
    eyeLabel = find(strcmp(EEG.etc.ic_classification.ICLabel.classes,'Eye')); %Find the components classified as blinks
    eyeI = find(EEG.etc.ic_classification.ICLabel.classifications(:,eyeLabel)>0.8); %Index the components most likely to be blinks
    [EEG] = pop_subcomp(EEG,eyeI,0); %Remove/subtract the eyeblink components from the data
    
end