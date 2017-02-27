function [PairedStimuli, UnpairedStimuli, PairedColor, UnpairedColors] = AssignStimuli(subjectID,OutputPath)

% function [PairedStimuli, UnpairedStimuli, PairedColor, UnpairedColors] = AssignStimuli(subjectID,OutputPath)
% Assigning the stimuli into relevant and unrelevant and into paired and
% unpaired.
%
% ON THIS OLDER VESION FIRST THE PAIRED COOLOR IS CHOSEN AND THEN THE
% RELEVANT SRIMULI.
%
% The assignment process:
% ------------------------
% Choosing the Paired group:
% 1) The function calculate the bid average of all the bids.
% 2) The color group that its averagse is in the middle will be the paired
% color.
% Choosing the paired stimuli:
% 3) The average bid for each group of stimuli is calculated.
% 4) In each color group the 3 closest to average are chosen to be relevant for the of the experiment.

%% Extracting a table:
RelevantFile = dir([OutputPath '/' subjectID '_day1_Sorted_BDM1*.txt']);
DataTable = readtable([OutputPath '/' RelevantFile.name],'Delimiter','\t');
% Defining Tables of the different colors
RedTable = DataTable(~cellfun(@isempty,strfind(DataTable{:,1},'Red')),:);
GreenTable = DataTable(~cellfun(@isempty,strfind(DataTable{:,1},'Green')),:);
BlueTable = DataTable(~cellfun(@isempty,strfind(DataTable{:,1},'Blue')),:);
%Getting the average bid for each color
Averages = [ mean(RedTable.Bid) ; mean(GreenTable.Bid) ; mean(BlueTable.Bid)];
AveragesTable = table(Averages,'RowNames',{'Red' 'Green' 'Blue'});
AveragesTable = sortrows(AveragesTable);

%% Define paired and unpaired colors:
PairedColor = AveragesTable.Properties.RowNames{2};
UnpairedColors = [AveragesTable.Properties.RowNames(1) AveragesTable.Properties.RowNames(3)];

%% Choose the relevant stimuli
RedTable.DistanceFromAverage = abs(RedTable.Bid - AveragesTable{'Red',:});
GreenTable.DistanceFromAverage = abs(GreenTable.Bid - AveragesTable{'Green',:});
BlueTable.DistanceFromAverage = abs(BlueTable.Bid - AveragesTable{'Blue',:});

RedTableSortedByDistanceFromAverage = sortrows(RedTable,'DistanceFromAverage');
GreenTableSortedByDistanceFromAverage = sortrows(GreenTable,'DistanceFromAverage');
BlueTableSortedByDistanceFromAverage = sortrows(BlueTable,'DistanceFromAverage');

RelevantStimuli = [ RedTableSortedByDistanceFromAverage{1:3,1} ; GreenTableSortedByDistanceFromAverage{1:3,1} ; BlueTableSortedByDistanceFromAverage{1:3,1}];
PairedStimuli = RelevantStimuli(~cellfun(@isempty,strfind(RelevantStimuli,PairedColor)));
UnpairedStimuli = RelevantStimuli(cellfun(@isempty,strfind(RelevantStimuli,PairedColor)));

end