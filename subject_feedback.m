function subject_feedback(subjectID, outputPath)

% function subject_feedback(subjectID, outputPath)

% based on the function personalDetails(subjectID, order, mainPath)
% This function gets a few personal details from the subject and saves it
% to file named subjectID '_personalDetails' num2str(sessionNum) '.txt'

% get time and date
c = clock;
hr = sprintf('%02d', c(4));
min = sprintf('%02d', c(5));
timestamp = [date,'_',hr,'h',min,'m'];


% open a txt file for the details
fid1 = fopen([outputPath '/' subjectID '_SubjectFeedback_' timestamp '.txt'], 'a');
fprintf(fid1,'subjectID\tdate\tExp. Goal\tTraining Strategy\tProbe Strategy Day 1\tProbe Strategy Day 2\tProbe Strategy Day 3\tProbe strategy change reason\tRecognized winning houses on day 1\tRecognized loosing houses on day 2\tNoticed they are the same houses\tEstimated time precentage looking at screen\tFeeling at the end of 1st day: 1(bad) to 6(good)\tFeeling at the end of 2nd day: 1(bad) to 6(good)\tFeeling at the end of 3rd day: 1(bad) to 6(good)\tParticipation reason\tSucces\tComments\n'); %write the header line

% Telling the subject now we will ask for personal details:
set(groot,'defaultUicontrolFontSize', 20)
questdlg('Next you will be presented with some open questions. Please try to answer as detailed as you can the next questions regarding the experiment.'... '
    ,'Open Questions','Continue','Continue');
WaitSecs(0.5);

%set text size of the dialod box
set(groot,'defaultUicontrolFontSize', 16)
Investigate = myinputdlg('In your opinion, what does this experiment investigate? ','Investigate',1);
Investigate = cell2mat(Investigate);

%set text size of the dialod box
set(groot,'defaultUicontrolFontSize', 16)
TrainingStraregy = myinputdlg('Did you use any strategies in the houses'' exploration parts? ','Houses Exploration Strategy',1);
TrainingStraregy = cell2mat(TrainingStraregy);

%set text size of the dialod box
set(groot,'defaultUicontrolFontSize', 16)
ProbeStrategyDay1 = myinputdlg('What strategies (if any) did you use in the two houses choice part on the 1st day? ','House Choosing Strategy',1);
ProbeStrategyDay1 = cell2mat(ProbeStrategyDay1);

%set text size of the dialod box
set(groot,'defaultUicontrolFontSize', 16)
ProbeStrategyDay2 = myinputdlg('What strategies (if any) did you use in the two houses choice part on the 2nd day? ','House Choosing Strategy',1);
ProbeStrategyDay2 = cell2mat(ProbeStrategyDay2);

%set text size of the dialod box
set(groot,'defaultUicontrolFontSize', 16)
ProbeStrategyDay3 = myinputdlg('What strategies (if any) did you use in the two houses choice part on the 3rd day? ','House Choosing Strategy',1);
ProbeStrategyDay3 = cell2mat(ProbeStrategyDay3);

%set text size of the dialod box
set(groot,'defaultUicontrolFontSize', 16)
ProbeStrategyChange = myinputdlg('If you changed your strategy, why did you? ','Room Choosing Strategy',1);
ProbeStrategyChange = cell2mat(ProbeStrategyChange);

%set text size of the dialod box
set(groot,'defaultUicontrolFontSize', 16)
RecognizeWinningRoomsDay1 = myinputdlg('Did you remember at the end of the exploration which houses were winning houses? ','House Choosing Strategy',1);
RecognizeWinningRoomsDay1 = cell2mat(RecognizeWinningRoomsDay1);

%set text size of the dialod box
set(groot,'defaultUicontrolFontSize', 16)
RecognizeLosingRoomsDay2 = myinputdlg('Did You remembered at the end of the exploration of the 2nd day which rooms were losing rooms? ','Room Choosing Strategy',1);
RecognizeLosingRoomsDay2 = cell2mat(RecognizeLosingRoomsDay2);

%set text size of the dialod box
set(groot,'defaultUicontrolFontSize', 16)
NoticeHappyAndSadRoomAreTheSame = myinputdlg('Did you Noticed they were the same rooms? ','Room Choosing Strategy',1);
NoticeHappyAndSadRoomAreTheSame = cell2mat(NoticeHappyAndSadRoomAreTheSame);

%set text size of the dialod box
set(groot,'defaultUicontrolFontSize', 16)
LookingAtScreen = myinputdlg('Estimate the amount of time you were looking at the screen during the tasks? (Estimate by precenteges)','Watching The Screen',1);
LookingAtScreen = cell2mat(LookingAtScreen);

%set text size of the dialod box
set(groot,'defaultUicontrolFontSize', 16)
Feeling1stDay = myinputdlg('How did you felt at the end of the 1st day on a scale of 1 (very bad) to 6 (very good)? ','Experience',1);
Feeling1stDay = cell2mat(Feeling1stDay);

%set text size of the dialod box
set(groot,'defaultUicontrolFontSize', 16)
Feeling2ndDay = myinputdlg('How did you felt at the end of the 2nd day on a scale of 1 (very bad) to 6 (very good)? ','Experience',1);
Feeling2ndDay = cell2mat(Feeling2ndDay);

%set text size of the dialod box
set(groot,'defaultUicontrolFontSize', 16)
Feeling3rdDay = myinputdlg('How do you feel today on a scale of 1 (very bad) to 6 (very good)? ','Experience',1);
Feeling3rdDay = cell2mat(Feeling3rdDay);

%set text size of the dialod box
set(groot,'defaultUicontrolFontSize', 16)
ParticipationReason = myinputdlg('What is the reason you chose to participate in this study?','Reason of participation',1);
ParticipationReason = cell2mat(ParticipationReason);

%set text size of the dialod box
set(groot,'defaultUicontrolFontSize', 16)
Success = myinputdlg('Do you think you succeeded in the tasks?','Success',1);
Success = cell2mat(Success);

%set text size of the dialod box
set(groot,'defaultUicontrolFontSize', 16)
Comments = myinputdlg('Any comments?','Comments',1);
Comments = cell2mat(Comments);


%% finish this part
%set text size of the dialod box
set(groot,'defaultUicontrolFontSize', 24)
end_part=0;
questdlg('Thank you!! The experiment is over.'... '
    ,'part 3','Continue','Continue');
WaitSecs(1);

% close experiment window, and then start the ranking manually
Screen('CloseAll');
ShowCursor;

% Write details to file
fprintf(fid1,'%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n', subjectID, timestamp, Investigate, TrainingStraregy, ProbeStrategyDay1, ProbeStrategyDay2, ProbeStrategyDay3, ProbeStrategyChange, RecognizeWinningRoomsDay1, RecognizeLosingRoomsDay2, NoticeHappyAndSadRoomAreTheSame, LookingAtScreen, Feeling1stDay, Feeling2ndDay, Feeling3rdDay, ParticipationReason, Success, Comments);
fclose(fid1);
end

