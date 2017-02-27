function [PairedStimuli, UnpairedStimuli, PairedColor, UnpairedColors] = AssignStimuli(subjectID,OutputPath)

% function [PairedStimuli, UnpairedStimuli, PairedColor, UnpairedColors] = AssignStimuli(subjectID,OutputPath)
% Assigning the stimuli into relevant and unrelevant and into paired and
% unpaired.
%
% The assignment process:
% ------------------------
% Choosing the relevant stimuli:
% 1) The function calculate the bid average of all the bids.
% 2) The 3 stimuli out of each color which are the closest to the mean are
% chosen to be used rest of the experiment. Now we have the 9 relevant
% stimuli.
% Choosing the Paired group:
% 3) The average bid for each relevant group of stimuli is calculated.
% 4) The middle average is defined as the Paired color and the others as
% the Unpaired colors.

%% Extracting a table:
RelevantFile = dir([OutputPath '/' subjectID '_day1_Sorted_BDM1*.txt']);
DataTable = readtable([OutputPath '/' RelevantFile.name],'Delimiter','\t');
% Getting total average:
AllStimuliBidMean = mean(DataTable.Bid);
DataTable.DistanceFromAllStimuliAverage = abs(DataTable.Bid - AllStimuliBidMean);
% Defining Tables of the different colors
RedTable = DataTable(~cellfun(@isempty,strfind(DataTable{:,1},'Red')),:);
GreenTable = DataTable(~cellfun(@isempty,strfind(DataTable{:,1},'Green')),:);
BlueTable = DataTable(~cellfun(@isempty,strfind(DataTable{:,1},'Blue')),:);
% Sorting according to distance from average:
RedTableSortedByDistanceFromAverage = sortrows(RedTable,'DistanceFromAllStimuliAverage');
GreenTableSortedByDistanceFromAverage = sortrows(GreenTable,'DistanceFromAllStimuliAverage');
BlueTableSortedByDistanceFromAverage = sortrows(BlueTable,'DistanceFromAllStimuliAverage');
% Define the relevant out of each color:
RedRlevantStimuliTable = RedTableSortedByDistanceFromAverage(1:3,:);
GreenRlevantStimuliTable = GreenTableSortedByDistanceFromAverage(1:3,:);
BlueRlevantStimuliTable = BlueTableSortedByDistanceFromAverage(1:3,:);

RelevantStimuliTable = [RedRlevantStimuliTable ; GreenRlevantStimuliTable ; BlueRlevantStimuliTable];
RelevantStimuli = RelevantStimuliTable.Stimulus;
% Getting the average distance from the mean for each color
AveragesBidsAccordingToColorForChosenStimuli = [mean(RedRlevantStimuliTable.Bid) ; mean(GreenRlevantStimuliTable.Bid) ;  mean(BlueRlevantStimuliTable.Bid)];
AveragesBidsAccordingToColorForChosenStimuliTable = table(AveragesBidsAccordingToColorForChosenStimuli,'RowNames',{'Red' 'Green' 'Blue'});
AveragesBidsAccordingToColorForChosenStimuliTable = sortrows(AveragesBidsAccordingToColorForChosenStimuliTable);

%% Define paired and unpaired colors:
PairedColor = AveragesBidsAccordingToColorForChosenStimuliTable.Properties.RowNames{2};
UnpairedColors = [AveragesBidsAccordingToColorForChosenStimuliTable.Properties.RowNames(1) AveragesBidsAccordingToColorForChosenStimuliTable.Properties.RowNames(3)];
%% Define the paired and unpaired stimuli:
PairedStimuli = RelevantStimuli(~cellfun(@isempty,strfind(RelevantStimuli,PairedColor)));
UnpairedStimuli = RelevantStimuli(cellfun(@isempty,strfind(RelevantStimuli,PairedColor)));

end