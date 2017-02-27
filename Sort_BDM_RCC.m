function [] = Sort_BDM_RCC(subjectID,outputPath,session,BeforeOrAfter)

% function [] = Sort_BDM_RCC(subjectID,order,outputPath)

% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
% =============== Created based on the previous boost codes ===============
% ==================== by Rotem Botvinik May 2015 ====================
% ================= adjusted by Rani Gera Oct 2016 ===================
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

% This function sorts the stimuli according to the BDM results.
% * The commented code lines in the code were used for assaigning stimuli by
% their ranking order to paired and unpaired (in an older version...)

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% % % --------- Exterior files needed for task to run correctly: ----------
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%   [mainPath '\Output\' subjectID 'day%d__Fractals_BDM%d_' timestamp '.txt', day, BeforeOrAfter(1 or 2)]

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% % % ------------------- Creates the following files: --------------------
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%   'day%d_Sorted_BDM%d_order%d.txt', day, BeforeOrAfter(1 or 2) , order

tic

%=========================================================================
%%  PARAMETERS
%=========================================================================
if strcmp(BeforeOrAfter,'before')
    NameOfExperiment = ['_day' num2str(session) '_Fractals_BDM1_'];
    AllStimFileName = '_Sorted_BDM1';
elseif strcmp(BeforeOrAfter,'after')
    NameOfExperiment = ['_day' num2str(session) '_Fractals_BDM2_'];
    AllStimFileName = '_Sorted_BDM2';
end

%RelevantStimFileName = '_PairingList_RelevantStim';
%RelevantRangeForStimuli = 5:16;
%Order1_PairdStimuliLocation = [5 10 11 16];
%Order2_PairdStimuliLocation = [6  9 12 15];
%Order3_PairdStimuliLocation = [7  8 13 14];
%=========================================================================
%%  read in info from BDM1.txt
%=========================================================================
% Loading and sorting the files by date and time
SubjectFileOrFiles = dir([outputPath '/' subjectID NameOfExperiment '*.txt']);
S = [SubjectFileOrFiles(:).datenum].'; % you may want to eliminate . and .. first.
[~,S] = sort(S);
SortedByDate = {SubjectFileOrFiles(S).name}; % Cell array of names in order by datenum.

fid = fopen([outputPath '/' SortedByDate{end}]); % Here we take only the most recently formed file.
BDM_data = textscan(fid, '%s%d%f%s%f%f%f', 'HeaderLines', 1); %read in data as new matrix   
fclose(fid);

%=========================================================================
%%  Create matrix sorted by descending bid value
%========================================================================

[bids_sort,trialnum_sort_bybid] = sort(BDM_data{5},'descend');

bid_sortedM(:,1) = trialnum_sort_bybid; % trialnums organized by descending bid amt
bid_sortedM(:,2) = bids_sort; % bids sorted large to small
NumOfStimuli = size(bid_sortedM,1);
bid_sortedM(:,3) = 1:1:NumOfStimuli; % stimrank

stimnames_sorted_by_bid = BDM_data{4}(trialnum_sort_bybid);

%=========================================================================
%%   The ranking of the stimuli determine the stimtype; 10 = Non Paired, 11 = Paired.
%=========================================================================
% bid_sortedM(RelevantRangeForStimuli, 4) = 10;
bid_sortedM(:, 4) = 10; % No meaning for version 7. Made to keep analysis codes relevant.

% if order == 1
%     bid_sortedM(Order1_PairdStimuliLocation, 4) = 11; % Paired
% elseif order == 2  
%     bid_sortedM(Order2_PairdStimuliLocation, 4) = 11; % Paired  
% elseif order == 3   
%     bid_sortedM(Order3_PairdStimuliLocation, 4) = 11; % Paired   
% end 

%itemsForTraining = bid_sortedM(RelevantRangeForStimuli,:);
%itemsNamesForTraining = stimnames_sorted_by_bid(RelevantRangeForStimuli);

%=========================================================================
%%  Create pairing lists of all stimuli and of only relevant stimuli
%   this files will be used for trainings and probes
%=========================================================================

fid2 = fopen([outputPath '/' subjectID sprintf(['_day%d' AllStimFileName '.txt'],session)], 'w');    

% I added on January 2017:
fprintf(fid2,'Stimulus\tStim_Type\tRank\tBid\tTrial_Number\n'); %write the header line

for i = 1:length(bid_sortedM)
    fprintf(fid2, '%s\t%d\t%d\t%d\t%d\n', stimnames_sorted_by_bid{i,1},bid_sortedM(i,4),bid_sortedM(i,3),bid_sortedM(i,2),bid_sortedM(i,1)); 
end
fprintf(fid2, '\n');
fclose(fid2);

% fid3 = fopen([outputPath '/' subjectID RelevantStimFileName '.txt'], 'w');    
% 
% for i = 1:length(itemsForTraining)
%     fprintf(fid3, '%s\t%d\t%d\t%d\t%d\t\n', itemsNamesForTraining{i,1},itemsForTraining(i,4),itemsForTraining(i,3),itemsForTraining(i,2),itemsForTraining(i,1)); 
% end
% fprintf(fid3, '\n');
% fclose(fid3);

end % end function