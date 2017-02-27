function [] = Analyse_BDM(EarlierBDMtoAnalyzeDayAndNumberVec,LaterBDMtoAnalyzeDayAndNumberVec, Test)

% function [] = Analyse_BDM(EarlierBDMtoAnalyzeDayAndNumberVec,LaterBDMtoAnalyzeDayAndNumberVec, Test)

% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

tic

if nargin < 2
    fprintf('BDM Analysis - please enter the day and number of the BDMs you want to compare\n')
    fprintf('* The diffrences are calculated as Later BDM - Earlier BDM of your input\n')
    fprintf('* On day 1 there is BDM1 for baseline and BDM2 after the training. On 2nd and 3rd day only BDM2 at the end of the days.\n')
    EarlierBDMtoAnalyzeDayAndNumberVec(1) = input('Earlier BDM day: '); EarlierBDMtoAnalyzeDayAndNumberVec(2) = input('Earlier BDM number: ');
    LaterBDMtoAnalyzeDayAndNumberVec(1) = input('Later BDM day: '); LaterBDMtoAnalyzeDayAndNumberVec(2) = input('Later BDM number: ');
end
%=========================================================================
%%  PARAMETERS
%=========================================================================
NameOfEarlierFile = ['_day' num2str(EarlierBDMtoAnalyzeDayAndNumberVec(1)) '_Sorted_BDM' num2str(EarlierBDMtoAnalyzeDayAndNumberVec(2)) '_order*.txt']; % The name of the experiment or the file.
NameOfLaterFile = ['_day' num2str(LaterBDMtoAnalyzeDayAndNumberVec(1)) '_Sorted_BDM' num2str(LaterBDMtoAnalyzeDayAndNumberVec(2)) '_order*.txt']; % The name of the experiment or the file.
% Additional parameters to the BDM1 sorting version:
outputPath = '/Users/ranigera/Dropbox/experimentsOutput/RCC/Output/';
subjectsToExclude = [];
ExpCode = 'RC7';
if exist('Test','var')
    if strcmp(Test,'Test')
        ExpCode = 'TST';
    end
end

%% SUBJECTS
RelevantSubjetcs = [];
FilesWithBDM = dir([outputPath '*Sorted_BDM2*.txt']);
for i = 1:size(FilesWithBDM,1)
    if i == 1 || str2double(FilesWithBDM(i).name(5:7)) ~= str2double(FilesWithBDM(i-1).name(5:7))
        RelevantSubjetcs(end+1) = str2double(FilesWithBDM(i).name(5:7));
    end
end
% Excluding subjects:
if ~isempty(subjectsToExclude)
    RelevantSubjetcs = RelevantSubjetcs(RelevantSubjetcs ~= subjectsToExclude);
end

Addition_N_or_R(RelevantSubjetcs > 100 & RelevantSubjetcs < 200) = 'N';
Addition_N_or_R(RelevantSubjetcs > 200 & RelevantSubjetcs < 300) = 'R';
SubjectsList = {};
for ind = 1:length(RelevantSubjetcs)
    SubjectsList{ind} = [ExpCode '_' num2str(RelevantSubjetcs(ind)) '_' Addition_N_or_R(ind)];
end

%% Pre-Allocating "all subjets" matrices:
%-----------------------------------
BidsGeneralStatistics = cell(length(SubjectsList)+1,6);
PairedBidStatistics = cell(length(SubjectsList)+1,7);
UnpairedBidStatistics = cell(length(SubjectsList)+1,7);
Paired_vs_UnpairedBidStatistics = cell(length(SubjectsList)+1,3);
AllRankingStatistics = cell(length(SubjectsList)+1,11);

% vectors for t-test:
PairedBidsMeanChangeVec = [];
UnpairedBidsMeanChangeVec = [];
RankingPairedMeanDiffVec = [];
RankingUnpairedMeanDiffVec = [];

MatrixForANOVAbids = zeros(length(SubjectsList),4);
% all data together matrix:
bid_sorted_all_subjects_BDM1 = {};
bid_sorted_all_subjects_BDM2 = {};

for SubjectIndex = 1 : length(SubjectsList)
    %=========================================================================
    %%  read in info from the sorted BDMs
    %=========================================================================
    earlier_sorted_BDM_file = dir([outputPath SubjectsList{SubjectIndex} NameOfEarlierFile]);
    EARLIER_BDM_sorted_data = readtable([outputPath earlier_sorted_BDM_file.name],'Delimiter','\t'); %read in data as new matrix
    
    Later_sorted_BDM_file = dir([outputPath SubjectsList{SubjectIndex} NameOfLaterFile]);
    LATER_BDM_sorted_data = readtable([outputPath Later_sorted_BDM_file.name],'Delimiter','\t'); %read in data as new matrix
    
    BDM_TABLES = {EARLIER_BDM_sorted_data LATER_BDM_sorted_data};
    
    %% Paired Colors by Order:
    %-----------------------------------
    SubjectNumber = str2double(SubjectsList{SubjectIndex}(6:7));
    switch mod(SubjectNumber,3)
        case 1
            order = 1;
            PairedColor = 'Red';
        case 2
            order = 2;
            PairedColor = 'Green';
        case 0
            order = 3;
            PairedColor = 'Blue';
    end
    
    %=========================================================================
    %%  Create the relevant data lists
    %========================================================================    
    % Assigning stimuli types
    for i = 1:size(BDM_TABLES,2)
        MarkedRelevantPaired = strfind(BDM_TABLES{i}.Stimulus, ['Group' PairedColor]);
        RelevantPairedStim = BDM_TABLES{i}.Stimulus(~cellfun('isempty', MarkedRelevantPaired));
        MarkedAllRelevantUnpaired = strfind(BDM_TABLES{i}.Stimulus, 'Group');
        MarkedAllRelevantUnpaired(~cellfun('isempty', MarkedRelevantPaired)) = {[]};
        RelevantUnpairedStim = BDM_TABLES{i}.Stimulus(~cellfun('isempty', MarkedAllRelevantUnpaired));
        BDM_TABLES{i}.Stim_Type(:) = 0;
        BDM_TABLES{i}.Stim_Type(ismember(BDM_TABLES{i}.Stimulus,RelevantPairedStim)) = 11;
        BDM_TABLES{i}.Stim_Type(ismember(BDM_TABLES{i}.Stimulus,RelevantUnpairedStim)) = 10;
    end
    
    BDM1_relevant_list = BDM_TABLES{1}(BDM_TABLES{1}.Stim_Type>0,:);
    BDM2_relevant_list = BDM_TABLES{2}(BDM_TABLES{2}.Stim_Type>0,:);
    BDM1_paired_list = BDM_TABLES{1}(BDM_TABLES{1}.Stim_Type==11,:);
    BDM2_paired_list = BDM_TABLES{2}(BDM_TABLES{2}.Stim_Type==11,:);
    BDM1_unpaired_list = BDM_TABLES{1}(BDM_TABLES{1}.Stim_Type==10,:);
    BDM2_unpaired_list = BDM_TABLES{2}(BDM_TABLES{2}.Stim_Type==10,:);
    
    
    %=========================================================================
    %%  Statistics
    %========================================================================
    % BIDS:
    %=============================
    % All stimuli:
    MeanAllBidsBDM1 = mean(BDM_TABLES{1}.Bid);
    MeanAllBidsBDM2 = mean(BDM_TABLES{2}.Bid);
    STD_all_Bids_BDM1 = std(BDM_TABLES{1}.Bid);
    STD_all_Bids_BDM2 = std(BDM_TABLES{2}.Bid);
    ChangeInMeansAllBids = MeanAllBidsBDM2 - MeanAllBidsBDM1;
    % Only relevant:
    MeanRelevantBidsBDM1 = mean(BDM1_relevant_list.Bid);
    MeanRelevantBidsBDM2 = mean(BDM2_relevant_list.Bid);
    % Paired and Unpaired:
    MeanPairedBidsBDM1 = mean(BDM1_paired_list.Bid);
    MeanPairedBidsBDM2 = mean(BDM2_paired_list.Bid);
    ChangeInMeansPairedBids = MeanPairedBidsBDM2 - MeanPairedBidsBDM1;
    %****************************-----Per stimulus:
    %DiffVecForPaired = BDM2_paired_list(1,2) - BDM2_paired_list(   
    MeanUnpairedBidsBDM1 = mean(BDM1_unpaired_list.Bid);
    MeanUnpairedBidsBDM2 = mean(BDM2_unpaired_list.Bid);
    ChangeInMeansUnpairedBids = MeanUnpairedBidsBDM2 - MeanUnpairedBidsBDM1;
    % standat scores (Z-scores)
    AverageBidsStandartScoreForPairedBDM1 = (MeanPairedBidsBDM1 - MeanAllBidsBDM1)/STD_all_Bids_BDM1;
    AverageBidsStandartScoreForPairedBDM2 = (MeanPairedBidsBDM2 - MeanAllBidsBDM2)/STD_all_Bids_BDM2;
    ChangeInBidsStdScorePaired = AverageBidsStandartScoreForPairedBDM2 - AverageBidsStandartScoreForPairedBDM1;
    
    AverageBidsStandartScoreForUnpairedBDM1 = (MeanUnpairedBidsBDM1 - MeanAllBidsBDM1)/STD_all_Bids_BDM1;
    AverageBidsStandartScoreForUnpairedBDM2 = (MeanUnpairedBidsBDM2 - MeanAllBidsBDM2)/STD_all_Bids_BDM2;
    ChangeInBidsStdScoreUnpaired = AverageBidsStandartScoreForUnpairedBDM2 - AverageBidsStandartScoreForUnpairedBDM1;
    % The important differences between Paired and Unpaired in the changes between BDM1 and BDM2:
    % (BDM2 - BDM1)of Paird - (BDM2 - BDM1)of Unpaird
    DifferenceInMeansChangeBetweenGroups = ChangeInMeansPairedBids - ChangeInMeansUnpairedBids;
    DifferenceInStdScoreChangeBetweenGroups = ChangeInBidsStdScorePaired - ChangeInBidsStdScoreUnpaired;
    % print:
    fprintf('\n  -------------------------------------------  %s  -------------------------------------------\n', 	SubjectsList{SubjectIndex})
    fprintf(' ''Before'' = Auction at the beginning of the experiment (before training)\n')
    fprintf(' ''After'' = Auction at the end of the experiment (after training and probe)\n')
    fprintf('  ----------------  Bids Analysis -----------------\n')
    fprintf(' General data:\n')
    fprintf(' mean ''before'': %.2f  std. dev: %.2f  |  mean ''after'': %.2f  std. dev: %.2f  |  change(after - before): %.2f\n', MeanAllBidsBDM1, STD_all_Bids_BDM1, MeanAllBidsBDM2, STD_all_Bids_BDM2, ChangeInMeansAllBids )
    fprintf(' Paired:\n')
    fprintf(' mean before: %.2f  std. score: %.2f  |  mean after: %.2f  std. score: %.2f  |  change in mean: %.2f  change in std. score:%.2f\n', MeanPairedBidsBDM1, AverageBidsStandartScoreForPairedBDM1, MeanPairedBidsBDM2, AverageBidsStandartScoreForPairedBDM2, ChangeInMeansPairedBids, ChangeInBidsStdScorePaired)
    fprintf(' Unpaired:\n')
    fprintf(' mean before: %.2f  std. score: %.2f  |  mean after: %.2f  std. score: %.2f  |  change in mean: %.2f  change in std. score:%.2f\n', MeanUnpairedBidsBDM1, AverageBidsStandartScoreForUnpairedBDM1, MeanUnpairedBidsBDM2, AverageBidsStandartScoreForUnpairedBDM2, ChangeInMeansUnpairedBids, ChangeInBidsStdScoreUnpaired)
    fprintf(' Paired vs. Unpaired (Paired minus Unpaired):\n')
    fprintf(' difference in mean change: %.2f   difference in std. score change: %.2f      [ * Here we would like to see positive values... ]\n', DifferenceInMeansChangeBetweenGroups, DifferenceInStdScoreChangeBetweenGroups)
    
    %=============================
    % RANKS:
    %=============================
    % On relevant:
    MeanRelevantRanksBDM1 = mean(BDM1_relevant_list.Rank);
    MeanRelevantRanksBDM2 = mean(BDM2_relevant_list.Rank);
    
    MeanPairedRanksBDM1 = mean(BDM1_paired_list.Rank);
    MeanPairedRanksBDM2 = mean(BDM2_paired_list.Rank);
    
    MeanUnpairedRanksBDM1 = mean(BDM1_unpaired_list.Rank);
    MeanUnpairedRanksBDM2 = mean(BDM2_unpaired_list.Rank);
    
    ChangeInRelevantMeanRanking = MeanRelevantRanksBDM1 - MeanRelevantRanksBDM2;
    ChangeInPairedMeanRanking = MeanPairedRanksBDM1 - MeanPairedRanksBDM2;%*
    ChangeInUnpairedMeanRanking = MeanUnpairedRanksBDM1 - MeanUnpairedRanksBDM2;%*
    ChangeInPaired_vs_UnpairedMeanRanking = ChangeInPairedMeanRanking - ChangeInUnpairedMeanRanking;%*
    
    fprintf('\n  ---------------  Ranking (Location) Analysis --------------\n')
    fprintf(' General data:\n')
    fprintf(' mean rank of all relevant contexts (both paired & unpaired): ''before'': %.2f |  ''after'': %.2f  |  change(after - before): %.2f\n', MeanRelevantRanksBDM1, MeanRelevantRanksBDM2, ChangeInRelevantMeanRanking)
    fprintf(' Paired:\n')
    fprintf(' mean rank before: %.2f  |  mean rank after: %.2f  |  change in mean rank: %.2f\n', MeanPairedRanksBDM1, MeanPairedRanksBDM2, ChangeInPairedMeanRanking)
    fprintf(' Unpaired:\n')
    fprintf(' mean rank before: %.2f  |  mean rank after: %.2f  |  change in mean rank: %.2f\n', MeanUnpairedRanksBDM1, MeanUnpairedRanksBDM2, ChangeInUnpairedMeanRanking)
    fprintf(' Paired vs. Unpaired (Paired minus Unpaired):\n')
    fprintf(' difference in mean rank change: %.2f     [ * Here we would like to see positive values... ]\n', ChangeInPaired_vs_UnpairedMeanRanking)
    
    
    %% All The subjects' together data: [matching tables will be formed after the loop]
    %---------------------------------------------
    % BIDS:
    %------------------
    BidsGeneralStatistics(1,:) = {'Subject' 'MeanAllBidsBDM1' 'STD_all_Bids_BDM1' 'MeanAllBidsBDM2' 'STD_all_Bids_BDM2' 'ChangeBetweenMeans'};
    BidsGeneralStatistics{SubjectIndex+1,1} = SubjectsList{SubjectIndex}; % subjects' names
    BidsGeneralStatistics{SubjectIndex+1,2} = MeanAllBidsBDM1;  BidsGeneralStatistics{SubjectIndex+1,3} = STD_all_Bids_BDM1;
    BidsGeneralStatistics{SubjectIndex+1,4} = MeanAllBidsBDM2;  BidsGeneralStatistics{SubjectIndex+1,5} = STD_all_Bids_BDM2;
    BidsGeneralStatistics{SubjectIndex+1,6} = MeanAllBidsBDM2 - MeanAllBidsBDM1;
    
    PairedBidStatistics(1,:) = {'Subject' 'MeanPairedBidsBDM1' 'AverageBidsStandartScoreForPairedBDM1' 'MeanPairedBidsBDM2' 'AverageBidsStandartScoreForPairedBDM2' 'ChangeBetweenMeans' 'DifferenceInBidsStdScorePaired'};
    PairedBidStatistics{SubjectIndex+1,1} = SubjectsList{SubjectIndex}; % subjects' names
    PairedBidStatistics{SubjectIndex+1,2} = MeanPairedBidsBDM1;  PairedBidStatistics{SubjectIndex+1,3} = AverageBidsStandartScoreForPairedBDM1;
    PairedBidStatistics{SubjectIndex+1,4} = MeanPairedBidsBDM2;  PairedBidStatistics{SubjectIndex+1,5} = AverageBidsStandartScoreForPairedBDM2;
    PairedBidStatistics{SubjectIndex+1,6} = ChangeInMeansPairedBids;  PairedBidStatistics{SubjectIndex+1,7} = ChangeInBidsStdScorePaired;
    
    UnpairedBidStatistics(1,:) = {'Subject' 'MeanUnpairedBidsBDM1' 'AverageBidsStandartScoreForUnpairedBDM1' 'MeanUnpairedBidsBDM2' 'AverageBidsStandartScoreForUnpairedBDM2' 'ChangeBetweenMeans' 'DifferenceInBidsStdScoreUnpaired'};
    UnpairedBidStatistics{SubjectIndex+1,1} = SubjectsList{SubjectIndex}; % subjects' names
    UnpairedBidStatistics{SubjectIndex+1,2} = MeanUnpairedBidsBDM1;  UnpairedBidStatistics{SubjectIndex+1,3} = AverageBidsStandartScoreForUnpairedBDM1;
    UnpairedBidStatistics{SubjectIndex+1,4} = MeanUnpairedBidsBDM2;  UnpairedBidStatistics{SubjectIndex+1,5} = AverageBidsStandartScoreForUnpairedBDM2;
    UnpairedBidStatistics{SubjectIndex+1,6} = ChangeInMeansUnpairedBids;  UnpairedBidStatistics{SubjectIndex+1,7} = ChangeInBidsStdScoreUnpaired;
        
    Paired_vs_UnpairedBidStatistics(1,:) = {'Subject' 'difference_in_mean_change' 'difference_in_std_score_change'};
    Paired_vs_UnpairedBidStatistics{SubjectIndex+1,1} = SubjectsList{SubjectIndex}; % subjects' names
    Paired_vs_UnpairedBidStatistics{SubjectIndex+1,2} = ChangeInMeansPairedBids - ChangeInMeansUnpairedBids;
    Paired_vs_UnpairedBidStatistics{SubjectIndex+1,3} = ChangeInBidsStdScorePaired - ChangeInBidsStdScoreUnpaired;

    % for t-test:
    PairedBidsMeanChangeVec(end+1) = ChangeInMeansPairedBids;
    UnpairedBidsMeanChangeVec(end+1) = ChangeInMeansUnpairedBids;
    % for ANOVA:
    MatrixForANOVAbids(SubjectIndex,1) = MeanPairedBidsBDM1; % Before Paired
    MatrixForANOVAbids(SubjectIndex,2) = MeanUnpairedBidsBDM1; % Before Unpaired
    MatrixForANOVAbids(SubjectIndex,3) = MeanPairedBidsBDM2; % After Paired
    MatrixForANOVAbids(SubjectIndex,4) = MeanUnpairedBidsBDM2; % After Unpaired     

    %------------------
    % RANKS:
    %------------------
    AllRankingStatistics(1,:) = {'Subject' 'MeanRankAllRelevant_Before' 'MeanRankAllRelevant_After' 'Change' 'MeanPairedRanksBDM1' 'MeanPairedRanksBDM2' 'ChangeInPairedMeanRanking' 'MeanUnpairedRanksBDM1' 'MeanUnpairedRanksBDM2' 'ChangeInUnpairedMeanRanking' 'difference_in_mean_rank_change'};
    AllRankingStatistics{SubjectIndex+1,1} = SubjectsList{SubjectIndex}; % subjects' names
    AllRankingStatistics{SubjectIndex+1,2} = MeanRelevantRanksBDM1;  AllRankingStatistics{SubjectIndex+1,3} = MeanRelevantRanksBDM2;
    AllRankingStatistics{SubjectIndex+1,4} = MeanRelevantRanksBDM2 - MeanRelevantRanksBDM1;  AllRankingStatistics{SubjectIndex+1,5} = MeanPairedRanksBDM1;
    AllRankingStatistics{SubjectIndex+1,6} = MeanPairedRanksBDM2;  AllRankingStatistics{SubjectIndex+1,7} = ChangeInPairedMeanRanking;
    AllRankingStatistics{SubjectIndex+1,8} = MeanUnpairedRanksBDM1;  AllRankingStatistics{SubjectIndex+1,9} = MeanUnpairedRanksBDM2;
    AllRankingStatistics{SubjectIndex+1,10} = ChangeInUnpairedMeanRanking;  AllRankingStatistics{SubjectIndex+1,11} = ChangeInPaired_vs_UnpairedMeanRanking;

    % for t-test:
    RankingPairedMeanDiffVec(end+1) = ChangeInPairedMeanRanking;
    RankingUnpairedMeanDiffVec(end+1) = ChangeInUnpairedMeanRanking;
 
    %------------------
    % All the subjects data together:
    %------------------
    bid_sorted_all_subjects_BDM1(end+1:end+size(BDM_TABLES{1},1),:) = table2cell(BDM_TABLES{1});
    bid_sorted_all_subjects_BDM2(end+1:end+size(BDM_TABLES{2},1),:) = table2cell(BDM_TABLES{2});
    
end
%% Matching Tables I Can Work With:
%-----------------------------------
%Bids:
%---------
BidsGeneralStatisticsTable = cell2table(BidsGeneralStatistics(2:end,:),'VariableNames',BidsGeneralStatistics(1,:));
PairedBidStatisticsTable = cell2table(PairedBidStatistics(2:end,:),'VariableNames',PairedBidStatistics(1,:));
UnpairedBidStatisticsTable = cell2table(UnpairedBidStatistics(2:end,:),'VariableNames',UnpairedBidStatistics(1,:));
Paired_vs_UnpairedBidStatisticsTable = cell2table(Paired_vs_UnpairedBidStatistics(2:end,:),'VariableNames',Paired_vs_UnpairedBidStatistics(1,:));
%Ranks:
%---------
AllRankingStatisticsTable = cell2table(AllRankingStatistics(2:end,:),'VariableNames',AllRankingStatistics(1,:));
% All subjects' data together:
%---------
bid_sorted_all_subjects_BDM1_Table = cell2table(bid_sorted_all_subjects_BDM1(2:end,:),'VariableNames',BDM_TABLES{1}.Properties.VariableNames);
bid_sorted_all_subjects_BDM2_Table = cell2table(bid_sorted_all_subjects_BDM2(2:end,:),'VariableNames',BDM_TABLES{2}.Properties.VariableNames);
% For ANOVA:
%---------
TableForANOVA_Bids = array2table(MatrixForANOVAbids, 'VariableNames', {'Before_Paired' 'Before_Unpaired' 'After_Paired' 'After_Unpaired'});
%-----------------------------------

% printing:
fprintf('\n  ------------------------------------------- Results N = %d -------------------------------------------\n', length(SubjectsList))
fprintf(' ''Before'' = Auction at the beginning of the experiment (before training)\n')
fprintf(' ''After'' = Auction at the end of the experiment (after training and probe)\n')
fprintf('  ----------------  Bids Analysis -----------------\n')
fprintf(' General data (all stimuli):\n')
fprintf(' mean ''before'': %.2f  mean std. dev: %.2f  |  mean ''after'': %.2f  mean std. dev: %.2f  |  mean change of means(mean after - mean before): %.2f\n', mean(BidsGeneralStatisticsTable.MeanAllBidsBDM1), mean(BidsGeneralStatisticsTable.STD_all_Bids_BDM1), mean(BidsGeneralStatisticsTable.MeanAllBidsBDM2), mean(BidsGeneralStatisticsTable.STD_all_Bids_BDM2), mean(BidsGeneralStatisticsTable.ChangeBetweenMeans) )
fprintf(' Paired:\n')
fprintf(' mean before: %.2f  mean std. score: %.2f  |  mean after: %.2f  mean std. score: %.2f  |  mean change in mean: %.2f  mean change in std. score:%.2f\n', mean(PairedBidStatisticsTable.MeanPairedBidsBDM1), mean(PairedBidStatisticsTable.AverageBidsStandartScoreForPairedBDM1), mean(PairedBidStatisticsTable.MeanPairedBidsBDM2), mean(PairedBidStatisticsTable.AverageBidsStandartScoreForPairedBDM2), mean(PairedBidStatisticsTable.ChangeBetweenMeans), mean(PairedBidStatisticsTable.DifferenceInBidsStdScorePaired))
fprintf(' Unpaired:\n')
fprintf(' mean before: %.2f  mean std. score: %.2f  |  mean after: %.2f  mean std. score: %.2f  |  mean change in mean: %.2f  mean change in std. score:%.2f\n', mean(UnpairedBidStatisticsTable.MeanUnpairedBidsBDM1), mean(UnpairedBidStatisticsTable.AverageBidsStandartScoreForUnpairedBDM1), mean(UnpairedBidStatisticsTable.MeanUnpairedBidsBDM2), mean(UnpairedBidStatisticsTable.AverageBidsStandartScoreForUnpairedBDM2), mean(UnpairedBidStatisticsTable.ChangeBetweenMeans), mean(UnpairedBidStatisticsTable.DifferenceInBidsStdScoreUnpaired))
fprintf(' Paired vs. Unpaired (Paired minus Unpaired):\n')
fprintf(' mean difference in mean change: %.2f   mean difference in std. score change: %.2f      [ * Here we would like to see positive values... ]\n', mean(Paired_vs_UnpairedBidStatisticsTable.difference_in_mean_change), mean(Paired_vs_UnpairedBidStatisticsTable.difference_in_std_score_change))

fprintf('\n  ---------------  Ranking (Location) Analysis --------------\n')
fprintf(' General data:\n')
fprintf(' mean rank of all relevant contexts (both paired & unpaired): ''before'': %.2f |  ''after'': %.2f  |  mean change(after - before): %.2f\n', mean(AllRankingStatisticsTable.MeanRankAllRelevant_Before), mean(AllRankingStatisticsTable.MeanRankAllRelevant_After), mean(AllRankingStatisticsTable.Change))
fprintf(' Paired:\n')
fprintf(' mean rank before: %.2f  |  mean rank after: %.2f  |  mean change in mean rank: %.2f\n', mean(AllRankingStatisticsTable.MeanPairedRanksBDM1), mean(AllRankingStatisticsTable.MeanPairedRanksBDM2), mean(AllRankingStatisticsTable.ChangeInPairedMeanRanking))
fprintf(' Unpaired:\n')
fprintf(' mean rank before: %.2f  |  mean rank after: %.2f  |  mean change in mean rank: %.2f\n', mean(AllRankingStatisticsTable.MeanUnpairedRanksBDM1), mean(AllRankingStatisticsTable.MeanUnpairedRanksBDM2), mean(AllRankingStatisticsTable.ChangeInUnpairedMeanRanking))
fprintf(' Paired vs. Unpaired (Paired minus Unpaired):\n')
fprintf(' mean difference in mean rank change: %.2f     [ * Here we would like to see a positive value... ]\n', mean(AllRankingStatisticsTable.difference_in_mean_rank_change))


PairedBidsMeanChangeVec = PairedBidsMeanChangeVec';
UnpairedBidsMeanChangeVec = UnpairedBidsMeanChangeVec';
[H_bids,P_bids] = ttest(PairedBidsMeanChangeVec,UnpairedBidsMeanChangeVec);
fprintf('\n\n\n     bids p-value = %.4f     [T-Test paired samples]\n', P_bids)


RankingPairedMeanDiffVec = RankingPairedMeanDiffVec';
RankingUnpairedMeanDiffVec = RankingUnpairedMeanDiffVec';
[H_ranks,P_ranks] = ttest(RankingPairedMeanDiffVec,RankingUnpairedMeanDiffVec);
fprintf('\n\n\n     ranks p-value = %.4f     [T-Test paired samples]\n', P_ranks)


end % end function