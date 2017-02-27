function PreliminaryAnalyze

% Initial results:

% * if nothing is written in a subject's feedback it's problematic to use it...

%------------------------------
%% IMPORTANT NOTE %%
% ALL THE PLACES THAT ARE RELEVANT TO CHANGE IF WHEN USING DIFFERENT
% VERSION WILL BE COMMENTED WITH *****
%------------------------------

%Read a subjects probe files day by day
%OutputPath = [pwd '/Output/'];
OutputPath = '/Users/ranigera/Dropbox/experimentsOutput/RCC/Output/';

FilesWithProbe = dir([OutputPath '*probe_*.txt']);

% Relevant files gathering:
RelevantFilesPlacer = 1;
for i = 1:size(FilesWithProbe,1)
    if isempty(strfind(FilesWithProbe(i).name,'block')) && isempty(strfind(FilesWithProbe(i).name,'demo'))
        RelevantFilesForProbeBeforeExclusion(RelevantFilesPlacer) = FilesWithProbe(i);
        RelevantFilesPlacer = RelevantFilesPlacer + 1;
    end
end

%EXCLUDE SUBJECTS
SubjectsToExclude = [101]; % *****      % DEFINE WHICH SUBJECTS TO EXCLUDE % The american group is 101:104;
SubjectsToExclude = [];% ACTIVATE TO SHOW ALL SUBJECTS;
RelevantFilesPlacer = 1;
for i = 1:size(RelevantFilesForProbeBeforeExclusion,2)
    if ~ismember(str2double(RelevantFilesForProbeBeforeExclusion(i).name(5:7)), SubjectsToExclude)
        RelevantFilesForProbe(RelevantFilesPlacer) = RelevantFilesForProbeBeforeExclusion(i);
        RelevantFilesPlacer = RelevantFilesPlacer + 1;
    end
end

%%%%%%%%
%Check if to add some relevant subjects' feedback:
AddFeedback = input('Add subjects'' feedback(y/n)? ', 's');
SubjectsFeedbackFiles = dir([OutputPath '*SubjectFeedback*']);
SubjectPlacer = 0;
%%%%%%%%%
%Initiate a matrixes for summarized data:
DataMatrix = zeros(size(RelevantFilesForProbe,2),5);
%%%%%%%%%
% % initiate learnes and non-learners counters:
% Learners = 0;
% Non_Learners = 0;

for i = 1:size(RelevantFilesForProbe,2)
    fid = fopen([OutputPath RelevantFilesForProbe(i).name],'r');
    Data = textscan(fid, '%s%f%f%f%s%s%f%f%s%f%f%f\n' , 'HeaderLines', 1);     %read in probe output file into Data ;
    fclose(fid);
    ProbeOutcomes=Data{1,11}; % *****
    %Variables for presentation:
    Subject = Data{1,1}{1}(1:7);
    day = str2double(RelevantFilesForProbe(i).name(14));
    AmountSelectedPairdRooms = sum(ProbeOutcomes==1);
    AmountSelectedUnPaireddRooms = sum(ProbeOutcomes==0);
    ValidRelevantSelections = AmountSelectedPairdRooms + AmountSelectedUnPaireddRooms; % out of 54 on the specific experiment
    PercentageSelectedPairedRooms = AmountSelectedPairdRooms/ValidRelevantSelections*100;
    PercentageSelectedUnPairedRooms = AmountSelectedUnPaireddRooms/ValidRelevantSelections*100;
    % Fill the data matrix:
    DataMatrix(i,1) = str2double(Subject(5:7));
    DataMatrix(i,2) = day;
    DataMatrix(i,3) = AmountSelectedPairdRooms;
    DataMatrix(i,4) = AmountSelectedUnPaireddRooms;
    DataMatrix(i,5) = ValidRelevantSelections;
    % Drawing the results:
    if i == 1 || ~strcmp(RelevantFilesForProbe(i).name(5:7),RelevantFilesForProbe(i-1).name(5:7))
    fprintf('\n  -------------------------------------------  %s  -------------------------------------------\n', Subject)
    end
    fprintf('|  day   Selected Paired   Selected Unpaired   Total Valid Selections   Per. Paired   Per. Unpaired\n')
    fprintf('|   %d          %.0f                 %.0f                    %.0f                %.2f%%         %.2f%%   \n', day, AmountSelectedPairdRooms, AmountSelectedUnPaireddRooms, ValidRelevantSelections, PercentageSelectedPairedRooms, PercentageSelectedUnPairedRooms);
    if strcmpi(AddFeedback, 'y')
        if ~isempty(strfind(RelevantFilesForProbe(i).name,'day1')) %*****    %&& (i == size(RelevantFilesForProbe,2) || ~strcmp(RelevantFilesForProbe(i).name(5:7),RelevantFilesForProbe(i+1).name(5:7)))
            SubjectPlacer = SubjectPlacer + 1;
            fidFeedback = fopen([OutputPath SubjectsFeedbackFiles(SubjectPlacer).name],'r');
            FeedbackData = textscan(fidFeedback, '%s%s%s%s%s%s%s%s%s%s%s\n' , 'HeaderLines', 0,'Whitespace' , '\t');% *****     %read in probe output file into Data ;
            fclose(fidFeedback);
            fprintf('|  ~~~~~ ~~~~~ ~~~~~ Subject''s Feedback: ~~~~~ ~~~~~ ~~~~~  \n')
            fprintf('|  %s - %s\n', FeedbackData{5}{1}, FeedbackData{5}{2})
            fprintf('|  %s - %s\n', FeedbackData{6}{1}, FeedbackData{6}{2})
            fprintf('|  %s - %s\n', FeedbackData{7}{1}, FeedbackData{7}{2})
            fprintf('|  %s - %s\n', FeedbackData{9}{1}, FeedbackData{9}{2})
            fprintf('|  %s - %s\n', FeedbackData{10}{1}, FeedbackData{10}{2})
            fprintf('|  %s - %s\n', FeedbackData{11}{1}, FeedbackData{11}{2})
            fprintf('  ---------------------------------------------------------------------------------------------------\n')
        end
    end
    
%    %NEW ADDITION: Made to create learners precentage.
%     switch day
%         case 1
%             if PercentageSelectedPairedRooms > 65
%                 Learners = Learners + 1;
%             else
%                 Non_Learners = Non_Learners + 1;
%             end
%         case 2
%             
%         case 3
%     end
end

%Check which data to include in the total data presentation:
RelevantSubjects = DataMatrix(DataMatrix(:,2) == 3); 
RelevantSubjects = DataMatrix(DataMatrix(:,2) == 1); % *****     % Enables TO GET NOT ONLY
%THE DATA OF THOSE WHO COMPLETED EVERYTHING.
RelevantDataMatrix = DataMatrix(ismember(DataMatrix(:,1),RelevantSubjects),:);
RetrievalGroupMatrix = RelevantDataMatrix(RelevantDataMatrix(:,1) > 200 & RelevantDataMatrix(:,1) < 300 ,:);
NoRetrievalGroupMatrix = RelevantDataMatrix(RelevantDataMatrix(:,1) > 100 & RelevantDataMatrix(:,1) < 200 ,:);

%%%%% Gathering the information In a more accurate Way (I added this
%%%%% part later)
%Retrieval:
NewRetrievalDay1 = RetrievalGroupMatrix(RetrievalGroupMatrix(:,2) == 1, 3:5);
MeanPairedRetrievalDay1ForEach = NewRetrievalDay1(:,1) ./ NewRetrievalDay1(:,3);
%MeanUnpairedRetrievalDay1ForEach = NewRetrievalDay1(:,2) ./ NewRetrievalDay1(:,3);
MeanPairedRetrievalDay1 = mean(MeanPairedRetrievalDay1ForEach);
StdErrorRetrievalDay1 = std(MeanPairedRetrievalDay1ForEach)/sqrt(length(MeanPairedRetrievalDay1ForEach));

NewRetrievalDay2 = RetrievalGroupMatrix(RetrievalGroupMatrix(:,2) == 2, 3:5);
MeanPairedRetrievalDay2ForEach = NewRetrievalDay2(:,1) ./ NewRetrievalDay2(:,3);
%MeanUnpairedRetrievalDay2ForEach = NewRetrievalDay2(:,2) ./ NewRetrievalDay2(:,3);
MeanPairedRetrievalDay2 = mean(MeanPairedRetrievalDay2ForEach);
StdErrorRetrievalDay2 = std(MeanPairedRetrievalDay2ForEach)/sqrt(length(MeanPairedRetrievalDay2ForEach));

NewRetrievalDay3 = RetrievalGroupMatrix(RetrievalGroupMatrix(:,2) == 3, 3:5);
MeanPairedRetrievalDay3ForEach = NewRetrievalDay3(:,1) ./ NewRetrievalDay3(:,3);
%MeanUnpairedRetrievalDay3ForEach = NewRetrievalDay3(:,2) ./ NewRetrievalDay3(:,3);
MeanPairedRetrievalDay3 = mean(MeanPairedRetrievalDay3ForEach);
StdErrorRetrievalDay3 = std(MeanPairedRetrievalDay3ForEach)/sqrt(length(MeanPairedRetrievalDay3ForEach));

%No Retrieval:

NewNoRetrievalDay1 = NoRetrievalGroupMatrix(NoRetrievalGroupMatrix(:,2) == 1, 3:5);
MeanPairedNoRetrievalDay1ForEach = NewNoRetrievalDay1(:,1) ./ NewNoRetrievalDay1(:,3);
%MeanUnpairedNoRetrievalDay1ForEach = NewNoRetrievalDay1(:,2) ./ NewNoRetrievalDay1(:,3);
MeanPairedNoRetrievalDay1 = mean(MeanPairedNoRetrievalDay1ForEach);
StdErrorNoRetrievalDay1 = std(MeanPairedNoRetrievalDay1ForEach)/sqrt(length(MeanPairedNoRetrievalDay1ForEach));

NewNoRetrievalDay2 = NoRetrievalGroupMatrix(NoRetrievalGroupMatrix(:,2) == 2, 3:5);
MeanPairedNoRetrievalDay2ForEach = NewNoRetrievalDay2(:,1) ./ NewNoRetrievalDay2(:,3);
%MeanUnpairedNoRetrievalDay2ForEach = NewNoRetrievalDay2(:,2) ./ NewNoRetrievalDay2(:,3);
MeanPairedNoRetrievalDay2 = mean(MeanPairedNoRetrievalDay2ForEach);
StdErrorNoRetrievalDay2 = std(MeanPairedNoRetrievalDay2ForEach)/sqrt(length(MeanPairedNoRetrievalDay2ForEach));

NewNoRetrievalDay3 = NoRetrievalGroupMatrix(NoRetrievalGroupMatrix(:,2) == 3, 3:5);
MeanPairedNoRetrievalDay3ForEach = NewNoRetrievalDay3(:,1) ./ NewNoRetrievalDay3(:,3);
%MeanUnpairedNoRetrievalDay3ForEach = NewNoRetrievalDay3(:,2) ./ NewNoRetrievalDay3(:,3);
MeanPairedNoRetrievalDay3 = mean(MeanPairedNoRetrievalDay3ForEach);
StdErrorNoRetrievalDay3 = std(MeanPairedNoRetrievalDay3ForEach)/sqrt(length(MeanPairedNoRetrievalDay3ForEach));

%%%%%
RetrievalDay1 = sum(RetrievalGroupMatrix(RetrievalGroupMatrix(:,2) == 1, 3:5),1);
RetrievalDay2 = sum(RetrievalGroupMatrix(RetrievalGroupMatrix(:,2) == 2, 3:5),1);
RetrievalDay3 = sum(RetrievalGroupMatrix(RetrievalGroupMatrix(:,2) == 3, 3:5),1);
RetrievalDay1(4:5) = RetrievalDay1(1:2)/RetrievalDay1(3)*100;
RetrievalDay2(4:5) = RetrievalDay2(1:2)/RetrievalDay2(3)*100;
RetrievalDay3(4:5) = RetrievalDay3(1:2)/RetrievalDay3(3)*100;
NoRetrievalDay1 = sum(NoRetrievalGroupMatrix(NoRetrievalGroupMatrix(:,2) == 1, 3:5),1);
NoRetrievalDay2 = sum(NoRetrievalGroupMatrix(NoRetrievalGroupMatrix(:,2) == 2, 3:5),1);
NoRetrievalDay3 = sum(NoRetrievalGroupMatrix(NoRetrievalGroupMatrix(:,2) == 3, 3:5),1);
NoRetrievalDay1(4:5) = NoRetrievalDay1(1:2)/NoRetrievalDay1(3)*100;
NoRetrievalDay2(4:5) = NoRetrievalDay2(1:2)/NoRetrievalDay2(3)*100;
NoRetrievalDay3(4:5) = NoRetrievalDay3(1:2)/NoRetrievalDay3(3)*100;

fprintf('\n\n  -------------------------------------------   Total   -------------------------------------------\n')
fprintf('  ----------------------------------   No Retrieval Group N = %d  ----------------------------------\n', sum(mod(RelevantSubjects,2) == 1))
fprintf('|  day   Selected Paired   Selected Unpaired   Total Valid Selections   Mean (Paired)   Std. Error\n')
fprintf('|   1          %.0f                 %.0f                    %.0f                %.2f         %.2f   \n', NoRetrievalDay1(1:3), MeanPairedNoRetrievalDay1, StdErrorNoRetrievalDay1);
fprintf('|  day   Selected Paired   Selected Unpaired   Total Valid Selections   Mean (Paired)   Std. Error\n')
fprintf('|   2          %.0f                 %.0f                    %.0f                %.2f         %.2f   \n', NoRetrievalDay2(1:3), MeanPairedNoRetrievalDay2, StdErrorNoRetrievalDay2);
fprintf('|  day   Selected Paired   Selected Unpaired   Total Valid Selections   Mean (Paired)   Std. Error\n')
fprintf('|   3          %.0f                 %.0f                    %.0f                %.2f         %.2f   \n', NoRetrievalDay3(1:3), MeanPairedNoRetrievalDay3, StdErrorNoRetrievalDay3);
fprintf('  ------------------------------------   Retrieval Group N = %d  ------------------------------------\n', sum(mod(RelevantSubjects,2) == 0))
fprintf('|  day   Selected Paired   Selected Unpaired   Total Valid Selections   Mean (Paired)   Std. Error\n')
fprintf('|   1          %.0f                 %.0f                    %.0f                %.2f         %.2f   \n', RetrievalDay1(1:3), MeanPairedRetrievalDay1, StdErrorRetrievalDay1);
fprintf('|  day   Selected Paired   Selected Unpaired   Total Valid Selections   Mean (Paired)   Std. Error\n')
fprintf('|   2          %.0f                 %.0f                    %.0f                %.2f         %.2f   \n', RetrievalDay2(1:3), MeanPairedRetrievalDay2, StdErrorRetrievalDay2);
fprintf('|  day   Selected Paired   Selected Unpaired   Total Valid Selections   Mean (Paired)   Std. Error\n')
fprintf('|   3          %.0f                 %.0f                    %.0f                %.2f         %.2f   \n', RetrievalDay3(1:3), MeanPairedRetrievalDay3, StdErrorRetrievalDay3);

%All Together:
AllTogetherDay1 = RetrievalDay1(1:3) + NoRetrievalDay1(1:3);
AllTogetherDay1(4) = AllTogetherDay1(1)/AllTogetherDay1(3)*100;
AllTogetherDay1(5) = AllTogetherDay1(2)/AllTogetherDay1(3)*100;
AllTogetherDay2 = RetrievalDay2(1:3) + NoRetrievalDay2(1:3);
AllTogetherDay2(4) = AllTogetherDay2(1)/AllTogetherDay2(3)*100;
AllTogetherDay2(5) = AllTogetherDay2(2)/AllTogetherDay2(3)*100;
AllTogetherDay3 = RetrievalDay3(1:3) + NoRetrievalDay3(1:3);
AllTogetherDay3(4) = AllTogetherDay3(1)/AllTogetherDay3(3)*100;
AllTogetherDay3(5) = AllTogetherDay3(2)/AllTogetherDay3(3)*100;

%%%%% Gathering The Information In a New More Correct Way (I have added this
%%%%% part later)
NewAllTogetherDay1 = [RetrievalGroupMatrix(RetrievalGroupMatrix(:,2) == 1, 3:5) ; NoRetrievalGroupMatrix(NoRetrievalGroupMatrix(:,2) == 1, 3:5)];
MeanPairedAllTogetherDay1ForEach = NewAllTogetherDay1(:,1) ./ NewAllTogetherDay1(:,3);
%MeanUnpairedAllTogetherDay1ForEach = NewAllTogetherDay1(:,2) ./ NewAllTogetherDay1(:,3);
MeanPairedAllTogetherDay1 = mean(MeanPairedAllTogetherDay1ForEach);
StdErrorAllTogetherDay1 = std(MeanPairedAllTogetherDay1ForEach)/sqrt(length(MeanPairedAllTogetherDay1ForEach));

NewAllTogetherDay2 = [RetrievalGroupMatrix(RetrievalGroupMatrix(:,2) == 2, 3:5) ; NoRetrievalGroupMatrix(NoRetrievalGroupMatrix(:,2) == 2, 3:5)];
MeanPairedAllTogetherDay2ForEach = NewAllTogetherDay2(:,1) ./ NewAllTogetherDay2(:,3);
%MeanUnpairedAllTogetherDay2ForEach = NewAllTogetherDay2(:,2) ./ NewAllTogetherDay2(:,3);
MeanPairedAllTogetherDay2 = mean(MeanPairedAllTogetherDay2ForEach);
StdErrorAllTogetherDay2 = std(MeanPairedAllTogetherDay2ForEach)/sqrt(length(MeanPairedAllTogetherDay2ForEach));

NewAllTogetherDay3 = [RetrievalGroupMatrix(RetrievalGroupMatrix(:,2) == 3, 3:5) ; NoRetrievalGroupMatrix(NoRetrievalGroupMatrix(:,2) == 3, 3:5)];
MeanPairedAllTogetherDay3ForEach = NewAllTogetherDay3(:,1) ./ NewAllTogetherDay3(:,3);
%MeanUnpairedAllTogetherDay3ForEach = NewAllTogetherDay3(:,2) ./ NewAllTogetherDay3(:,3);
MeanPairedAllTogetherDay3 = mean(MeanPairedAllTogetherDay3ForEach);
StdErrorAllTogetherDay3 = std(MeanPairedAllTogetherDay3ForEach)/sqrt(length(MeanPairedAllTogetherDay3ForEach));

%%%%%


fprintf('\n\n  ---------------------------------------   All Together   ---------------------------------------\n')
fprintf('  -------------------------------------------   N = %d  -------------------------------------------\n', size(RelevantSubjects,1));
fprintf('|  day   Selected Paired   Selected Unpaired   Total Valid Selections   Mean (Paired)   Std. Error\n')
fprintf('|   1          %.0f                 %.0f                    %.0f                %.2f         %.2f   \n', AllTogetherDay1(1:3), MeanPairedAllTogetherDay1, StdErrorAllTogetherDay1);
fprintf('|  day   Selected Paired   Selected Unpaired   Total Valid Selections   Mean (Paired)   Std. Error\n')
fprintf('|   2          %.0f                 %.0f                    %.0f                %.2f         %.2f   \n', AllTogetherDay2(1:3), MeanPairedAllTogetherDay2, StdErrorAllTogetherDay2);
fprintf('|  day   Selected Paired   Selected Unpaired   Total Valid Selections   Mean (Paired)   Std. Error\n')
fprintf('|   3          %.0f                 %.0f                    %.0f                %.2f         %.2f   \n', AllTogetherDay3(1:3), MeanPairedAllTogetherDay3, StdErrorAllTogetherDay3);

%fprintf('* Learners Per. = %.2f%%\n', Learners/(Learners+Non_Learners)*100);

%print saubject's name, day, number of choosing the relvant, number of
%choosing the no relevant, number of no choosing in relevant comparisons.
%precentege of relevan from total valid relevant choices, same for the
%unrelevant choices

%% FIGURES:

%Figure for every subject
for i = 1:length(RelevantSubjects)
    NumRelevantDaysForSubject = sum(RelevantDataMatrix(:,1)==RelevantSubjects(i));
    DataForSubject = RelevantDataMatrix(RelevantDataMatrix(:,1)==RelevantSubjects(i),:);
    figure
    b = bar(1:NumRelevantDaysForSubject, DataForSubject(:,3)./DataForSubject(:,5)*100,0.5);
    ylim([0 100])
    title(['Subject: ' num2str(RelevantSubjects(i))],'FontSize',15)
    xlabel('Day','FontSize',15)
    ylabel('Chosen Paired Stimuli (per.)','FontSize',15)
    hold on
    p = plot(1:NumRelevantDaysForSubject, DataForSubject(:,3)./DataForSubject(:,5)*100, 'r*-');
    p.LineWidth = 3;
    b.FaceColor = [ 0 0.447 0.741];
    plot(xlim,[50 50], 'k--')
    set(gca,'YGrid','on')
    set(gca,'GridLineStyle','-')
end

% Set the figure of all together means and error bars
figure
MeansAllMatrix = [MeanPairedAllTogetherDay1 MeanPairedAllTogetherDay2 MeanPairedAllTogetherDay3];
StdErrorsAll = [StdErrorAllTogetherDay1 StdErrorAllTogetherDay2 StdErrorAllTogetherDay3];
bar(MeansAllMatrix);
ylim([0 1])
title(['Retrieval CC All Subjects Together  N=' num2str(length(RelevantSubjects))],'FontSize',15)
xlabel('Day','FontSize',15)
ylabel('Mean Chosen Paired Stimuli (per.)','FontSize',15)
hold on
plot(xlim,[0.5 0.5], 'k--')
Labels = {'1', '2', '3'};
set(gca, 'XTick', 1:4, 'XTickLabel', Labels,'FontSize',15);
set(gca,'YGrid','on')
set(gca,'GridLineStyle','-')
% Set the error bars
errorbar(MeansAllMatrix, StdErrorsAll, 'k', 'linestyle', 'none');

% Set the main figure  - means and error bars
figure
MeansMatrix = [MeanPairedNoRetrievalDay1 MeanPairedRetrievalDay1 ;MeanPairedNoRetrievalDay2 MeanPairedRetrievalDay2, ;MeanPairedNoRetrievalDay3 MeanPairedRetrievalDay3];
StdErrors = [StdErrorNoRetrievalDay1 StdErrorRetrievalDay1;StdErrorNoRetrievalDay2 StdErrorRetrievalDay2;StdErrorNoRetrievalDay3 StdErrorRetrievalDay3];
bar(MeansMatrix);
ylim([0 1])
title(['Retrieval CC Results  N=' num2str(length(RelevantSubjects))],'FontSize',15)
xlabel('Day','FontSize',15)
ylabel('Mean Chosen Paired Stimuli (per.)','FontSize',15)
hold on
plot(xlim,[0.5 0.5], 'k--')
Labels = {'1', '2', '3'};
set(gca, 'XTick', 1:4, 'XTickLabel', Labels,'FontSize',15);
legend(['No Retrieval  N=' num2str(sum(mod(RelevantSubjects,2) == 1))], ['Retrieval  N=' num2str(sum(mod(RelevantSubjects,2) == 0))])
set(gca,'YGrid','on')
set(gca,'GridLineStyle','-')
% Set the error bars
numgroups = size(MeansMatrix, 1);
numbars = size(MeansMatrix, 2);
groupwidth = min(0.8, numbars/(numbars+1.5));
for i = 1:numbars
    % Based on barweb.m by Bolu Ajiboye from MATLAB File Exchange
    x = (1:numgroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*numbars);  % Aligning error bar with individual bar
    errorbar(x, MeansMatrix(:,i), StdErrors(:,i), 'k', 'linestyle', 'none');
end


end 
