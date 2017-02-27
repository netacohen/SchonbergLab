function RCC_recognition(subjectID,mainPath, sessionNum, ChosenLanguage, Kind)

% function RCC_recognition(subjectID,mainPath,order, sessionNum, ChosenLanguage, Kind)

% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =


tic

rng shuffle
%==========================================================
%% PARAMETERS:
%==========================================================
% General:
%----------------------------------------------
%TimeToRespond = 5;

% STIMULI SIZE AND LOCATION
%----------------------------------------------
StartingPointOnX = 0;
StartingPointOnY = 0;
StimuliWidthScaleFactor = 1;
StimuliHeightScaleFactor = 0.8361;

%==========================================================
%% 'INITIALIZE Screen variables to be used in each task'
%==========================================================

Screen('Preference', 'VisualDebuglevel', 3); %No PTB intro screen
screennum = min(Screen('Screens'));

pixelSize = 32;
% [w] = Screen('OpenWindow',screennum,[],[0 0 640 480],pixelSize);% %debugging screensize
[w] = Screen('OpenWindow',screennum,[],[],pixelSize);

[screenXpixels, screenYpixels] = Screen('WindowSize', w);
xcenter = screenXpixels/2;
ycenter = screenYpixels/2;

% Colors settings
black = BlackIndex(w); % Should equal 0.
white = WhiteIndex(w); % Should equal 255.
% green = [0 255 0];

Screen('FillRect', w, black);
Screen('Flip', w);

% text settings
theFont = 'Arial';
Screen('TextFont',w,theFont);
Screen('TextSize',w, 40);

HideCursor;

%--------------------------------------------------------------------------
%% SETTINGS FOR THE STIMULI SIZE AND LOCATION
%--------------------------------------------------------------------------
PictureSizeOnX = round(screenXpixels * StimuliWidthScaleFactor);
PictureSizeOnY = round(screenYpixels * StimuliHeightScaleFactor);
PictureLocationVector = [StartingPointOnX, StartingPointOnY, StartingPointOnX + PictureSizeOnX, StartingPointOnY + PictureSizeOnY];

% PictureLocationVector = []; Activate it to draw the picture in the original size and in the center.

%% SETTINGS FOR THE Cohices LOCATION
%--------------------------------------------------------------------------
PositioningForChoicesOnX = round(linspace(-0.35 * screenXpixels,0.35 * screenXpixels,5));
PositioningForChoicesTextOnY = round(0.4491 * screenYpixels);
PositioningForChoicesNumbersOnY = round(0.4028 * screenYpixels);
PositioningForQuestionesOnY = round(0.35 * screenYpixels);
% -----------------------------------------------
%% Load Instructions and texts in chosen language:
% -----------------------------------------------
if strcmp(Kind, 'recognition')
    TextBlock = Language(ChosenLanguage, 'recognition');% mfilename gets the name of the running function;
elseif strcmp(Kind, 'recognition_demo')
    TextBlock = Language(ChosenLanguage, 'recognition_demo');% mfilename gets the name of the running function;
end

Answers = TextBlock(6:10);
%---------------------------------------------------------------
%% 'GLOBAL VARIABLES'
%---------------------------------------------------------------
timeNow = clock;
hours = sprintf('%02d', timeNow(4));
minutes = sprintf('%02d', timeNow(5));
timestamp = [date,'_',hours,'h',minutes,'m'];

outputPath = [mainPath '/Output'];

%---------------------------------------------------------------
%% 'Assign response keys'
%---------------------------------------------------------------
KbName('UnifyKeyNames');

key1 = '1'; % high confidence yes / paired
key2 = '2'; % low confidence yes / paired
key3 = '3'; % uncertain
key4 = '4'; % low confidence no / no paired
key5 = '5'; % high confidence no / no paired

%---------------------------------------------------------------
%% Assigning Group of Contexts variables & 'LOAD image arrays'
%-----------------------------------------------
if strcmp(Kind, 'recognition')
% Assigning Group of Contexts variables:
% --------------------------------------
    [PairedStimuli, UnpairedStimuli, PairedColor, UnpairedColors] = AssignStimuli(subjectID,outputPath);
    oldStimName = [PairedStimuli ; UnpairedStimuli];
    
    isPaired = zeros(length(oldStimName),1);
    for i = 1:length(PairedStimuli)
    isPaired = isPaired + strcmp(oldStimName,PairedStimuli(i));
    end
    
    [oldStimName, indSortedOldStimName] = sort(oldStimName); % sort old stimuli ABC
    
% Load image arrays:
% --------------------------------------
    newStimName = dir([mainPath '/Stim/contexts/RecognitionNew/*.jpg']); % Read new stimuli
    
    % Read old images to a cell array
    imgArraysOld = cell(1,length(oldStimName));
    for i = 1:length(oldStimName)
        imgArraysOld{i} = imread([mainPath '/stim/contexts/' oldStimName{i}]);
    end
    Old = ones(length(oldStimName),1);
    
    % Read new images to a cell array
    imgArraysNew = cell(1,length(newStimName));
    for i = 1:length(newStimName)
        imgArraysNew{i} = imread([mainPath '/Stim/contexts/RecognitionNew/' newStimName(i).name],'jpg');
    end
    New = zeros(length(newStimName),1);
    
    isOld = [Old; New]; % Create an array indicating whether an item is old (1) or not (0)
    
%'ORGANIZE data about the stimuli - Paired \ NoPaired
%---------------------------------------
    sortedIsPaired = isPaired(indSortedOldStimName);
    sortedIsPaired(length(oldStimName)+1:length(oldStimName)+length(newStimName)) = 0;

elseif strcmp(Kind, 'recognition_demo')
    DemoStimName = dir([mainPath '/Stim/contexts/demo/*.jpg']); % Read new stimuli
    DemoStimOrderArray = [4 5 3 8 6 1 7 2];
    imgArrays = cell(1,length(DemoStimName));
    for i = 1:length(DemoStimName)
        imgArrays{i} = imread([mainPath '/Stim/contexts/demo/' DemoStimName(DemoStimOrderArray(i)).name],'jpg');
    end
end

%---------------------------------------------------------------
%% 'SHUFFLE data about the stimuli - Paired \ UnPaired
%---------------------------------------------------------------
% Add zeros for the PairedNoPaired, isPaired, bidInd and bidValue of the new items
% - - - - - - - - - - - - - - -
if strcmp(Kind, 'recognition')
    % Merge the old and new lists, and shuffle them
    
    % Add the names of the new stimuli to stimName
    stimName = cell(1, length(oldStimName) + length(newStimName));
    stimName(1:length(oldStimName)) = oldStimName;
    
    for newStimInd = 1:length(newStimName)
        stimName{length(oldStimName)+newStimInd} = newStimName(newStimInd).name;
    end
    
    [shuffledlist, shuffledlistInd] = Shuffle(stimName);
    imgArrays = [imgArraysOld imgArraysNew];
    imgArrays = imgArrays(shuffledlistInd);
    shuffledIsOld = isOld(shuffledlistInd);
    shuffledSortedIsPaired = sortedIsPaired(shuffledlistInd);
    
elseif strcmp(Kind, 'recognition_demo')
    stimName = {DemoStimName.name};
    shuffledlist = stimName;
    shuffledlistInd = DemoStimOrderArray;
    shuffledIsOld = zeros(1,length(shuffledlistInd));
    shuffledSortedIsPaired = zeros(1,length(shuffledlistInd));
end

%---------------------------------------------------------------
%% 'Write output file header'
%---------------------------------------------------------------

fid1 = fopen([outputPath '/' subjectID '_' Kind '_confidence_results_day' num2str(sessionNum) '_' timestamp '.txt'], 'a');
fprintf(fid1,'subjectID\titemIndABC\tstimName\truntrial\tisOld?\tsubjectAnswerIsOld\tonsettime_isOld\tresp_isOld\tRT_isOld\tisGo?\tsubjectAnswerIsGo\tonsettime_isGo\tresp_isGo\tRT_isGo\n'); %write the header line

%---------------------------------------------------------------
%% 'Display Main Instructions'
%---------------------------------------------------------------

Screen('TextSize',w, 70);
Screen('TextStyle',w ,1);
DrawFormattedText(w, TextBlock{1} , 'center', screenYpixels*0.10, [255 255 255])
Screen('TextSize',w, 45);
Screen('TextStyle',w ,0);
DrawFormattedText(w, TextBlock{2} , 'center', screenYpixels*0.20, [255 255 255])
Screen('TextStyle',w ,1);
DrawFormattedText(w, TextBlock{3} , 'center', screenYpixels*0.57, [255 255 255])
DrawFormattedText(w, TextBlock{4} , 'center', screenYpixels*0.79, [50 255 50])
Screen('TextStyle',w ,0);
DrawFormattedText(w, TextBlock{5} , 'center', screenYpixels*0.84, [255 255 255])
Screen(w,'Flip');

noresp = 1;
while noresp,
    [keyIsDown] = KbCheck(-1); % deviceNumber=keyboard
    if keyIsDown && noresp,
        noresp = 0;
    end;
end

WaitSecs(0.001);
% anchor = GetSecs;

Screen('TextSize',w, 60);
Screen('DrawText', w, '+', xcenter, ycenter, white);
Screen(w,'Flip');
WaitSecs(1);

KbQueueCreate;

%---------------------------------------------------------------
%% 'Run Trials'
%---------------------------------------------------------------
% pre-allocate vectors
isOldAnswers = zeros(1, length(stimName)); % An array for the results
isGoAnswers = zeros(1, length(stimName)); % An array for the results

runStart = GetSecs;

%for trial = 1:6 % for debugging
for trial = 1:length(stimName)
    
    respTime_isOld = 999;
    respTime_isGo = 999;
    
    % isOld part
    
    %-----------------------------------------------------------------
    % display image
    % 3 seconds for each question
    
    Screen('PutImage',w,imgArrays{trial}, PictureLocationVector); % display item
    % present the Choices options:
    Screen('TextSize',w, 45);
    Screen('TextStyle',w ,1);
    CenterText(w,TextBlock{11}, [255 255 255] , 0 ,PositioningForQuestionesOnY);
    Screen('TextSize',w, 40);
    Screen('TextStyle',w ,0);
    for i = 1:length(PositioningForChoicesOnX)
        CenterText(w,num2str(i), [255 255 255] ,PositioningForChoicesOnX(i),PositioningForChoicesNumbersOnY);
        CenterText(w,Answers{i}, [255 255 255] ,PositioningForChoicesOnX(i),PositioningForChoicesTextOnY);
    end
    
    Screen(w,'Flip');
    StimOnset_isOld = GetSecs;
    
    KbQueueStart;
    %-----------------------------------------------------------------
    % get response
    
    
    noresp = 1;
    % keep tracking response for 3 seconds or until there is a response
    while noresp % && (GetSecs - StimOnset_isOld < TimeToRespond)
        % check for response
        [keyIsDown, firstPress] = KbQueueCheck(-1);
        
        if keyIsDown && noresp
            findfirstPress = find(firstPress);
            respTime_isOld = firstPress(findfirstPress(1))-StimOnset_isOld;
            tmp = KbName(findfirstPress);
            if ischar(tmp)==0 % if 2 keys are hit at once, they become a cell, not a char. we need keyPressed to be a char, so this converts it and takes the first key pressed
                tmp = char(tmp);
            end
            response_isOld = tmp(1);
            if response_isOld==key1||response_isOld==key2||response_isOld==key3||response_isOld==key4||response_isOld==key5 % A valid response is only 1,2,3,4 or 5
                noresp = 0;
            end
            
        end % end if keyIsDown && noresp
        
    end % end while noresp
    
    %-----------------------------------------------------------------
    % save the subject's response
    if noresp
        response_isOld = '999';
        isOldAnswers(trial) = str2double(response_isOld);
        % display a message for responding faster
        
        Screen('TextSize',w, 40);
        CenterText(w,TextBlock{15},white,0,0);
        Screen(w,'Flip');
    else
        isOldAnswers(trial) = str2double(response_isOld);
        % redraw text output with the appropriate colorchanges to highlight
        % response
        Screen('PutImage',w,imgArrays{trial}, PictureLocationVector); % display item
        % present the Choices options:
        Screen('TextSize',w, 45);
        Screen('TextStyle',w ,1);
        CenterText(w,TextBlock{11}, [255 255 255] , 0 ,PositioningForQuestionesOnY);
        Screen('TextSize',w, 40);
        Screen('TextStyle',w ,0);
        for i = 1:length(PositioningForChoicesOnX)
            if i == isOldAnswers(trial) %The choice to highlight
                CenterText(w,num2str(i), [50 255 50] ,PositioningForChoicesOnX(i),PositioningForChoicesNumbersOnY);
                CenterText(w,Answers{i}, [50 255 50] ,PositioningForChoicesOnX(i),PositioningForChoicesTextOnY);
            else
                CenterText(w,num2str(i), [255 255 255] ,PositioningForChoicesOnX(i),PositioningForChoicesNumbersOnY);
                CenterText(w,Answers{i}, [255 255 255] ,PositioningForChoicesOnX(i),PositioningForChoicesTextOnY);
            end
        end
        Screen(w,'Flip');
    end
    
    WaitSecs(0.5);
    Screen('PutImage',w,imgArrays{trial}, PictureLocationVector); % display item
    Screen(w,'Flip');
    WaitSecs(0.5);

    %-----------------------------------------------------------------
    %     % show fixation ITI
    %     Screen('TextSize',w, 60);
    %     Screen('DrawText', w, '+', xcenter, ycenter, white);
    %     Screen(w,'Flip');
    %     WaitSecs(1);
    
    KbQueueFlush;
    
    
    %% Paired/Unpaired question
    %-----------------------------------------------------------------
    
    Screen('PutImage',w,imgArrays{trial}, PictureLocationVector); % display item
    % present the Choices options:
    Screen('TextSize',w, 45);
    Screen('TextStyle',w ,1);
    CenterText(w,TextBlock{12}, [255 255 255] , 0 ,PositioningForQuestionesOnY);
    Screen('TextSize',w, 40);
    Screen('TextStyle',w ,0);
    for i = 1:length(PositioningForChoicesOnX)
        CenterText(w,num2str(i), [255 255 255] ,PositioningForChoicesOnX(i),PositioningForChoicesNumbersOnY);
        CenterText(w,Answers{i}, [255 255 255] ,PositioningForChoicesOnX(i),PositioningForChoicesTextOnY);
    end
    
    Screen(w,'Flip');
    StimOnset_isGo = GetSecs;
    
    KbQueueStart;
    %-----------------------------------------------------------------
    % get response
    
    
    noresp = 1;
    while noresp % && (GetSecs - StimOnset_isGo < TimeToRespond)
        % check for response
        [keyIsDown, firstPress] = KbQueueCheck(-1);
        
        if keyIsDown && noresp
            findfirstPress = find(firstPress);
            respTime_isGo = firstPress(findfirstPress(1))-StimOnset_isGo;
            tmp = KbName(findfirstPress);
            if ischar(tmp)==0 % if 2 keys are hit at once, they become a cell, not a char. we need keyPressed to be a char, so this converts it and takes the first key pressed
                tmp = char(tmp);
            end
            response_isGo = tmp(1);
            if response_isGo==key1||response_isGo==key2||response_isGo==key3||response_isGo==key4||response_isGo==key5 % A valid response is only 1,2,3,4 or 5
                noresp = 0;
            end
            
        end % end if keyIsDown && noresp
        
    end % end while noresp
    
    
    
    %-----------------------------------------------------------------
    % save the subject's response
    if noresp
        response_isGo = '999';
        isGoAnswers(trial) = str2double(response_isGo);
        % display a message for responding faster
        
        Screen('TextSize',w, 40);
        CenterText(w,TextBlock{15} ,white,0,0);
        Screen(w,'Flip');
    else
        isGoAnswers(trial) = str2double(response_isGo);
        % redraw text output with the appropriate colorchanges to highlight
        % response
        Screen('PutImage',w,imgArrays{trial}, PictureLocationVector); % display item
        % present the Choices options:
        Screen('TextSize',w, 45);
        Screen('TextStyle',w ,1);
        CenterText(w,TextBlock{12}, [255 255 255] , 0 ,PositioningForQuestionesOnY);
        Screen('TextSize',w, 40);
        Screen('TextStyle',w ,0);
        for i = 1:length(PositioningForChoicesOnX)
            if i == isGoAnswers(trial) %The choice to highlight
                CenterText(w,num2str(i), [50 255 50] ,PositioningForChoicesOnX(i),PositioningForChoicesNumbersOnY);
                CenterText(w,Answers{i}, [50 255 50] ,PositioningForChoicesOnX(i),PositioningForChoicesTextOnY);
            else
                CenterText(w,num2str(i), [255 255 255] ,PositioningForChoicesOnX(i),PositioningForChoicesNumbersOnY);
                CenterText(w,Answers{i}, [255 255 255] ,PositioningForChoicesOnX(i),PositioningForChoicesTextOnY);
            end
        end
        Screen(w,'Flip');
        
    end
    
    WaitSecs(0.5);
    
    %-----------------------------------------------------------------
    % show fixation ITI
    Screen('TextSize',w, 60);
    Screen('DrawText', w, '+', xcenter, ycenter, white);
    Screen(w,'Flip');
    WaitSecs(1);
    
    %-----------------------------------------------------------------
    % Write to output files
    
    fprintf(fid1,'%s\t%d\t%s\t%d\t%d\t%d\t%d\t%s\t%d\t%d\t%d\t%d\t%s\t%d\n', subjectID, shuffledlistInd(trial), shuffledlist{trial}, trial, shuffledIsOld(trial), isOldAnswers(trial), StimOnset_isOld-runStart, response_isOld, respTime_isOld, shuffledSortedIsPaired(trial), isGoAnswers(trial), StimOnset_isGo-runStart, response_isGo, respTime_isGo);
    % fprintf(fid1,'subjectID\titemIndABC\tstimName\truntrial\tisOld?\tsubjectAnswerIsOld\tonsettime_isOld\tresp_isOld\tRT_isOld\tisGo?\tsubjectAnswerIsGo\tonsettime_isGo\tresp_isGo\tRT_isGo\n'); %write the header line
    
    KbQueueFlush;
    
end % end loop for trial = 1:length(food_images);

% Close open files
fclose(fid1);


% Save variables to mat file
if strcmp(Kind, 'recognition')
    outfile = strcat(outputPath,'/', sprintf('%s_recognition_confidence_day%d_%s.mat', subjectID, sessionNum, timestamp));
elseif strcmp(Kind, 'recognition_demo')
    outfile = strcat(outputPath,'/', sprintf('%s_recognition_confidence_demo_day%d_%s.mat', subjectID, sessionNum, timestamp));
end


% create a data structure with info about the run
run_info.subject = subjectID;
run_info.date = date;
run_info.outfile = outfile;

run_info.script_name = mfilename;
clear imgArrays imgArraysNew imgArraysOld;
save(outfile);


% End of session screen
Screen('TextSize',w, 40);
CenterText(w,TextBlock{13}, white,0,-50);
Screen(w,'Flip', 0,1);
WaitSecs(0.8);
CenterText(w,TextBlock{14}, white,0,50);
Screen(w,'Flip');


% Closing

WaitSecs(4);
toc
ShowCursor;
Screen('CloseAll');


end % end function