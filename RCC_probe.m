function RCC_probe(subjectID, mainPath, NumberOfRoundsForProbe, ChosenLanguage, Kind)

% function day1_probe(subjectID, mainPath, sessionNum, block, numRun, numRunsPerBlock, trialsPerRun)
%
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =


tic

rng shuffle

%==============================================
%% 'GLOBAL VARIABLES'
%==============================================

outputPath = [mainPath '/Output'];

%   'timestamp'
% - - - - - - - - - - - - - - - - -
c = clock;
hr = sprintf('%02d', c(4));
minutes = sprintf('%02d', c(5));
timestamp = [date,'_',hr,'h',minutes,'m'];

%   'set phase times'
% - - - - - - - - - - - - - - - - -
maxtime = 2;      % 1.5 second limit on each selection
baseline_fixation_dur = 2; % Need to modify based on if first few volumes are saved or not
afterrunfixation = 1;
%afterrunfixation = 6;

%about language:
TextBlock = Language(ChosenLanguage, Kind);% mfilename gets the name of the running function;

% Variables For OnsetList (The variables are not including the 2 seconds of
% the stimuli appearance
%---------------------------
mean_ITI = 3.5;
min_ITI = 1.5;
max_ITI = 8;
RoundITIdifferencesTo = 0.5;
%---------------------------

tic

%==============================================
%% 'INITIALIZE Screen variables'
%==============================================
Screen('Preference', 'VisualDebuglevel', 3); %No PTB intro screen
screennum = min(Screen('Screens'));

pixelSize=32;
%[w] = Screen('OpenWindow',screennum,[],[0 0 640 480],pixelSize);% %debugging screensize
[w] = Screen('OpenWindow',screennum,[],[],pixelSize);

HideCursor;


% Define Colors
% - - - - - - - - - - - - - - -
black = BlackIndex(w); % Should equal 0.
white = WhiteIndex(w); % Should equal 255.
yellow = [255 255 0];

Screen('FillRect', w, black);  % NB: only need to do this once!
Screen('Flip', w);


% setting the text
% - - - - - - - - - - - - - - -
theFont = 'Arial';
Screen('TextFont',w,theFont);
Screen('TextSize',w, 40);

% stack locations
% - - - - - - - - - - - - - - -
[screenXpixels, screenYpixels] = Screen('WindowSize', w);
xcenter = screenXpixels/2;
ycenter = screenYpixels/2;

stackW = 576;
stackH = 432;

leftRect = [xcenter-stackW-300 ycenter-stackH/2 xcenter-300 ycenter+stackH/2];
rightRect = [xcenter+300 ycenter-stackH/2 xcenter+stackW+300 ycenter+stackH/2];

penWidth = 10;
%% just a fix for a specific problem with my macbook-pro when it runs on it.
[~,MacSerialNumber] = system('system_profiler SPHardwareDataType | awk ''/Serial/ {print $4}''');
if strcmp(MacSerialNumber,['C02P9B1RFVH5' char(10)])
    penWidth = 7;
end

Screen('BlendFunction', w, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

HideCursor;

%==============================================
%% 'ASSIGN response keys'
%==============================================
KbName('UnifyKeyNames');

leftstack = 'u';
rightstack = 'i';
badresp = 'x';

%% Assigning Group of Contexts variables
%-----------------------------------------------
[PairedStimuli, UnpairedStimuli, PairedColor, UnpairedColors] = AssignStimuli(subjectID,outputPath);

%==============================================
%% 'Read in files'
%==============================================

% LOADING THE HAPPY/SAD CONTEXTS FOR THIS SUBJECT
% - - - - - - - - - - - - - - -  - - - - - - - - - - - - - - - - - - - -
if strcmp(Kind, 'day1_probe') || strcmp(Kind, 'day2_probe') || strcmp(Kind, 'day3_probe')
    PairedContexts = PairedStimuli;
    % about contexts
    numOfContexts = 9; % may use 1/2/other for debugging.
elseif strcmp(Kind, 'day1_probe_demo') || strcmp(Kind, 'day2_probe_demo') || strcmp(Kind, 'day3_probe_demo')
    numOfContexts = 4;
end

%   Making the contexts files list
% - - - - - - - - - - - - - - -
if strcmp(Kind, 'day1_probe') || strcmp(Kind, 'day2_probe') || strcmp(Kind, 'day3_probe')
    contexts{1} = [PairedStimuli ; UnpairedStimuli];
elseif strcmp(Kind, 'day1_probe_demo') || strcmp(Kind, 'day2_probe_demo') || strcmp(Kind, 'day3_probe_demo')
    images=dir('./Stim/contexts/demo/*.jpg');
    contexts{1} = cell((Struct2Vect(images,'name'))') ;
end
contexts{1} = cell(contexts{1}(1:numOfContexts)); %ONLY FOR DEBUGGING (1:1) or (1:2)!
clear images

% Basic Variables for the houses presentation:
% - - - - - - - - - - - - - - -
DoorsAnimationSettings

if strcmp(Kind, 'day1_probe')
    % Creating the array for the probe comparisons:
    %------------------------------------------------
    PairedContextsItems = PairedContexts;
    PairedContext_SerialNumber = find(ismember(contexts{1},PairedContextsItems));
    UnpairedContexts_SerialNumbers = find(~ismember(contexts{1},PairedContexts));
    UnpairedGroup_A_Color = contexts{1}{UnpairedContexts_SerialNumbers(1)}(6:8);
    UnpairedGroup_A_SerialNumbers = find(~cellfun('isempty' , (strfind(contexts{1},UnpairedGroup_A_Color))));
    UnpairedGroup_B_SerialNumbers = find(~ismember(1:length(contexts{1}),PairedContext_SerialNumber) & ~ismember(1:length(contexts{1}),UnpairedGroup_A_SerialNumbers))';
    
    NumOfPairedContexts = length(PairedContext_SerialNumber);
    NumOfUnPairedContexts = length(UnpairedContexts_SerialNumbers);
    NumOfUnpairedGroup_A_Contexts = length(UnpairedGroup_A_SerialNumbers);
    NumOfUnpairedGroup_B_Contexts = length(UnpairedGroup_B_SerialNumbers);
    
    % Creating The Relevant Array:
    %-----------------------------------
    RelevantComparisonsArray = zeros(NumOfPairedContexts * NumOfUnPairedContexts, 2);
    for i = 1:NumOfPairedContexts
        for j = 1:NumOfUnPairedContexts
            RelevantComparisonsArray((i-1)*NumOfUnPairedContexts+j,1) = PairedContext_SerialNumber(i);
            RelevantComparisonsArray((i-1)*NumOfUnPairedContexts+j,2) = UnpairedContexts_SerialNumbers(j);
        end
    end
    
    % Adding unrelevant comparisons between the items of the two unpaired group (so every context will apear the same amount of
    % times):
    % --------------------------------
    % gathering the data and make all the possible comparisons array:
        
    FinalNeutralComparisonMatrix = zeros(NumOfUnpairedGroup_A_Contexts * NumOfUnpairedGroup_B_Contexts, 2);
    for i = 1:NumOfUnpairedGroup_A_Contexts
        for j = 1:NumOfUnpairedGroup_B_Contexts
            FinalNeutralComparisonMatrix((i-1)*NumOfUnpairedGroup_A_Contexts+j,1) = UnpairedGroup_A_SerialNumbers(i);
            FinalNeutralComparisonMatrix((i-1)*NumOfUnpairedGroup_A_Contexts+j,2) = UnpairedGroup_B_SerialNumbers(j);
        end
    end
    
    % Connecting Relevan and Irelevant Comparisons Arrays Toghether:
    ComparisonsArray = [RelevantComparisonsArray ;FinalNeutralComparisonMatrix];
    
    save([outputPath '/' subjectID '_Comparisons_Array'],'ComparisonsArray')
    
    NumOfComparisonsPerRun = size(ComparisonsArray,1);
    
    %   'load image arrays'
    % - - - - - - - - - - - - - - -
    context_items = cell(1,numOfContexts);
    for i = 1:numOfContexts
        context_items{i} = imread([mainPath sprintf('/stim/contexts/%s',contexts{1}{i})]);
    end
elseif strcmp(Kind, 'day2_probe') || strcmp(Kind, 'day3_probe')
    PairedContextsItems = PairedContexts;
    PairedContext_SerialNumber = find(ismember(contexts{1},PairedContextsItems));
    
    load([outputPath '/' subjectID '_Comparisons_Array'],'ComparisonsArray')
    
    NumOfComparisonsPerRun = size(ComparisonsArray,1);
    
    %   'load image arrays'
    % - - - - - - - - - - - - - - -
    context_items = cell(1,numOfContexts);
    for i = 1:numOfContexts
        context_items{i} = imread([mainPath sprintf('/stim/contexts/%s',contexts{1}{i})]);
    end
elseif strcmp(Kind, 'day1_probe_demo') || strcmp(Kind, 'day2_probe_demo') || strcmp(Kind, 'day3_probe_demo')
    NumOfComparisonsPerRun = sum(1:numOfContexts - 1);
    PairedContext_SerialNumber = [];
    %   'load image arrays'
    % - - - - - - - - - - - - - - -
    context_items = cell(1,numOfContexts);
    for i = 1:numOfContexts
        context_items{i} = imread([mainPath sprintf('/stim/contexts/demo/%s',contexts{1}{i})]);
    end
    
end

%% Croping the contexts settings

XCropingFromLeft = round(screenXpixels*0.2344)+1;
XCropingFromRight = screenXpixels - round(screenXpixels*0.2344);
YCropingFromTop = round(screenYpixels*0.3555);
YCropingFromButtom = round(screenYpixels * 0.8361);

%   Making the cropped contexts accordingly
%---------------------------
CroppedContextsItems = cell(1,length(context_items));
for i = 1 : length(context_items)
    CroppedContextsItems{i} = context_items{i}(YCropingFromTop:YCropingFromButtom,XCropingFromLeft:XCropingFromRight,:); %The cropping variables are defined inside DoorsAnimationSettings.m
end

%-----------------------------------------------------------------
%% 'Write output file header'
%-----------------------------------------------------------------

if strcmp(Kind, 'day1_probe')
    fid1 = fopen([outputPath '/' subjectID sprintf('_day1_probe_') timestamp '.txt'], 'a');
elseif strcmp(Kind, 'day2_probe')
    fid1 = fopen([outputPath '/' subjectID sprintf('_day2_probe_') timestamp '.txt'], 'a');
elseif strcmp(Kind, 'day3_probe')
    fid1 = fopen([outputPath '/' subjectID sprintf('_day3_probe_') timestamp '.txt'], 'a');
elseif strcmp(Kind, 'day1_probe_demo')
    fid1 = fopen([outputPath '/' subjectID sprintf('_day1_probe_demo_') timestamp '.txt'], 'a');
elseif strcmp(Kind, 'day2_probe_demo')
    fid1 = fopen([outputPath '/' subjectID sprintf('_day2_probe_demo_') timestamp '.txt'], 'a');
    elseif strcmp(Kind, 'day3_probe_demo')
    fid1 = fopen([outputPath '/' subjectID sprintf('_day3_probe_demo_') timestamp '.txt'], 'a');
end
fprintf(fid1,'subjectID\tblock\ttrial\tonsettime\tImageLeft\tImageRight\tContextIndexLeft\tContextIndexRight\tResponse\tPairType\tOutcome\tRT\n'); %write the header line


%% Starts the loop for the number of rounds:
for block = 1 : NumberOfRoundsForProbe
    
    %   'load onsets'
    % - - - - - - - - - - - - - - -
    if strcmp(Kind, 'day1_probe') || strcmp(Kind, 'day2_probe') || strcmp(Kind, 'day3_probe')
        requiredLength = (NumOfComparisonsPerRun - 1) * (mean_ITI + maxtime);
        onsetlist = createOnsetListForProbe(mean_ITI,min_ITI,max_ITI,RoundITIdifferencesTo,requiredLength,NumOfComparisonsPerRun);   
    elseif strcmp(Kind, 'day1_probe_demo') || strcmp(Kind, 'day2_probe_demo') || strcmp(Kind, 'day3_probe_demo')
        onsetlist = [0 5.5 11 19 23.5 27];
    end
    
    %==============================================
    %% 'Display Main Instructions'
    %==============================================
    KbQueueCreate;
    if  mod(block-1,3) == 0 % If this is the first run of the first block and every 3 blocks, show instructions
        
        %TextBlock{1} = [1513 1500 1489 32 50 32 45 32 1489 1495 1497 1512 1492 32 1489 1497 1503 32 1495 1491 1512 1497 1501]; %'Instruction:'
        %TextBlock{2} = [1489 1513 1500 1489 32 1494 1492 32 1497 1493 1510 1490 1493 32 1489 1508 1504 1497 1498 32 50 32 1495 1491 1512 1497 1501 32 1489 1499 1500 32 1508 1506 1501 46 32 1492 1502 1513 1497 1502 1492 32 1492 1497 1488 32 1500 1489 1495 1493 1512 32 1488 1495 1491 32 1502 1513 1504 1497 32 1492 1495 1491 1512 1497 1501 46 10 10 1489 1495 1497 1512 1514 32 1492 1495 1491 1512 1497 1501 32 1513 1514 1506 1513 1492 47 1497 32 1489 1513 1500 1489 32 1494 1492 32 1514 1513 1508 1497 1506 32 1506 1500 32 1502 1513 1497 1502 1492 32 1489 1497 1493 1501 32 1492 1488 1495 1512 1493 1503 32 1500 1504 1497 1505 1493 1497 46 10 1499 1499 1500 32 1513 1514 1489 1495 1512 47 1497 32 1489 1495 1491 1512 32 1502 1505 1493 1497 1497 1501 32 1497 1493 1514 1512 32 1508 1506 1502 1497 1501 32 1514 1489 1500 1492 47 1497 32 1489 1493 32 1494 1502 1503 32 1512 1489 32 1497 1493 1514 1512 32 1489 1502 1513 1497 1502 1492 32 10 1513 1489 1497 1493 1501 32 1492 1488 1495 1512 1493 1503 32 40 1489 1488 1493 1508 1503 32 1497 1495 1505 1497 32 1502 1514 1493 1498 32 1494 1502 1503 32 1492 1502 1513 1497 1502 1492 32 1492 1499 1493 1500 1500 41 46 10 1500 1505 1497 1499 1493 1501 58 32 1492 1502 1496 1512 1492 32 1489 1513 1500 1489 32 1494 1492 32 1492 1497 1488 32 1500 1489 1495 1493 1512 32 1489 1495 1491 1512 32 1513 1488 1514 47 1492 32 10 1502 1506 1491 1497 1507 47 1492 44 32 1499 1500 1493 1502 1512 32 1513 1514 1512 1510 1492 47 1497 32 1500 1513 1492 1493 1514 32 1489 1493 32 1497 1493 1514 1512 32 1489 1492 1502 1513 1498 46 10 10 1492 1489 1495 1497 1512 1492 32 1502 1514 1489 1510 1506 1514 32 1506 1500 32 1497 1491 1497 32 1492 1502 1511 1513 1497 1501 32 8216 105 8217 32 1493 45 8216 117 8217 46 32 1500 1495 1510 47 1497 32 8216 105 8217 32 1500 1489 1495 1497 1512 1514 32 10 1492 1495 1491 1512 32 1513 1502 1493 1510 1490 32 1502 1497 1502 1497 1503 32 1493 45 8216 117 8217 32 1500 1489 1495 1497 1512 1514 32 1492 1495 1491 1512 32 1513 1502 1493 1510 1490 32 1502 1510 1491 32 1513 1502 1488 1500 46 32 10 1500 1512 1513 1493 1514 1498 32 49 46 53 32 1513 1504 1497 1493 1514 32 1500 1489 1510 1506 32 1488 1514 32 1492 1489 1495 1497 1512 1492 32 1489 1499 1500 32 1508 1506 1501 46 10 1488 1504 1488 32 1489 1495 1512 47 1497 32 1489 1502 1492 1497 1512 1493 1514 46];
        %TextBlock{3} = [1489 1492 1510 1500 1495 1492 33];
        
        Screen('TextSize',w, 70);
        Screen('TextStyle',w ,1);
        DrawFormattedText(w, TextBlock{1} , 'center', screenYpixels*0.15, [50 255 50])
        Screen('TextSize',w, 45);
        Screen('TextStyle',w ,1);
        DrawFormattedText(w, TextBlock{2} , 'center', screenYpixels*0.27, [255 255 255],  0, 0, 0, 1.2)
        Screen('TextStyle',w ,0);
        DrawFormattedText(w, TextBlock{3} , 'center', screenYpixels*0.47, [255 255 255],  0, 0, 0, 1.2)
        Screen('TextStyle',w ,1);
        DrawFormattedText(w, TextBlock{4} , 'center', screenYpixels*0.72, [255 255 255],  0, 0, 0, 1.2)
        Screen('TextStyle',w ,0);
        DrawFormattedText(w, TextBlock{5} , 'center', screenYpixels*0.88, [50 255 50])
        Screen(w,'Flip');
        
        Screen('TextSize',w,40); % return to normal size
        
        noresp = 1;
        while noresp,
            [keyIsDown] = KbCheck(-1);%deviceNumber=keyboard
            if keyIsDown && noresp,
                noresp = 0;
            end;
        end;
    else % this is the first run but not the first block
        
        %TextBlock = [1505 1497 1489 1493 1489 32 1504 1493 1505 1507 32 1497 1514 1495 1497 1500 32 1506 1499 1513 1497 1493 46 10 32 1500 1495 1510 47 1497 32 1506 1500 32 1502 1511 1513 32 1499 1500 1513 1492 1493 32 1499 1491 1497 32 1500 1492 1502 1513 1497 1498 46];
        DrawFormattedText(w, TextBlock{6}, 'center', 'center', white, 0, 0, 0, 2.5);
        Screen('Flip',w);
        
        noresp = 1;
        while noresp,
            [keyIsDown] = KbCheck(-1);%deviceNumber=keyboard
            if keyIsDown && noresp,
                noresp = 0;
            end;
        end;
    end % end if block == 1
    
    %------------------------------------------------------------
    %% Shuffle the array for the probe:
    %------------------------------------------------------------
    if strcmp(Kind, 'day1_probe') || strcmp(Kind, 'day2_probe') || strcmp(Kind, 'day3_probe')
        % Shuffling The pairs (first rows and then columns):
        ComparisonsPerRunMatrix = Shuffle2(ComparisonsArray,2);
        for i = 1:size(ComparisonsPerRunMatrix,1)
            ComparisonsPerRunMatrix(i,:) = Shuffle(ComparisonsPerRunMatrix(i,:));
        end
        % Set the trial type vector:
        pairType = sum(ismember(ComparisonsPerRunMatrix, PairedContext_SerialNumber),2); % 1 indicates a comparison of interest. 0 unpaired contextes comparison.
    elseif strcmp(Kind, 'day1_probe_demo') || strcmp(Kind, 'day2_probe_demo') || strcmp(Kind, 'day3_probe_demo')
        ComparisonsPerRunMatrix = [3 2; 4 3; 1 2; 3 1; 2 4; 4 1];
        % Set the trial type vector:
        pairType = 999; % 999 - a demo comparison.
    end

    
    %%   baseline fixation cross
    % - - - - - - - - - - - - -
    
    prebaseline = GetSecs;
    % baseline fixation - currently 10 seconds = 4*Volumes (2.5 TR)
    while GetSecs < prebaseline+baseline_fixation_dur
        %    Screen(w,'Flip', anchor);
        DrawFormattedText(w, '+' , 'center', screenYpixels/2 , white)
        Screen('TextSize',w, 60);% adjusting size to fixation cross.
        Screen(w,'Flip');
    end
    postbaseline = GetSecs;
    baseline_fixation = postbaseline - prebaseline;
    
    %==============================================
    %% 'Run Trials'
    %==============================================
    
    runStart = GetSecs;
    
    for trial = 1:NumOfComparisonsPerRun % Starts the trials loop.
        
        % initial box outline colors
        % - - - - - - -
        colorLeft = black;
        colorRight = black;
        out = 999;
        
        
        %-----------------------------------------------------------------
        % display images
        %-----------------------------------------------------------------
        % Adding the pathes
        Screen('DrawTextures', w, imageTexturePath, [], dstRectPath * ScalingRatioForProbeHouses + PositionForRightCroppedContext, 0);
        Screen('DrawTextures', w, imageTexturePath, [], dstRectPath * ScalingRatioForProbeHouses + PositionForLeftCroppedContext, 0);
        
        Screen('DrawTextures', w, imageTextureHouseLeft, [], dstRectHouseLeft);
        Screen('DrawTextures', w, imageTextureHouseRight, [], dstRectHouseRight);
        
        Screen('PutImage',w,CroppedContextsItems{ComparisonsPerRunMatrix(trial,1)}, [XCropingFromLeft-1,YCropingFromTop-1,XCropingFromRight,YCropingFromButtom] * ScalingRatioForProbeHouses + PositionForLeftCroppedContext);
        Screen('PutImage',w,CroppedContextsItems{ComparisonsPerRunMatrix(trial,2)}, [XCropingFromLeft-1,YCropingFromTop-1,XCropingFromRight,YCropingFromButtom] * ScalingRatioForProbeHouses + PositionForRightCroppedContext);
        
        % Adding the doors
        Screen('DrawTextures', w, imageTextureDoor(1), [], DoorsPosition * ScalingRatioForProbeHouses + PositionForRightCroppedContext , 0);
        Screen('DrawTextures', w, imageTextureDoor(1), [], DoorsPosition * ScalingRatioForProbeHouses + PositionForLeftCroppedContext, 0);

        DrawFormattedText(w, '+' , 'center', screenYpixels/2, white)
        StimOnset = Screen(w,'Flip', runStart+onsetlist(trial)+baseline_fixation);
        
        KbQueueFlush;
        KbQueueStart;
        
        
        %-----------------------------------------------------------------
        % get response
        %-----------------------------------------------------------------
        
        noresp = 1;
        goodresp = 0;
        while noresp
            % check for response
            [keyIsDown, firstPress] = KbQueueCheck;
            
            if keyIsDown && noresp
                keyPressed = KbName(firstPress);
                if ischar(keyPressed) == 0 % if 2 keys are hit at once, they become a cell, not a char. we need keyPressed to be a char, so this converts it and takes the first key pressed
                    keyPressed = char(keyPressed);
                    keyPressed = keyPressed(1);
                end
                switch keyPressed
                    case leftstack
                        respTime = firstPress(KbName(leftstack))-StimOnset;
                        noresp = 0;
                        goodresp = 1;
                    case rightstack
                        respTime = firstPress(KbName(rightstack))-StimOnset;
                        noresp = 0;
                        goodresp = 1;
                end
            end % end if keyIsDown && noresp
            
            
            % check for reaching time limit
            if noresp && GetSecs-runStart >= onsetlist(trial)+baseline_fixation+maxtime
                noresp = 0;
                keyPressed = badresp;
                respTime = maxtime;
            end
        end % end while noresp
        
        %-----------------------------------------------------------------
        % Determine the output for the choice
        %-----------------------------------------------------------------
        if any(ismember(PairedContext_SerialNumber, ComparisonsPerRunMatrix(trial,:)))% Check that the comparison is relevant (between a "happy/sad" context to a neutral one.
            switch keyPressed
                case leftstack
                    if ismember(ComparisonsPerRunMatrix(trial,1),PairedContext_SerialNumber)
                        out = 1;
                    else
                        out = 0;
                    end
                case rightstack
                    if ismember(ComparisonsPerRunMatrix(trial,2),PairedContext_SerialNumber)
                        out = 1;
                    else
                        out = 0;
                    end
            end
        else % If just a trial of no interest. Left choice will get 11 and right will get 12.
            switch keyPressed
                case leftstack
                    out = 11;
                case rightstack
                    out = 12;
            end
        end
        
        if goodresp==1
            % Adding the pathes
            Screen('DrawTextures', w, imageTexturePath, [], dstRectPath * ScalingRatioForProbeHouses + PositionForRightCroppedContext, 0);
            Screen('DrawTextures', w, imageTexturePath, [], dstRectPath * ScalingRatioForProbeHouses + PositionForLeftCroppedContext, 0);
            
            Screen('DrawTextures', w, imageTextureHouseLeft, [], dstRectHouseLeft);
            Screen('DrawTextures', w, imageTextureHouseRight, [], dstRectHouseRight);
            
            Screen('PutImage',w,CroppedContextsItems{ComparisonsPerRunMatrix(trial,1)}, [XCropingFromLeft-1,YCropingFromTop-1,XCropingFromRight,YCropingFromButtom] * ScalingRatioForProbeHouses + PositionForLeftCroppedContext);
            Screen('PutImage',w,CroppedContextsItems{ComparisonsPerRunMatrix(trial,2)}, [XCropingFromLeft-1,YCropingFromTop-1,XCropingFromRight,YCropingFromButtom] * ScalingRatioForProbeHouses + PositionForRightCroppedContext);
            
            % Adding the doors
            Screen('DrawTextures', w, imageTextureDoor(1), [], DoorsPosition * ScalingRatioForProbeHouses + PositionForRightCroppedContext , 0);
            Screen('DrawTextures', w, imageTextureDoor(1), [], DoorsPosition * ScalingRatioForProbeHouses + PositionForLeftCroppedContext, 0);

            %-----------------------------------------------------------------
            % determine what bid to highlight
            %-----------------------------------------------------------------
            switch keyPressed
                case leftstack
                    colorLeft = yellow;
                    % left house - frame
                    Screen('DrawLine', w ,colorLeft, 891 , 835, 891, 425 ,penWidth);%right
                    Screen('DrawLine', w ,colorLeft, 65 , 835, 65, 425 ,penWidth);%left
                    Screen('DrawLine', w ,colorLeft, 60 , 427, 475, 199 ,penWidth);% / shape
                    Screen('DrawLine', w ,colorLeft, 475 , 199, 896, 427 ,penWidth);% \ shape
                    Screen('DrawLine', w ,colorLeft, 60 , 839, 896, 839 ,penWidth);%buttom line
                    %Screen('FrameRect', w, colorLeft, leftRect, penWidth);
                case rightstack
                    colorRight = yellow;
                    % right house - frame
                    Screen('DrawLine', w ,colorRight, 1851 , 835, 1851, 425 ,penWidth);%right
                    Screen('DrawLine', w ,colorRight, 1025 , 835, 1025, 425 ,penWidth);%left
                    Screen('DrawLine', w ,colorRight, 1020 , 427, 1435, 199 ,penWidth);% / shape
                    Screen('DrawLine', w ,colorRight, 1435 , 199, 1856, 427 ,penWidth);% \ shape
                    Screen('DrawLine', w ,colorRight, 1020 , 839, 1856, 839 ,penWidth);%buttom line
                    %Screen('FrameRect', w, colorRight, rightRect, penWidth);
            end
            DrawFormattedText(w, '+' , 'center', screenYpixels/2, white)
            Screen(w,'Flip',runStart+onsetlist(trial)+respTime+baseline_fixation);
        else
            %TextBlock = [1497 1513 32 1500 1492 1490 1497 1489 32 1502 1492 1512 32 1497 1493 1514 1512 33];
            if strcmp(Kind, 'day1_probe') || strcmp(Kind, 'day2_probe') || strcmp(Kind, 'day3_probe')
                DrawFormattedText(w, TextBlock{7}, 'center', 'center', white)
            elseif strcmp(Kind, 'day1_probe_demo') || strcmp(Kind, 'day2_probe_demo') || strcmp(Kind, 'day3_probe_demo')
                DrawFormattedText(w, TextBlock{6}, 'center', 'center', white)
            end
            Screen(w,'Flip',runStart+onsetlist(trial)+respTime+baseline_fixation);
        end % end if goodresp==1
        
        
        %-----------------------------------------------------------------
        % show fixation ITI
        %-----------------------------------------------------------------
        DrawFormattedText(w, '+' , 'center', screenYpixels/2, white)
        if goodresp==1
            Screen(w,'Flip',runStart+onsetlist(trial)+maxtime+baseline_fixation);
        else
            Screen(w,'Flip',runStart+onsetlist(trial)+respTime+.5+baseline_fixation);
        end
        
        if goodresp ~= 1
            respTime = 999;
        end
        
        %-----------------------------------------------------------------
        % 'Save data'
        %-----------------------------------------------------------------
        if strcmp(Kind, 'day1_probe') || strcmp(Kind, 'day2_probe') || strcmp(Kind, 'day3_probe')
            fprintf(fid1,'%s\t %s\t %d\t %d\t %s\t %s\t %d\t %d\t %s\t %d\t %d\t %.2f\n', subjectID, sprintf('%02d', block), trial, StimOnset-runStart, contexts{1}{ComparisonsPerRunMatrix(trial,1)}, contexts{1}{ComparisonsPerRunMatrix(trial,2)}, ComparisonsPerRunMatrix(trial,1), ComparisonsPerRunMatrix(trial,2), keyPressed, pairType(trial), out, respTime*1000);
        elseif strcmp(Kind, 'day1_probe_demo') || strcmp(Kind, 'day2_probe_demo') || strcmp(Kind, 'day3_probe_demo')
            fprintf(fid1,'%s\t %s\t %d\t %d\t %s\t %s\t %d\t %d\t %s\t %d\t %d\t %.2f\n', subjectID, sprintf('%02d', block), trial, StimOnset-runStart, contexts{1}{ComparisonsPerRunMatrix(trial,1)}, contexts{1}{ComparisonsPerRunMatrix(trial,2)}, ComparisonsPerRunMatrix(trial,1), ComparisonsPerRunMatrix(trial,2), keyPressed, pairType, out, respTime*1000);
        end
        
        %     KbQueueFlush;
        
    end % loop through trials
    
    Postexperiment = GetSecs;
    while GetSecs < Postexperiment + afterrunfixation;
        DrawFormattedText(w, '+' , 'center', screenYpixels/2, white)
        Screen(w,'Flip');
    end
    
    
    %-----------------------------------------------------------------
    %	display outgoing message
    %-----------------------------------------------------------------
    WaitSecs(2);
    Screen('FillRect', w, black);
    Screen('TextSize',w, 40);
    
    if block ~= NumberOfRoundsForProbe
        % This is not the last run of the block
        %TextBlock = [1499 1513 1488 1514 47 1492 32 1502 1493 1499 1504 47 1492 32 1504 1513 1500 1497 1501 32 1505 1497 1489 1493 1489 32 1504 1493 1505 1507 32 1513 1500 32 1488 1493 1514 1492 32 1502 1496 1500 1492 10 1500 1495 1510 47 1497 32 1506 1500 32 1502 1511 1513 32 1499 1500 1513 1492 1493 32 1499 1491 1497 32 1500 1492 1502 1513 1497 1498 46];
        DrawFormattedText(w, TextBlock{8} , 'center', 'center', white, 0, 0, 0, 1.4)
        Screen('Flip',w);
        
        noresp=1;
        while noresp,
            [keyIsDown,~,~] = KbCheck;
            if keyIsDown && noresp,
                noresp=0;
            end;
        end;
                
    else
        %TextBlock = [1495 1500 1511 32 1494 1492 32 1492 1505 1514 1497 1497 1501 10 1488 1504 1488 32 1511 1512 1488 32 1500 1504 1505 1497 1497 1503 46];
        if strcmp(Kind, 'day1_probe') || strcmp(Kind, 'day2_probe') || strcmp(Kind, 'day3_probe')
            DrawFormattedText(w, TextBlock{9} , 'center', 'center', white, 0, 0, 0, 1.4)
        elseif strcmp(Kind, 'day1_probe_demo') || strcmp(Kind, 'day2_probe_demo') || strcmp(Kind, 'day3_probe_demo')
            DrawFormattedText(w, TextBlock{7} , 'center', 'center', white, 0, 0, 0, 1.4)
        end
        Screen('Flip',w);
        
        noresp=1;
        while noresp,
            [keyIsDown,~,~] = KbCheck;
            if keyIsDown && noresp,
                noresp=0;
            end;
        end;
        
    end % end if mod(block,2) == 1
    
    WaitSecs(0.1);
    
end

%---------------------------------------------------------------
%%   save data to a .mat file & close out
%---------------------------------------------------------------
if strcmp(Kind, 'day1_probe')
    outfile = strcat(outputPath,'/', sprintf('%s_day1_probe_%s.mat',subjectID,timestamp));
elseif strcmp(Kind, 'day2_probe')
    outfile = strcat(outputPath,'/', sprintf('%s_day2_probe_%s.mat',subjectID,timestamp));
elseif strcmp(Kind, 'day3_probe')
    outfile = strcat(outputPath,'/', sprintf('%s_day3_probe_%s.mat',subjectID,timestamp));
elseif strcmp(Kind, 'day1_probe_demo')
    outfile = strcat(outputPath,'/', sprintf('%s_day1_probe_demo_%s.mat',subjectID,timestamp));
elseif strcmp(Kind, 'day2_probe_demo')
    outfile = strcat(outputPath,'/', sprintf('%s_day2_probe_demo_%s.mat',subjectID,timestamp));
elseif strcmp(Kind, 'day3_probe_demo')
    outfile = strcat(outputPath,'/', sprintf('%s_day3_probe_demo_%s.mat',subjectID,timestamp));
end
% create a data structure with info about the run
run_info.subject=subjectID;
run_info.date=date;
run_info.outfile=outfile;
run_info.script_name=mfilename;
%save(outfile);
clear doors_items VillageImage VillageImageAlpha PathImage PathImageAlpha HouseImage HouseImageAlpha DoorsAlpha
save(outfile, '-regexp', '^(?!(context_items|CroppedContextsItems)$).')
%---------------------------------------------------------------

fclose(fid1); % Close the txt data file.

KbQueueFlush;

Screen('CloseAll');
ShowCursor;
WaitSecs(1);

end % end function