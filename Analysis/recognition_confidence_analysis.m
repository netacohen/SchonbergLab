function [Recognition_results_table,Recognition_results_table_Means] = recognition_confidence_analysis(Test)


%=========================================================================
%%  PARAMETERS
%=========================================================================
NameOfFiles = ['_recognition_confidence_results_day*.txt']; % The name of the experiment or the file.
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
FilesWithRecognition = dir([outputPath '*recognition_confidence_results*.txt']);
for i = 1:size(FilesWithRecognition,1)
        RelevantSubjetcs(end+1) = str2double(FilesWithRecognition(i).name(5:7));
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

Recognition_results = zeros(length(SubjectsList),40);


for subjectInd = 1:length(SubjectsList)
    recognition_data = readtable([outputPath FilesWithRecognition(subjectInd).name],'Delimiter','\t'); %read in data as new matrix

    isOld = logical(recognition_data.isOld_);
    subjectAnswerOld = zeros(length(recognition_data.subjectAnswerIsOld),1);
    num_missed_isOld = sum(recognition_data.subjectAnswerIsOld==999);
    %subjectAnswerOld(subjectAnswerOld==999) = 3;
    subjectAnswerOld(recognition_data.subjectAnswerIsOld==1 | recognition_data.subjectAnswerIsOld==2) = 1;
    subjectAnswerOld(recognition_data.subjectAnswerIsOld==4 | recognition_data.subjectAnswerIsOld==5) = 0;
    subjectAnswerOld(recognition_data.subjectAnswerIsOld==3 & recognition_data.isOld_==0) = 1;
    subjectAnswerOld(recognition_data.subjectAnswerIsOld==3 & recognition_data.isOld_==1) = 0;
     
    isGo = logical(recognition_data.isGo_);
    subjectAnswerGo = zeros(length(recognition_data.subjectAnswerIsGo),1);
    num_missed_isGo = sum(recognition_data.subjectAnswerIsGo==999);
    %subjectAnswerGo(subjectAnswerGo==999) = 3;
    subjectAnswerGo(recognition_data.subjectAnswerIsGo==1 | recognition_data.subjectAnswerIsGo==2) = 1;
    subjectAnswerGo(recognition_data.subjectAnswerIsGo==4 | recognition_data.subjectAnswerIsGo==5) = 0;
    subjectAnswerGo(recognition_data.subjectAnswerIsGo==3 & recognition_data.isGo_==0) = 1;
    subjectAnswerGo(recognition_data.subjectAnswerIsGo==3 & recognition_data.isGo_==1) = 0;
    
    RT_isOld = recognition_data.RT_isOld;
    RT_isGo = recognition_data.RT_isGo;
    
    isOldCorrectResponse = isOld==subjectAnswerOld;
    isGoCorrectResponse = isGo==subjectAnswerGo;
        
    %% Calculating and making the variables for the table
    % -----------------------------------------------------------
    subject_num(subjectInd,1) = str2double(recognition_data.subjectID{1}(5:7));   
    order(subjectInd,1) = recognition_data.order(1);
    % isOld question
    % - - - - - - - -
    Missed_isOld(subjectInd,1) = num_missed_isOld;
    Percentage_correct_isOld_all(subjectInd,1) = sum(isOldCorrectResponse & subjectAnswerOld~=999)/sum(subjectAnswerOld~=999);
    Mean_RT_isOld_all(subjectInd,1) = mean(RT_isOld(RT_isOld~=999));
    Percentage_correct_isOld_Paired_items(subjectInd,1) = sum(isOldCorrectResponse & isGo & subjectAnswerOld~=999)/sum(isGo & subjectAnswerOld~=999);
    Mean_RT_isOld_Paired_items(subjectInd,1) = mean(RT_isOld(isGo & RT_isOld~=999));
    Percentage_correct_isOld_Unpaired_items(subjectInd,1) = sum(isOldCorrectResponse & isOld & ~isGo & subjectAnswerOld~=999)/sum(isOld & ~isGo & subjectAnswerOld~=999);
    Mean_RT_isOld_Unpaired_items(subjectInd,1) = mean(RT_isOld(isOld & ~isGo & RT_isOld~=999));  
    % isGo question
    % - - - - - - - -
    Missed_isPaired(subjectInd,1) = num_missed_isGo;
    Percentage_correct_isPaired_old_items(subjectInd,1) = sum(isGoCorrectResponse & isOld & subjectAnswerGo~=999)/sum(isOld & subjectAnswerGo~=999);
    Mean_RT_isPaired_old_items(subjectInd,1) = mean(RT_isGo(isOld & RT_isGo~=999));
    Percentage_correct_isPaired_Paired_items(subjectInd,1) = sum(isGoCorrectResponse & isGo & subjectAnswerGo~=999)/sum(isGo & subjectAnswerGo~=999);  
    Mean_RT_isPaired_Paired_items(subjectInd,1) = mean(RT_isGo(isGo & RT_isGo~=999));
    Percentage_correct_isPaired_Unpaired_old_items(subjectInd,1) = sum(isGoCorrectResponse & ~isGo & isOld & subjectAnswerGo~=999)/sum(~isGo & isOld & subjectAnswerGo~=999);  
    Mean_RT_isGo_NoGo_old_items(subjectInd,1) = mean(RT_isGo(~isGo & isOld & RT_isGo~=999));    
      
end % end subject loop

Recognition_results_table = table(subject_num,order,Missed_isOld,Percentage_correct_isOld_all,Mean_RT_isOld_all,Percentage_correct_isOld_Paired_items,...
    Mean_RT_isOld_Paired_items,Percentage_correct_isOld_Unpaired_items,Mean_RT_isOld_Unpaired_items,Missed_isPaired,Percentage_correct_isPaired_old_items,...
    Mean_RT_isPaired_old_items,Percentage_correct_isPaired_Paired_items,Mean_RT_isPaired_Paired_items,Percentage_correct_isPaired_Unpaired_old_items,Mean_RT_isGo_NoGo_old_items);

Recognition_results_table_Means = varfun(@mean,Recognition_results_table);
%fix the names (after 'mean' is added to all the names)
Recognition_results_table_Means.Properties.VariableNames = cellfun(@(x) x(6:end),Recognition_results_table_Means.Properties.VariableNames, 'UniformOutput',false);

% Optional uitable:
uitable(figure,'Data',Recognition_results_table{:,:},'ColumnName',Recognition_results_table.Properties.VariableNames,'Position',[20 20 2000 400])

end % end function

