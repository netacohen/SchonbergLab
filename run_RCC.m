function run_RCC(sessionNum,Test)

% function run_RCC()

% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
% ================ by Rani Gera January 2017 ===============
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

% This is the full code to run the full 3 days RCC experiment (Only for the
% NO-Retrieval group)

% This version is a nine contexts version (three reinforced).
% 20 runs in the training sessions. 2 in the probe.
% It is recommended to add one input argument called 'Test' for tests.
% The sessionNum variable stands for the specific day (i.e. day1/day2/day3 in this experiment)

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% % % ---------------- FUNCTIONS REQUIRED TO RUN PROPERLY: ----------------
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% % %   --- RCC codes: ---
% % %   'RCC_BDM'
% % %   'RCC_probe'
% % %   'RCC_recognition'
% % %   'RCC_training'
% % %   'Sort_BDM_RCC'
% % %   'AssignStimuli'
% % %   'Language'
% % %   'personal_details'
% % %   'PressLetterOfTwo'
% % %   'RandomizeRewards'
% % %   'subject_feedback'
% % %   'TravelingSheepSettings'

% % %   --- Other codes: ---
% % %  'CenterText'
% % %  'CopyOutputToDropbox'
% % %  'DoorsAnimationSettings'
% % %  'expsample'
% % %  'mygetnicedialoglocation'
% % %  'myinputdlg'
% % %  'mysetdefaultbutton'
% % %  'Shuffle2'

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% % % ---------------- FOLDERS REQUIRED TO RUN PROPERLY: ------------------
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% % %   'Misc': a folder with some graphic and audio files.
% % %   'Onset_files': a folder with the onset files for the training and
% % %    for the probe.
% % %   'Output': the folder for the output files- results.
% % %   'Stim': with stimuli.

tic
rng shuffle

% get time and date
c = clock;
hr = sprintf('%02d', c(4));
min = sprintf('%02d', c(5));
timestamp = [date,'_',hr,'h',min,'m'];

if nargin < 2
    Test = '';
end
% =========================================================================
%% PARAMETERS
% =========================================================================
RCC_Version = 7; % The experiment version.
ExperimentName = ['RC' num2str(RCC_Version)];% The constant part of the subject ID that indicates the experiment.

% Set number of runs for TRAINING
% -------------------------------------------------
total_num_runs_training_for_first_demo = 2;
total_num_runs_training_for_second_demo = 1;
total_num_runs_training = 20;

% Set number of runs for PROBE
% -------------------------------------------------
NumberOfRoundsForProbeOnDemo = 1;
NumberOfRoundsForProbe = 2;% Define how many full rounds (each round includes all comprisons, one time each pair)

% Set number of runs for REINSTATEMENT
% -------------------------------------------------
total_num_runs_reinstatement = 1;

% Set number of runs for RANDOM HOUSES task
% -------------------------------------------------
total_num_runs_random_houses = 1;

if strcmp(Test,'Test') % put here everything you want to be different in the tests.
    total_num_runs_training = 2;
    ExperimentName = 'TST';
end

% Set the computer and path
% --------------------------
mainPath = pwd;
outputPath = [mainPath '/Output'];

% Language:
ChosenLanguage = 'Hebrew';

% =========================================================================
%% Get input args and check if input is ok
% =========================================================================
% input checkers
IsCorrectSubjectInfo = 'No';
while strcmp(IsCorrectSubjectInfo,'No')
    set(groot,'defaultUicontrolFontSize', 16)
    subjectID = myinputdlg('Subject Number:','Details');
    subjectID = subjectID{1};
    subjectID = [ExperimentName '_'  subjectID];
    [subjectID_num,okID]=str2num(subjectID(end-2:end));
    while okID==0 || subjectID_num>=200 || subjectID_num<=100 || length(subjectID)~=7
        subjectID = myinputdlg('ERROR: Subject code must be between 101 to 199 contain 3 characters numeric ending, e.g "123". Please try again. Subject Number:','Details');
        subjectID = subjectID{1};
        subjectID = [ExperimentName '_' subjectID];
        [subjectID_num,okID]=str2num(subjectID(end-2:end));
    end
    % Group Assigning - N = NON RETRIEVAL GROUP. R = RETRIEVAL GROUP
    %if ~mod(str2double(subjectID(end-1:end)),2)
    %    GroupType = 'R';
    %else
    GroupType = 'N';
    %end
    % Verify all is correct:
    subjectID = [subjectID '_' GroupType];
    IsCorrectSubjectInfo = questdlg(['Is ' subjectID ' correct?'], 'Input Verifyin', 'Yes', 'No', 'No');
end

% Safety checks for correct day input (assessing it using the BDM2 output files)
%-------------------------------------
SubjectOutputFilesFromDaysBefore = dir([outputPath '/' subjectID '*Fractals_BDM2*']);
SubjectOutputFilesFromDaysBefore_Cell = struct2cell(SubjectOutputFilesFromDaysBefore);
WasDay1 = any(~cellfun(@isempty,strfind(SubjectOutputFilesFromDaysBefore_Cell(1,:),'day1')));
WasDay2 = any(~cellfun(@isempty,strfind(SubjectOutputFilesFromDaysBefore_Cell(1,:),'day2')));

if (WasDay2 && sessionNum ~= 3) || (WasDay1 && sessionNum == 1) % i.e. the given session was already conducted by this subject
    IsCorrectSessionNum = questdlg(['WARNING: Subject ' subjectID ' already have output files for day ' num2str(sessionNum)...
        '. Are you sure it is the correct session?                                                      * IF SUBJECT ID IS NOT CORRECT PLEASE PRESS CTRL+C AND OPERATE THE CODE AGAIN.'], 'Session Verifyin', 'Yes', 'No', 'No');
    while strcmp(IsCorrectSessionNum,'No')
        sessionNum = myinputdlg('What is the correct session number (integer between 1 to 3):','Session');
        sessionNum = str2double(sessionNum{1});
        while ~ismember(sessionNum,1:3)
            sessionNum = myinputdlg('ERROR: Session number must be an integer between 1 to 3. Please try again. Session Number:','Session');
            sessionNum = str2double(sessionNum{1});
        end
        IsCorrectSessionNum = questdlg(['Is ' num2str(sessionNum) ' is the correct session?'], 'Input Verifyin', 'Yes', 'No', 'No');
    end
elseif ((~WasDay1 || ~WasDay2) && sessionNum == 3) || (~WasDay1 && sessionNum == 2) % i.e. there is a previous session missing for this subject
    IsCorrectSessionNum = questdlg(['WARNING: Subject ' subjectID ' is missing output previous days.  '...
        'Are you sure it is the correct session?                                                      * IF SUBJECT ID IS NOT CORRECT PLEASE PRESS CTRL+C AND OPERATE THE CODE AGAIN.'], 'Session Verifyin', 'Yes', 'No', 'No');
    while strcmp(IsCorrectSessionNum,'No')
        sessionNum = myinputdlg('What is the correct session number (integer between 1 to 3):','Session');
        sessionNum = str2double(sessionNum{1});
        while ~ismember(sessionNum,1:3)
            sessionNum = myinputdlg('ERROR: Session number must be an integer between 1 to 3. Please try again. Session Number:','Session');
            sessionNum = str2double(sessionNum{1});
        end
        IsCorrectSessionNum = questdlg(['Is ' num2str(sessionNum) ' is the correct session?'], 'Input Verifyin', 'Yes', 'No', 'No');
    end
end

% open a txt file for crashing logs
fid_crash1 = fopen([outputPath '/' subjectID '_crashingLogs_day' num2str(sessionNum) '_' timestamp '.txt'], 'a');
% fprintf(fid_crash,'subjectID\ttraining demo\ttraining\tprobe demo\tprobe\trecognition new old\trecognition go no go\n'); % write the header line

% =========================================================================
%% BDM1 Fractals (contexts):        *including demo
% =========================================================================
if sessionNum == 1
    % Demo:
    crashedBDMfractalsDemo = 0;
    keepTrying = 1;
    while keepTrying < 10
        try
            RCC_BDM(subjectID, sessionNum, ChosenLanguage, 'fractals_BDM_demo')
            keepTrying = 10;
        catch
            sca;
            crashedBDMfractalsDemo = crashedBDMfractalsDemo + 1;
            keepTrying = keepTrying + 1;
            disp('CODE HAD CRASHED - FRACTALS BDM DEMO!');
        end
    end
    fprintf(fid_crash1,'fractals BDM demo crashed:\t %d\n', crashedBDMfractalsDemo);
    
    % Regular:
    crashedBDMfractals = 0;
    keepTrying = 1;
    while keepTrying < 10
        try
            RCC_BDM(subjectID, sessionNum, ChosenLanguage, 'fractals_BDM1')
            keepTrying = 10;
        catch
            sca;
            crashedBDMfractals = crashedBDMfractals + 1;
            keepTrying = keepTrying + 1;
            disp('CODE HAD CRASHED - FRACTALS BDM!');
        end
    end
    fprintf(fid_crash1,'fractals BDM crashed:\t %d\n', crashedBDMfractals);
    
    % =========================================================================
    %% Sorting the BDM list and create the relevant stimuli files for the rest pf the experiment
    % =========================================================================
    Sort_BDM_RCC(subjectID,outputPath,sessionNum,'before')
    
end
% =========================================================================
%% Training Demo / Retrieval / Reinstatement
% =========================================================================
runInd = 1; % The first run to run with the training function

if sessionNum == 1
    crashedDemoTraining = 0;
    keepTrying = 1;
    while keepTrying < 10
        try
            RCC_training(subjectID,mainPath,runInd,total_num_runs_training_for_first_demo,ChosenLanguage,'day1_training_demo');
            keepTrying = 10;
        catch
            sca;
            crashedDemoTraining = crashedDemoTraining + 1;
            keepTrying = keepTrying + 1;
            disp('CODE HAD CRASHED - TRAINING DEMO!');
        end
    end
    fprintf(fid_crash1,'training demo crashed:\t %d\n', crashedDemoTraining);
    
    % Ask if subject wants another demo
    % ----------------------------------
    demo_again = questdlg('Do you want to run the demo again?','Repeat Demo','Yes','No','No');
    if strcmp(demo_again,'Yes')
        crashedDemoAgainTraining = 0;
        keepTrying = 1;
        while keepTrying < 10
            try
                RCC_training(subjectID,mainPath,runInd,total_num_runs_training_for_second_demo,ChosenLanguage,'day1_training_demo');
                keepTrying = 10;
            catch
                sca;
                crashedDemoAgainTraining = crashedDemoAgainTraining + 1;
                keepTrying = keepTrying + 1;
                disp('CODE HAD CRASHED - TRAINING DEMO AGAIN!');
            end
        end
        fprintf(fid_crash1,'training demo again crashed:\t %d\n', crashedDemoAgainTraining);
    end
    
elseif sessionNum == 2 && strcmp(subjectID(9),'R')
    %--------------------------------------
    % This is the RETRIEVAL part which only half of the subjects will conduct.
    %--------------------------------------
    %     crashedDemoTraining = 0;
    %     keepTrying = 1;
    %     while keepTrying < 10
    %         try
    %             day2_training_demo(subjectID, mainPath, ChosenLanguage);
    %             keepTrying = 10;
    %         catch
    %             sca;
    %             crashedDemoTraining = crashedDemoTraining + 1;
    %             keepTrying = keepTrying + 1;
    %             disp('CODE HAD CRASHED - TRAINING DEMO!');
    %         end
    %     end
    %     fprintf(fid_crash1,'Retrieval (training demo) crashed:\t %d\n', crashedDemoTraining);
elseif sessionNum == 3
    %--------------------------------------
    % REINSTATEMENT
    %--------------------------------------
    crashedReinstatement = 0;
    keepTrying = 1;
    while keepTrying < 10
        try
            RCC_training(subjectID,mainPath,runInd,total_num_runs_reinstatement,ChosenLanguage,'day3_reinstatement');
            keepTrying = 10;
        catch
            sca;
            crashedReinstatement = crashedReinstatement + 1;
            keepTrying = keepTrying + 1;
            disp('CODE HAD CRASHED - REINSTATEMENT!');
        end
    end
    fprintf(fid_crash1,'reinstatement crashed:\t %d\n', crashedReinstatement);
end

if sessionNum == 1 || sessionNum == 2
    %--------------------------------------
    % TRAINING
    %--------------------------------------
    crashedTraining = 0;
    keepTrying = 1;
    while keepTrying < 10
        try
            RCC_training(subjectID,mainPath,runInd,total_num_runs_training,ChosenLanguage,['day' num2str(sessionNum) '_training']);
            keepTrying = 10;
        catch
            sca;
            crashedTraining = crashedTraining + 1;
            keepTrying = keepTrying + 1;
            disp('CODE HAD CRASHED - TRAINING!');
        end
    end
    fprintf(fid_crash1,'training crashed:\t %d\n', crashedTraining);
    
    %==========================================================
    %%   'Part 2 - BDM faces'
    %==========================================================
    % This part is used to give a break between the training and probe, to
    % allow consolidation (at least partly).
    % This part is used to get data regarding subjects' liking of other stimuli
    % for the other experiments, such as faces / fractals.
    crashedFacesBDM = 0;
    keepTrying = 1;
    while keepTrying < 10
        try
            RCC_BDM(subjectID, sessionNum, ChosenLanguage, 'faces_BDM');
            keepTrying = 10;
        catch
            sca;
            crashedFacesBDM = crashedFacesBDM + 1;
            keepTrying = keepTrying + 1;
            disp('CODE HAD CRASHED - BDM Faces!');
        end
    end
    fprintf(fid_crash1,'Faces BDM crashed:\t %d\n', crashedFacesBDM);
end
%==========================================================
%%  probe_demo & probe'
%==========================================================

crashedDemoProbe = 0;
keepTrying = 1;
while keepTrying < 10
    try
        RCC_probe(subjectID, mainPath, NumberOfRoundsForProbeOnDemo, ChosenLanguage, ['day' num2str(sessionNum) '_probe_demo']);
        keepTrying = 10;
    catch
        sca;
        crashedDemoProbe = crashedDemoProbe + 1;
        keepTrying = keepTrying + 1;
        disp('CODE HAD CRASHED - PROBE DEMO!');
    end
end
fprintf(fid_crash1,'probe demo crashed:\t %d\n', crashedDemoProbe);

% Ask if subject wanted another demo
% ----------------------------------
demo_again = questdlg('Do you want to run the demo again?','Repeat Demo','Yes','No','No');
if strcmp(demo_again,'Yes')
    crashedDemoAgainProbe = 0;
    keepTrying = 1;
    while keepTrying < 10
        try
            RCC_probe(subjectID, mainPath, NumberOfRoundsForProbeOnDemo, ChosenLanguage, ['day' num2str(sessionNum) '_probe_demo']);
            keepTrying = 10;
        catch
            sca;
            crashedDemoAgainProbe = crashedDemoAgainProbe + 1;
            keepTrying = keepTrying + 1;
            disp('CODE HAD CRASHED - PROBE DEMO AGAIN!');
        end
    end
    fprintf(fid_crash1,'probe demo again crashed:\t %d\n', crashedDemoAgainProbe);
end


crashedProbe = 0;
keepTrying = 1;
while keepTrying < 10
    try
        RCC_probe(subjectID, mainPath, NumberOfRoundsForProbe, ChosenLanguage, ['day' num2str(sessionNum) '_probe']);
        keepTrying=10;
    catch
        sca;
        keepTrying = keepTrying+1;
        crashedProbe = crashedProbe + 1;
        disp('CODE HAD CRASHED - PROBE!');
    end
end
fprintf(fid_crash1,'probe crashed:\t %d\n', crashedProbe);

% =========================================================================
%% BDM2 Fractals (contexts):
% =========================================================================
% Regular:
crashedBDMfractals = 0;
keepTrying = 1;
while keepTrying < 10
    try
        RCC_BDM(subjectID, sessionNum, ChosenLanguage, 'fractals_BDM2')
        keepTrying = 10;
    catch
        sca;
        crashedBDMfractals = crashedBDMfractals + 1;
        keepTrying = keepTrying + 1;
        disp('CODE HAD CRASHED - FRACTALS BDM!');
    end
end
fprintf(fid_crash1,'fractals BDM2 crashed:\t %d\n', crashedBDMfractals);

% =========================================================================
%% Sorting the BDM list and create the relevant stimuli files for the rest pf the experiment
% =========================================================================
Sort_BDM_RCC(subjectID,outputPath,sessionNum,'after')
% =========================================================================

if sessionNum == 3
    % =========================================================================
    %% Personal Detailes
    % =========================================================================
    personal_details(subjectID, outputPath, sessionNum);
    
    % =========================================================================
    %% Recognition (including demo)
    % =========================================================================
    
    crashedDemoRecognition = 0;
    keepTrying = 1;
    while keepTrying < 10
        try
            RCC_recognition(subjectID,mainPath, sessionNum, ChosenLanguage, 'recognition_demo');
            keepTrying = 10;
        catch
            sca;
            crashedDemoRecognition = crashedDemoRecognition + 1;
            keepTrying = keepTrying + 1;
            disp('CODE HAD CRASHED - RECOGNITION DEMO!');
        end
    end
    fprintf(fid_crash1,'recognition demo crashed:\t %d\n', crashedDemoRecognition);
    
    % Ask if subject wanted another demo
    % ----------------------------------
    demo_again = questdlg('Do you want to run the demo again?','Repeat Demo','Yes','No','No');
    if strcmp(demo_again,'Yes')
        crashedDemoAgainRecognition = 0;
        keepTrying = 1;
        while keepTrying < 10
            try
                RCC_recognition(subjectID,mainPath, sessionNum, ChosenLanguage, 'recognition_demo');
                keepTrying = 10;
            catch
                sca;
                crashedDemoAgainRecognition = crashedDemoAgainRecognition + 1;
                keepTrying = keepTrying + 1;
                disp('CODE HAD CRASHED - RECOGNITION DEMO AGAIN!');
            end
        end
        fprintf(fid_crash1,'recognition demo again crashed:\t %d\n', crashedDemoAgainRecognition);
    end
    
    crashedRecognition = 0;
    keepTrying = 1;
    while keepTrying < 10
        try
            RCC_recognition(subjectID,mainPath, sessionNum, ChosenLanguage, 'recognition');
            keepTrying = 10;
        catch
            sca;
            crashedRecognition = crashedRecognition + 1;
            keepTrying = keepTrying + 1;
            disp('CODE HAD CRASHED - RECOGNITION!');
        end
    end
    fprintf(fid_crash1,'recognition crashed:\t %d\n', crashedRecognition);
    
    % =========================================================================
    %% Random (Chosen) Houses
    % =========================================================================
    
    crashedRandomHousesTraining = 0;
    keepTrying = 1;
    while keepTrying < 10
        try
            RCC_training(subjectID,mainPath,runInd,total_num_runs_random_houses,ChosenLanguage,'day3_random_houses');
            keepTrying = 10;
        catch
            sca;
            crashedRandomHousesTraining = crashedRandomHousesTraining + 1;
            keepTrying = keepTrying + 1;
            disp('CODE HAD CRASHED - RANDOM HOUSES!');
        end
    end
    fprintf(fid_crash1,'random houses crashed:\t %d\n', crashedRandomHousesTraining);
    
    %==========================================================
    %%   'Open questions about the experiment'
    %==========================================================
    subject_feedback(subjectID, outputPath);
    %==========================================================
end

fclose(fid_crash1);

CopyOutputToDropbox(subjectID, mainPath, sessionNum);

end % end function

