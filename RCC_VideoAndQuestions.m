function [] = RCC_VideoAndQuestions(subjectID, mainPath)

% function [] = VideoAndQuestions(subjectID, mainPath, ChosenLanguage, Kind)
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
% ==================== by Rani Gera February 2017 ====================
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
% This function plays a movie and questions about it will appear on a
% pre-determined schedule while the movie keeps playing.
% For maximum control there are two experimenter keys.
% 'Z' will enable to begin after a blank screen will appear and to go back
% to matlab desktop after the task is finished.
% During the movie a sequence of 'Z' and then 'Q' will stop the movie and
% the code will go further to end of the task.
% * Letter's upper/lawer cases is irrelevant.
%
% Required functions and files:
% QuestionsForVideo.m
% CopyOutputToDropbox.m
%
% The function will create an output txt file and a mat file containing the
% variables and a struct array with the run general info.
%
tic

rng shuffle

%---------------------------------------------------------
%%  'SCRIPT VERSION'
%---------------------------------------------------------
script_name = 'Retrieval_CC';
script_version='7';
revision_date='02-2017';
fprintf('%s %s (revised %s)\n',script_name,script_version,revision_date);

%---------------------------------------------------------------
%%   'GLOBAL VARIABLES'
%---------------------------------------------------------------
%   'timestamp'
% - - - - - - - - - - - - - - - - -
c = clock;
hr = sprintf('%02d', c(4));
minutes = sprintf('%02d', c(5));
timestamp = [date,'_',hr,'h',minutes,'m'];

% For the No-Retrieval group (that conduct this task on the laptop):
[~,specific_computer] = system('hostname');
if ~isempty(strfind(specific_computer,'Pro')) %i.e. if it is the macbook-pro
    ExperimentName = 'RCC';
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
    
    mainPath = pwd;
end

outputPath = [mainPath '/Output'];
% -----------------------------------------------
%% 'INITIALIZE SCREEN'
%---------------------------------------------------------------
Screen('Preference', 'VisualDebuglevel', 3); %No PTB intro screen
screennum = min(Screen('Screens'));
pixelSize=32;
%[w] = Screen('OpenWindow',screennum,[],[0 0 640 480],pixelSize);% %debugging screensize%
[w] = Screen('OpenWindow',screennum,[],[],pixelSize);
% Get the size of the on screen window
[screenXpixels, screenYpixels] = Screen('WindowSize', w);
% Set up alpha-blending
Screen('BlendFunction', w, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
%   colors
% - - - - - -
black = BlackIndex(w); % Should equal 0.
white = WhiteIndex(w); % Should equal 255.

Screen('FillRect', w, black);
Screen('Flip', w);

WaitSecs(1);
HideCursor;

%---------------------------------------------------------------
%%  PARAMETERS
%---------------------------------------------------------------
% Control Keys:
ExperimenterControlKey = 'Z';
SecondExperimenterControlKey = 'Q';

% Movie:
MovieFolderAndName = '/Misc/Video/PlanetEarthMountains';
if ~isempty(strfind(specific_computer,'Pro')) %i.e. if it is the macbook-pro
    MovieScaleFactor = 0.92;
else
    MovieScaleFactor = 1.1;
end
DistanceFromTopOnY = screenYpixels * 0.05;

% 'Assign response keys'
%------------------------
KbName('UnifyKeyNames');
key1 = '1';
key2 = '2';
key3 = '3';

% About questions in the video:
QuestionsOnsetVector = [29 80 108 175 231 345 372 390 415 460 496 542 572 597 619];
TimeForQuestion = 10;

% output file name:
OutputFileName = 'day2_video';
% day/session:
DayOfExperiment = 2;

%   text
% - - - - - -
if ~isempty(strfind(specific_computer,'Pro')) %i.e. if it is the macbook-pro
    TextSizeScaleFactore = 0.8182;
else
    TextSizeScaleFactore = 1;
end

theFont = 'Arial';
Screen('TextSize',w,round(40*TextSizeScaleFactore));
Screen('TextFont',w,theFont);
Screen('TextColor',w,white);
%---------------------------------------------------------------
%% SETTINGS:
%---------------------------------------------------------------
% Loading questions and answers:
[QuestionsText,AnswersText, Instructions, FinalMessage] = QuestionsForVideo;
AnswersInd = cell(size(AnswersText));
% Shuffle the answers:
for i = 1:length(AnswersText)
    [AnswersText{i},AnswersInd{i}] = Shuffle(AnswersText{i});
end
CorrectAnswers = cellfun(@(x) find(x==1),AnswersInd)'; % because the right answer where set to be the first one in the text initiation.
% Extracting number of optional answers for each question. * The code is adapted to a constant number of answers to all the questions.
NumOfOptionalAnswers = length(AnswersText{1});

% Loading movie file
MovieLocation = dir([mainPath MovieFolderAndName '*']);
% Open the movie:
[Movie,duration,~,Width,Height] = Screen('OpenMovie', w,[mainPath '/Misc/Video/' MovieLocation.name]); %[Movie,duration,fps,width,height] = Screen('OpenMovie', w,[mainPath '/Misc/Video/' MovieLocation.name])

% Initialyze the variables to collect data:
QuestionsAmount = length(QuestionsOnsetVector);
AnswerRT = zeros(QuestionsAmount ,1);
SubjectAnswers = zeros(QuestionsAmount ,1);
QuestionOnsets = zeros(QuestionsAmount ,1);

% Movie and Question Placers and Scaling:
ScaledWidth = Width * MovieScaleFactor;
ScaledHeight = Height * MovieScaleFactor;
MovieConstantLocatorOnX = (screenXpixels-ScaledWidth)/2;
MovieRectangle =[MovieConstantLocatorOnX DistanceFromTopOnY ScaledWidth+MovieConstantLocatorOnX ScaledHeight+DistanceFromTopOnY]; % Change to an empty vec to make it the original size and in the middle of the screen.
PositioningForChoicesTextOnY = round(linspace(0.9 * screenYpixels, 0.98 * screenYpixels, NumOfOptionalAnswers));

%---------------------------------------------------------------
%% experimenter control key before starting
%---------------------------------------------------------------

UnCorrectResponse=1;
while UnCorrectResponse
    [IsPressed,~,KeyCode] = KbCheck;
    KeyPressed = KbName(KeyCode);
    if strcmpi(KeyPressed, ExperimenterControlKey)
        UnCorrectResponse=0;
    end;
end;
while IsPressed
    [IsPressed,~,~] = KbCheck;
end
WaitSecs(0.001);

%---------------------------------------------------------------
%% 'Display Main Instructions'
%---------------------------------------------------------------

Screen('TextSize',w, round(60*TextSizeScaleFactore));
Screen('TextStyle',w ,1);
DrawFormattedText(w, Instructions{1} , 'center', screenYpixels*0.15, [50 255 50])
Screen('TextSize',w, round(40*TextSizeScaleFactore));
Screen('TextStyle',w ,1);
DrawFormattedText(w, Instructions{2} , 'center', screenYpixels*0.30, [255 255 255],  0, 0, 0, 1.2)
Screen('TextStyle',w ,0);
DrawFormattedText(w, Instructions{3} , 'center', screenYpixels*0.90, [255 255 255],  0, 0, 0, 1.2)
Screen('TextStyle',w ,1);
Screen(w,'Flip');

Screen('TextSize',w,round(40*TextSizeScaleFactore)); % return to normal size

noResponse=1;
while noResponse
    [keyIsDown,~,~] = KbCheck;
    if keyIsDown && noResponse
        noResponse=0;
    end;
end;
WaitSecs(0.001);

%---------------------------------------------------------------
%%  'Play the movie'
%---------------------------------------------------------------
Screen('PlayMovie', Movie, 1, 0, 1)
% Get the start time:
MovieStartTime = GetSecs();
% Initiating variables:
QuestionNum = 1;
ColoringFlag = 0;
QuestionOnsetFlag = 1;
WasControllKey1Pressed = 1;
WasControllKey2Pressed = 1;
while GetSecs - MovieStartTime <= duration && (WasControllKey1Pressed || WasControllKey2Pressed)
    % Get the texture:
    MovieTexture = Screen('GetMovieImage', w, Movie);
    % Draw the texture:
    Screen('DrawTexture',w , MovieTexture, [] , MovieRectangle);
    Screen('Flip',w);
    % Discard the texture:
    Screen('Close', MovieTexture);
    
    %Check responses
    [keyIsDown,~,KeyCode] = KbCheck;
    KeyPressed = KbName(KeyCode);
    if iscell(KeyPressed)
        KeyPressed = KeyPressed{1}(1);
    elseif ~isempty(KeyPressed)
        KeyPressed = KeyPressed(1);
    end
    % Add questions:
    if GetSecs - MovieStartTime > QuestionsOnsetVector(QuestionNum) && GetSecs - MovieStartTime < QuestionsOnsetVector(QuestionNum) + TimeForQuestion
        if QuestionOnsetFlag
            QuestionOnsets(QuestionNum) = GetSecs - MovieStartTime;
            QuestionOnsetFlag = 0;
        end
        DrawFormattedText(w, QuestionsText{QuestionNum} , 'right', screenYpixels*0.85, [50 255 50],[],[],[],[],[],[0 0 screenXpixels*0.7 screenYpixels]);
        for i = 1:length(AnswersText{1})
            DrawFormattedText(w,[double(num2str(i)) double('. ') AnswersText{QuestionNum}{i}], 'right',PositioningForChoicesTextOnY(i),[255 255 255],[],[],[],[],[],[0 0 screenXpixels*0.7 screenYpixels]);
        end
        if (keyIsDown && (KeyPressed==key1||KeyPressed==key2||KeyPressed==key3)) || ColoringFlag % A valid response is only 1,2,3,4 or 5
            if ~ColoringFlag % i.e. it's the first time in this 'if'
                SubjectAnswers(QuestionNum) = str2double(KeyPressed);
                AnswerRT(QuestionNum) = GetSecs - MovieStartTime - QuestionsOnsetVector(QuestionNum);
                LastKeyPressed = KeyPressed;
            end
            for i = 1:length(AnswersText{1})
                if i == str2double(LastKeyPressed) %The choice to highlight
                    DrawFormattedText(w,[double(num2str(i)) double('. ') AnswersText{QuestionNum}{i}], 'right' ,PositioningForChoicesTextOnY(i),[50 255 50],[],[],[],[],[],[0 0 screenXpixels*0.7 screenYpixels]);
                else
                    DrawFormattedText(w,[double(num2str(i)) double('. ') AnswersText{QuestionNum}{i}], 'right' ,PositioningForChoicesTextOnY(i),[255 255 255],[],[],[],[],[],[0 0 screenXpixels*0.7 screenYpixels]);
                end
            end
            ColoringFlag = 1;
        end
    elseif QuestionNum < length(QuestionsOnsetVector) && GetSecs - MovieStartTime > QuestionsOnsetVector(QuestionNum) + TimeForQuestion
        QuestionNum = QuestionNum + 1;
        ColoringFlag = 0;
        QuestionOnsetFlag = 1;
    end
    
    % Option to quit movie playing with pressing two control keys in the correct order:
    if ~iscell(KeyPressed) && strcmpi(KeyPressed, ExperimenterControlKey)
        WasControllKey1Pressed=0;
    end;
    if ~iscell(KeyPressed) && ~isempty(KeyPressed) && ~strcmpi(KeyPressed, ExperimenterControlKey) && ~strcmpi(KeyPressed, SecondExperimenterControlKey)
        WasControllKey1Pressed=1;
    end;
    if WasControllKey1Pressed == 0 && ~iscell(KeyPressed) && strcmpi(KeyPressed, SecondExperimenterControlKey)
        WasControllKey2Pressed=0;
    end;
end
% Stop the movie:
Screen('PlayMovie', Movie, 0)
% Close the movie:
Screen('CloseMovie', Movie)


%% write output file:
%---------------------------------------------------
[subject_ID{1:QuestionsAmount,1}] = deal(subjectID);
WasSubjectCorrect = SubjectAnswers == CorrectAnswers;
DataTable = table(subject_ID, SubjectAnswers, CorrectAnswers, WasSubjectCorrect, QuestionOnsets, AnswerRT);

writetable(DataTable, [outputPath '/' subjectID '_' OutputFileName '_' timestamp '.txt'],'Delimiter','\t');
%%   save data to a .mat file & close out
%---------------------------------------------------------------
% outfile = strcat(outputPath, '/', subjectID,'_training_run', sprintf('%02d',runInd),'_to_run', sprintf('%02d',runNum), '_eyetracking_', timestamp,'.edf');
outfile = strcat(outputPath, '/', subjectID,'_',OutputFileName,'_', timestamp,'.mat');

run_info.subject = subjectID;
run_info.date = date;
run_info.specific_computer = specific_computer;% create a data structure with info about the run
run_info.outfile = outfile;
run_info.script_version = script_version;
run_info.revision_date = revision_date;
run_info.script_name = mfilename;

save(outfile);

Screen('Flip',w);
WaitSecs(1.5)
CenterText(w,FinalMessage{1},white, 0,-85);
Screen('Flip',w,0,1);
WaitSecs(1.5)
CenterText(w,FinalMessage{2},white, 0,0);
Screen('Flip',w);

noresp = 1;
while noresp
    [keyIsDown,~,~] = KbCheck;
    if keyIsDown && noresp
        noresp = 0;
    end;
end;
WaitSecs(0.2);

%---------------------------------------------------------------
%% experimenter control key before exiting
%---------------------------------------------------------------
UnCorrectResponse=1;
while UnCorrectResponse
    [IsPressed,~,KeyCode] = KbCheck;
    KeyPressed = KbName(KeyCode);
    if strcmpi(KeyPressed, ExperimenterControlKey)
        UnCorrectResponse=0;
    end;
end;
while IsPressed
    [IsPressed,~,~] = KbCheck;
end
WaitSecs(0.001);
Screen('CloseAll');
ShowCursor;

if ~isempty(strfind(specific_computer,'Pro')) %i.e. if it is the macbook-pro
 CopyOutputToDropbox(subjectID, mainPath, DayOfExperiment);
end

end % end function

