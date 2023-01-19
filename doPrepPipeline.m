%% Krigolson PREP Pipeline function

function [EEG] = doPrepPipeline(EEG)

data = EEG;
events = data.event;

%% Clear boundary events
% Clear any boundary events. This prevents errors in the prepPipeline
% call, and these markers are essentially useless in our data. 

for counter = 1:length(events) %For all events/markers in our data,
    if strcmp(events(counter).type, 'boundary') %Find boundary event, and
        data.event(counter) = []; %Delete it. 
    end
end

% Next, send a message to determine if the parallel computing toolbox is
% installed. If it isnt, give user a chance to stop, as the process is very
% slow without it. 

if ~contains(struct2array(ver), 'Parallel Computing Toolbox')
    input(['WARNING: Parallel Computing Toolbox not installed.' newline 'Without it, this process will be lengthy.' newline 'Press any key to continue anyways.'])
end

%% Initiate PrepPipeline
% All we are doing here is initating the prepPipeline with default
% settings.
[data] = prepPipeline(data,[]);

%% Generate report. 
%Using EEG-Clean-Tools commands, we can generate summary and detailed
%reports of the PREP process. 

newFileName = data.filename(1:end-5); %Remove the .vhdr from the filename to keep it clean. 
publishPrepReport(data, [data.pathname newFilename 'summary.pdf'], [data.pathname newFileName 'detailed.pdf'], 1, true);