function [] = RCC_training(subjectID, mainPath,runInd,total_num_runs_training, ChosenLanguage, Kind)

% function [] = RCC_training(subjectID, mainPath,runInd,total_num_runs_training, ChosenLanguage, Kind)
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
% ==================== by Rani Gera January 2017 ====================
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

% FOR TIME MEASUREMENTS IN DEBUGGING:
%tempNeutralAssinment = [];
%tempGoodAssignment =[];
%tempContextsTime =[];
%tempInContext=[];
%tempMoneyAppearing = [];
%tempFtime = [];
%tempMoneyTime=[];
%tempContextTime=[];
%tempLastInd=[];

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

outputPath = [mainPath '/Output'];

% about timing
c = clock;
hr = sprintf('%02d', c(4));
minutes = sprintf('%02d', c(5));
timestamp = [date,'_',hr,'h',minutes,'m'];

% about timing
image_duration = 1; %because stim duration is 1.5 secs in opt_stop
baseline_fixation = 1;
afterrunfixation = 1;

%about language:
TextBlock = Language(ChosenLanguage, Kind);% mfilename gets the name of the running function;

%about MATLAB Version
Versions = ver;
% Find the right line to look at in the struct:
index = find(strcmp({Versions.Name}, 'MATLAB')==1);
MatlabVersion = Versions(index).Release;
InTestingRooms = strfind(MatlabVersion,'2014');

OS_Version = system_dependent('getos');
Is_El_Capitan_Or_Newer = ~isempty(strfind(OS_Version,'10.11')) || ~isempty(strfind(OS_Version,'10.12'));

%---------------------------------------------------------------
%%  PARAMETERS 
%---------------------------------------------------------------

% about contexts and rewards
if strcmp(Kind, 'day1_training') || strcmp(Kind, 'day2_training')
    num_of_contexts = 9; % may use 1/2/other for debugging.
    ContingencyOfReinforcedContexts = 1/3; % 25% of the contexts will be reinforced!
    %for debugging:
    %num_of_contexts = 2; % may use 1/2/other for debugging.
    %ContingencyOfReinforcedContexts = 0.5; % 25% of the contexts will be reinforced!
elseif strcmp(Kind, 'day1_training_demo')
    num_of_contexts = 2; % may use 1/2/other for debugging.
    ContingencyOfReinforcedContexts = 0.5; % 25% of the contexts will be reinforced!
elseif strcmp(Kind, 'day2_training_demo')
    % LOADING THE HAPPY/SAD CONTEXTS FOR THIS SUBJECT ***
    % - - - - - - - - - - - - - - -  - - - - - - - - - - - - - - - - - - - -
    %num_of_contexts = sum(RelevantStimuliList{:,2}==11); % may use 1/2/other for debugging.
    %ContingencyOfReinforcedContexts = 1; % 25% of the contexts will be reinforced!
elseif strcmp(Kind, 'day3_reinstatement')
    num_of_contexts = 6; % may use 1/2/other for debugging.
    num_of_contexts_for_neighborhood = 9;
    ContingencyOfReinforcedContexts = 1; % 25% of the contexts will be reinforced!
elseif strcmp(Kind, 'day3_random_houses')
    num_of_contexts = 3; % may use 1/2/other for debugging.
    ContingencyOfReinforcedContexts = 0; % 25% of the contexts will be reinforced!
end
num_of_reinforced_contexts = round(num_of_contexts * ContingencyOfReinforcedContexts);

% about stimuli(fractals)/steps
steps_per_context = 3; % The actual number will be after the reduction of the assignment from the number defined here. i.e. assignment is instead of a fractal.
% Contingencies:
if strcmp(Kind, 'day2_training_demo') || strcmp(Kind, 'day3_random_houses')
    rewardContingency = 0;
else
    rewardContingency = 2/3;
end

AssignmentContingency = 1/3; % 0.5 for debugging
num_rewards_per_context = rewardContingency * steps_per_context;

give_reward = [1 2 1]; % 1 = "free money" in the paired contexts. 2 = assignment.

% Time Parameter/s:
% ---------------------------
TimeToPressTheSequence = 1.5;

% About Reward
% creating the randomize rewards matrix:
if strcmp(Kind, 'day1_training') || strcmp(Kind, 'day3_reinstatement') || strcmp(Kind, 'day2_training')
    Rewards_Vector = RandomizeRewards(18, 7, 29, num_rewards_per_context * num_of_reinforced_contexts * total_num_runs_training); % RandomizeRewards(RequiredMean, minSum, maxSum, VecLength)
    if strcmp(Kind, 'day2_training')
        Rewards_Vector = -Rewards_Vector;
    end
elseif strcmp(Kind, 'day1_training_demo')
    Rewards_Vector = [11 25 11 25];
end
% initiate reward variables:
accumulated_money = 0;
Rewards_Vector_Placer = 1;

% Control Key:       [used in demo for now so the experimenter can explain before another round begins]
% ---------------------------
ExperimenterControlKey = 'Z';
%--------------------------------------------------------------------------
%% PARAMETERS FOR THE CONTEXTS SIZE AND LOCATION (without the floor)
%--------------------------------------------------------------------------
StartingPointOnX = 0;
StartingPointOnY = 0;
StimuliWidthScaleFactor = 1;
StimuliHeightScaleFactor = 0.8361;

%% Assigning Group of Contexts variables
%-----------------------------------------------
[PairedStimuli, UnpairedStimuli, PairedColor, UnpairedColors] = AssignStimuli(subjectID,outputPath);

% -----------------------------------------------
%% Load Instructions
% -----------------------------------------------
% Optional - Make here the hebrew vectors with different names.
% -----------------------------------------------
%% 'INITIALIZE SCREEN'
%---------------------------------------------------------------

Screen('Preference', 'VisualDebuglevel', 3); %No PTB intro screen
screennum = min(Screen('Screens')); % max at the Lab !
%screennum = min(Screen('Screens')); %for debugging in a connected screen

pixelSize=32;
%[w] = Screen('OpenWindow',screennum,[],[0 0 640 480],pixelSize);% %debugging screensize%
[w] = Screen('OpenWindow',screennum,[],[],pixelSize);

% screen refresh rate
flip_interval=Screen('GetFlipInterval',w);

% Get the size of the on screen window
[screenXpixels, screenYpixels] = Screen('WindowSize', w);
% Set up alpha-blending
Screen('BlendFunction', w, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

%   colors
% - - - - - -
black = BlackIndex(w); % Should equal 0.
white = WhiteIndex(w); % Should equal 255.
Green = [0 255 0];
Red = [255 0 0];
Blue = [0 0 255];
Colors = {[0,200,0] [200,0,0]}; % for highlighting the amount won or loss
%Welcome_Color = [76,145,240]; %Blueish...
% a factor to manipulate the order in changing colors texts
if strcmp(Kind, 'day1_training') || strcmp(Kind, 'day1_training_demo') || strcmp(Kind, 'day3_reinstatement') || strcmp(Kind, 'day3_random_houses')
    ColoringOrderFactor = -2;
elseif strcmp(Kind, 'day2_training')
    ColoringOrderFactor = -1;
end

Screen('FillRect', w, black);
Screen('Flip', w);

%   text
% - - - - - -
theFont = 'Arial';
Screen('TextSize',w,40);
Screen('TextFont',w,theFont);
Screen('TextColor',w,white);


WaitSecs(1);
HideCursor;

% -------------------------------------------------------
%% 'Visual Cues settings'
%---------------------------------------------------------------
% REWARD
%++++++++++++++++++++++++++++

% Load cue image
if strcmp(Kind, 'day1_training') || strcmp(Kind, 'day1_training_demo') || strcmp(Kind, 'day3_reinstatement') || strcmp(Kind, 'day3_random_houses')
    CueImageLocation = './Misc/rewards/coins.png';
elseif strcmp(Kind, 'day2_training')
    CueImageLocation = './Misc/rewards/losing_coins.png';
end
[CueImage, ~, CueImageAlpha] = imread(CueImageLocation);

% Place the transparency layer of the foreground image into the 4th (alpha)
% image plane. This is the bit which is needed, else the tranparent
% background will be non-transparent
transparencyFactor=1;  %change this factor to manipulate cue's transparency
CueImage(:, :, 4) = CueImageAlpha*transparencyFactor    ;

% Get the size of the Cue
[CueHight, CueWidth, ~] = size(CueImage);

% Scale the destination rectangle up to make the foreground image bigger
% (the key image is small, so we scale it here else it is hard to see)
scaleFactor = 1.5; %change this factor to manipulate cue's size
dstRectCue = CenterRectOnPointd([0 0 CueWidth CueHight] .* scaleFactor, screenXpixels / 2, screenYpixels / 2);

% Make the images into a texture
imageTextureCue = Screen('MakeTexture', w, CueImage);

Cue_Y_final_position = -50;
Cue_Y_initial_position = 50;
%General animation settings for welcome screen:
Cue_animation_position_steps = 20; % How many changes in position for the animation.
Cue_Y_animation_vector = linspace(Cue_Y_initial_position,Cue_Y_final_position,Cue_animation_position_steps);

%++++++++++++++++++++++++++++
%% The Assginment - Intializing
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%   Making the Arrows files list
% - - - - - - - - - - - - - - - -
images=dir('./Misc/assignment/Good/NewArrows*.png');
ValuableAssignmentArrows{1} = cell((Struct2Vect(images,'name'))');
clear images

%   reading in images
%---------------------------
ValuableArrow_items = cell(1, length(ValuableAssignmentArrows{1}));
ValuableArrowAlpha = cell(1, length(ValuableAssignmentArrows{1}));
imageTextureArrow = zeros(1,length(ValuableAssignmentArrows{1}));

ValuableArrowTransparencyFactor=1;  %change this factor to manipulate cue's transparency

for i = 1:length(ValuableAssignmentArrows{1})
    [ValuableArrow_items{i}, ~,ValuableArrowAlpha{i}] = imread(sprintf('Misc/assignment/Good/%s',ValuableAssignmentArrows{1}{i}));
    ValuableArrow_items{i}(:, :, 4) = ValuableArrowAlpha{i}*ValuableArrowTransparencyFactor;
    imageTextureArrow(i) = Screen('MakeTexture', w, ValuableArrow_items{i});
end

% Get the size of the Arrows
[ValuableArrowHeight, ValuableArrowWidth, ~] = size(ValuableArrow_items{1});

scaleFactorArrow = 0.5; %change this factor to manipulate arrows' size
LeftArrowsPosition = CenterRectOnPointd([0 0 ValuableArrowWidth ValuableArrowHeight] .* scaleFactorArrow,...
    screenXpixels / 7, screenYpixels / 2);
RightArrowsPosition = CenterRectOnPointd([0 0 ValuableArrowWidth ValuableArrowHeight] .* scaleFactorArrow,...
    screenXpixels / (7/6), screenYpixels / 2);

%++++++++++++++++++++++++++++
% Animated colomns for the assignment
%++++++++++++++++++++++++++++
HappyColumnImageLocation = './Misc/assignment/Good/HappyColumn.png';
[HappyColumnImage, ~, HappyColumnImageAlpha] = imread(HappyColumnImageLocation);
ColumnTransparencyFactor=1;  %change this factor to manipulate cue's transparency
HappyColumnImage(:, :, 4) = HappyColumnImageAlpha*ColumnTransparencyFactor    ;
% Get the size of image
[ColumnHight, ColumnWidth, ~] = size(HappyColumnImage);
scaleFactorColumns = 1.2; %change this factor to manipulate cue's size
LeftColumnPosition = CenterRectOnPointd([0 0 ColumnWidth/2 ColumnHight/2] .* scaleFactorColumns,...
    screenXpixels / 7, screenYpixels / 2);
RightColumnPosition = CenterRectOnPointd([0 0 ColumnWidth/2 ColumnHight/2] .* scaleFactorColumns,...
    screenXpixels / (7/6), screenYpixels / 2);
% Make the images into a texture
imageTextureColumn = Screen('MakeTexture', w, HappyColumnImage);

%++++++++++++++++++++++++++++
% Black background for the assignments
%++++++++++++++++++++++++++++
AssignmentBlackBackgroundImageLocation = './Misc/assignment/BlackBackgroundForAssignment.png';
[AssignmentBlackBackgroundImage, ~, AssignmentBlackBackgroundImageAlpha] = imread(AssignmentBlackBackgroundImageLocation);
AssignmentBlackBackgroundTransparencyFactor=1;
AssignmentBlackBackgroundImage(:, :, 4) = AssignmentBlackBackgroundImageAlpha * AssignmentBlackBackgroundTransparencyFactor    ;
% Get the size of image
[AssignmentBlackBackgroundHight, AssignmentBlackBackgroundWidth, ~] = size(AssignmentBlackBackgroundImage);
scaleFactorAssignmentBlackBackground = 1; %change this factor to manipulate cue's size
AssignmentBlackBackgroundPosition = CenterRectOnPointd([0 0 AssignmentBlackBackgroundWidth*0.9 AssignmentBlackBackgroundHight*0.6] .* scaleFactorAssignmentBlackBackground, screenXpixels / 2, screenYpixels * 0.525);
if ~isempty(InTestingRooms) %i.e. if the experiment is in the testing rooms (matlab 2014 version)
    AssignmentBlackBackgroundPosition = AssignmentBlackBackgroundPosition + [0, -10, 0 ,-10];
end
% Make the images into a texture
imageTextureAssignmentBlackBackground = Screen('MakeTexture', w, AssignmentBlackBackgroundImage);

%++++++++++++++++++++++++++++
% Floor (of the inside of the houses)
%++++++++++++++++++++++++++++
FloorImageLocation = './Misc/Floor/floor.png';
[FloorImage, ~, FloorImageAlpha] = imread(FloorImageLocation);
FloorTransparencyFactor=1;
FloorImage(:, :, 4) = FloorImageAlpha * FloorTransparencyFactor;
% Get the size of image
[FloorHight, ~, ~] = size(FloorImage);
FloorRelativeHeightFactor = FloorHight/1080; %change this factor to manipulate cue's size
FloorStartingPoint = screenYpixels - FloorRelativeHeightFactor*screenYpixels;
FloorPosition = [0 FloorStartingPoint screenXpixels screenYpixels];
% Make the images into a texture
imageTextureFloor = Screen('MakeTexture', w, FloorImage);

%% DOORS ANIMATION SETTINGS (by a script)
%%---------------------------------------------------------------
DoorsAnimationSettings
% Sheep Settings (by a script):
TravelingSheepSettings

%---------------------------------------------------------------
%%   'PRE-TRIAL DATA ORGANIZATION'
%---------------------------------------------------------------

%   Making the contexts files list
% - - - - - - - - - - - - - - -
if strcmp(Kind, 'day1_training') || strcmp(Kind, 'day2_training')
    contexts{1} = [PairedStimuli ; UnpairedStimuli];
elseif strcmp(Kind, 'day1_training_demo')
    images=dir('./Stim/contexts/demo/*.jpg');
    contexts{1} = cell((Struct2Vect(images,'name'))') ;
    contexts{1}=cell(contexts{1}(1:num_of_contexts)); %ONLY FOR DEBUGGING (1:1) or (1:2)!
    clear images
elseif strcmp(Kind, 'day2_training_demo')
    %     contexts{1} = RelevantStimuliList{:,1}(RelevantStimuliList{:,2}==11) ;
    %     clear images
elseif strcmp(Kind, 'day3_random_houses')
    contexts{1} = cell(num_of_contexts,1);
    for i = 1:num_of_contexts
        ProbePath = dir([outputPath '/' subjectID '_day' num2str(i) '_probe*txt']);
        %Removing demo files from the list:
        ProbePathCell = struct2cell(ProbePath);
        IndexOfRelevantProbes = cellfun(@isempty,strfind(ProbePathCell(1,:),'demo'));
        ProbePath = ProbePath(IndexOfRelevantProbes);
        %
        ProbeTable = readtable([outputPath '/' ProbePath(end).name],'Delimiter','\t');
        ProbeUnrelevantComparisonsTable = ProbeTable(ProbeTable.PairType == 0 ,:);
        ProbeRandomComparison = ProbeUnrelevantComparisonsTable(randi(size(ProbeUnrelevantComparisonsTable,1)),:);
        if ProbeRandomComparison.Outcome == 11 %i.e. The left one was chosen
            contexts{1}(i) = ProbeRandomComparison.ImageLeft;
        elseif ProbeRandomComparison.Outcome == 12
            contexts{1}(i) = ProbeRandomComparison.ImageRight;
        else % i.e. the subject did not made a choice
            RightAndLeftArray = Shuffle([ProbeRandomComparison.ImageLeft ProbeRandomComparison.ImageRight]);
            contexts{1}(i) = RightAndLeftArray(1);
        end
    end
end

%  DEFINE THE MANIPULATED CONTEXTS
% - - - - - - - - - - - - - - -  - - - - - - - - - - - - - - - - - - - -

if strcmp(Kind, 'day1_training') || strcmp(Kind, 'day2_training')
    PairedContexts = PairedStimuli;
    if strcmp(Kind, 'day1_training')
        save([outputPath '/' subjectID '_Reinforced_Contexts'],'PairedContexts')
    end
elseif strcmp(Kind, 'day1_training_demo')
    PairedContexts = contexts{1}(2); % so the scond context will be reinforced
elseif strcmp(Kind, 'day3_reinstatement')
    PairedContexts = cell(num_of_contexts,1);
    for i = 1:num_of_contexts
        PairedContexts{i,1} = 'Blank';
    end
elseif strcmp(Kind, 'day3_random_houses')
    PairedContexts = cell(num_of_contexts,1);
    for i = 1:num_of_contexts
        PairedContexts{i,1} = 'None';
    end
end

% SETTINGS FOR THE STIMULI SIZE AND LOCATION
%--------------------------------------------------------------------------
PictureSizeOnX = round(screenXpixels * StimuliWidthScaleFactor);
PictureSizeOnY = round(screenYpixels * StimuliHeightScaleFactor);
PictureLocationVector = [StartingPointOnX, StartingPointOnY, StartingPointOnX + PictureSizeOnX, StartingPointOnY + PictureSizeOnY];
% PictureLocationVector = []; Activate it to draw the picture in the original size and in the center.

%% Croping the contexts settings (for the houses screens)
XCropingFromLeft = round(screenXpixels*0.2344)+1;
XCropingFromRight = screenXpixels - round(screenXpixels*0.2344);
YCropingFromTop = round(screenYpixels*0.3555);
YCropingFromButtom = round(screenYpixels * 0.8361);

%     This next part was cancelled in Version 5 to make the order of the reinforcment
%     presentations the same:
% %--------> Rewards array:
% give_reward_baseline = zeros(1,steps_per_context);
% NumOfRewards = length(give_reward_baseline)*rewardContingency;
% give_reward_baseline(1:NumOfRewards) = 1;
% %--------> Assignment: (Using The same variable)
NumOfAssignments = length(give_reward)*AssignmentContingency;
% give_reward_baseline(NumOfRewards+1:NumOfRewards+NumOfAssignments) = 2;
% % Summary - give_reward_baseline: 1 - calls reward. 2 - calls assignment.

%   Making the fractals files list
% - - - - - - - - - - - - - - -
images=dir('./Stim/fractals/*.jpg');
fractals{1} = cell((Struct2Vect(images,'name'))') ;
clear images

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%% Small Houses Screen Initiation:
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
SmallHousesImageLocation = './Misc/doors/HouseForProbe.png';
[SmallHousesImage, ~, SmallHousesImageAlpha] = imread(SmallHousesImageLocation);
transparencyFactor=1;  %change this factor to manipulate cue's transparency
SmallHousesImage(:, :, 4) = SmallHousesImageAlpha*transparencyFactor    ;
[SmallHousesHeight, SmallHousesWidth, ~] = size(SmallHousesImage);
scaleFactorHomeForSmallHouses = 0.35; %change this factor to manipulate cue's size
SmallHousesSize = [SmallHousesWidth SmallHousesHeight] .* scaleFactorHomeForSmallHouses;
imageTextureSmallHouse = Screen('MakeTexture', w, SmallHousesImage);

SmallHouseStartPointFromEdgesOnX =  2/3 * (screenXpixels/4 - SmallHousesSize(1));
SmallHouseDistancePointsBetweenHousesOnX = 1/3 * (screenXpixels/4 - SmallHousesSize(1));
AdjustingFactoFor9Houses = (screenXpixels - ((screenXpixels/3*2 + SmallHouseDistancePointsBetweenHousesOnX+SmallHousesSize(1)) + SmallHouseStartPointFromEdgesOnX))/2 - SmallHouseStartPointFromEdgesOnX;
if strcmp(Kind, 'day1_training') || strcmp(Kind, 'day2_training') || strcmp(Kind, 'day3_reinstatement') || strcmp(Kind, 'day3_random_houses')
    SmallHousesPositionMatrixOnX = [SmallHouseStartPointFromEdgesOnX+AdjustingFactoFor9Houses  SmallHouseStartPointFromEdgesOnX+SmallHousesSize(1)+AdjustingFactoFor9Houses; screenXpixels/3 + SmallHouseDistancePointsBetweenHousesOnX+AdjustingFactoFor9Houses screenXpixels/3 + SmallHouseDistancePointsBetweenHousesOnX+SmallHousesSize(1)+AdjustingFactoFor9Houses;screenXpixels/3*2 + SmallHouseDistancePointsBetweenHousesOnX+AdjustingFactoFor9Houses screenXpixels/3*2 + SmallHouseDistancePointsBetweenHousesOnX+SmallHousesSize(1)+AdjustingFactoFor9Houses];
elseif strcmp(Kind, 'day1_training_demo')
    SmallHousesPositionMatrixOnX = [SmallHouseStartPointFromEdgesOnX  SmallHouseStartPointFromEdgesOnX+SmallHousesSize(1); screenXpixels/4 + SmallHouseDistancePointsBetweenHousesOnX screenXpixels/4 + SmallHouseDistancePointsBetweenHousesOnX+SmallHousesSize(1);screenXpixels/4*2 + SmallHouseDistancePointsBetweenHousesOnX screenXpixels/4*2 + SmallHouseDistancePointsBetweenHousesOnX+SmallHousesSize(1) ;screenXpixels/4*3 + SmallHouseDistancePointsBetweenHousesOnX screenXpixels/4*3 + SmallHouseDistancePointsBetweenHousesOnX+SmallHousesSize(1)];
end
SmallHousesPositionMatrixOnY = [screenYpixels-SmallHouseStartPointFromEdgesOnX-SmallHousesSize(2) screenYpixels-SmallHouseStartPointFromEdgesOnX ; screenYpixels-SmallHouseStartPointFromEdgesOnX-2*SmallHousesSize(2)-SmallHouseStartPointFromEdgesOnX  screenYpixels-SmallHouseStartPointFromEdgesOnX-SmallHousesSize(2)-SmallHouseStartPointFromEdgesOnX ; screenYpixels-SmallHouseStartPointFromEdgesOnX-3*SmallHousesSize(2)-2*SmallHouseStartPointFromEdgesOnX  screenYpixels-SmallHouseStartPointFromEdgesOnX-2*SmallHousesSize(2)-2*SmallHouseStartPointFromEdgesOnX ];
if strcmp(Kind, 'day1_training_demo')
    SmallHousesPositionMatrixOnX = SmallHousesPositionMatrixOnX(2:3,:);
    SmallHousesPositionMatrixOnY = SmallHousesPositionMatrixOnY(2,:);
%elseif strcmp(Kind, 'day3_reinstatement')
%    SmallHousesPositionMatrixOnY = SmallHousesPositionMatrixOnY(1:2,:);
end
%Small Contexts:
ScaleFactorForSmallContetxts = scaleFactorHomeForSmallHouses / scaleFactorHouses;
SmallCroppedContextsItemsWidth = ScaleFactorForSmallContetxts * (XCropingFromRight-XCropingFromLeft+1);
SmallCroppedContextsItemsHeight = ScaleFactorForSmallContetxts * (YCropingFromButtom-YCropingFromTop+1);
SmallCroppedContextsItemsLocAdjustmentsX = round(0.026*screenXpixels);
SmallCroppedContextsItemsLocAdjustmentsY = round(0.1204*screenYpixels);
%Small Doors:
SmallDoorSize = ScaleFactorForSmallContetxts * [418 550]; %The original training size
SmallDoorAdjustmentsY = round(0.1426 * screenYpixels);
%Path Between Houses:
PathsCentersOnX = (SmallHousesPositionMatrixOnX(:,1) + SmallHousesPositionMatrixOnX(:,2))/2;
PathWidth = round(0.0458 * screenXpixels);
if strcmp(Kind, 'day1_training') || strcmp(Kind, 'day2_training') || strcmp(Kind, 'day3_random_houses') || strcmp(Kind, 'day3_reinstatement')
    PathDrawingMatrix = [PathsCentersOnX'-PathWidth/2  repmat(PathsCentersOnX(1)-PathWidth/2,1,3) ; repmat(screenYpixels*0.3241,1,3) SmallHousesPositionMatrixOnY(:,2)'+20   ; PathsCentersOnX' + PathWidth/2  repmat(PathsCentersOnX(end)-PathWidth/2,1,3); repmat(screenYpixels,1,3)  SmallHousesPositionMatrixOnY(:,2)'+70];
elseif strcmp(Kind, 'day1_training_demo')
    PathDrawingMatrix = [PathsCentersOnX'-PathWidth/2  PathsCentersOnX(1)-PathWidth/2 screenXpixels/2-PathWidth/2; repmat(screenYpixels*0.5,1,2) SmallHousesPositionMatrixOnY(:,2)'+20  SmallHousesPositionMatrixOnY(:,2)'+20 ; PathsCentersOnX' + PathWidth/2  PathsCentersOnX(end)-PathWidth/2 screenXpixels/2+PathWidth/2; repmat(SmallHousesPositionMatrixOnY(:,2)'+70,1,3) screenYpixels];
%elseif strcmp(Kind, 'day3_reinstatement')
%    PathDrawingMatrix = [PathsCentersOnX'-PathWidth/2  repmat(PathsCentersOnX(1)-PathWidth/2,1,2) ; repmat(screenYpixels*0.3241/(2/3),1,3) SmallHousesPositionMatrixOnY(:,2)'+20   ; PathsCentersOnX' + PathWidth/2  repmat(PathsCentersOnX(end)-PathWidth/2,1,2); repmat(screenYpixels,1,3)  SmallHousesPositionMatrixOnY(:,2)'+70];
end
PathBordersDrawingMatrix = [PathDrawingMatrix(1,:) - 2 ; PathDrawingMatrix(2,:) - 2 ; PathDrawingMatrix(3,:) + 2 ; PathDrawingMatrix(4,:) + 2 ];


%--------------------------------------------------
%% Initialize Sound:
%--------------------------------------------------
InitializePsychSound(1);  %initializes sound driver...the 1 pushes for low latency
PsychPortAudio('Close');% CLOSE ANY EXISTED BUFFERS. USE WITHOUT THE PAHANDLE HERE IS VERY IMPORTANT!!!!
%++++++++++++++++++++++++++++
%Constant Money Winning Sound
%++++++++++++++++++++++++++++
if strcmp(Kind, 'day1_training') || strcmp(Kind, 'day1_training_demo') || strcmp(Kind, 'day3_reinstatement') || strcmp(Kind, 'day3_random_houses')
    sound = dir('./Misc/rewards/ConstantMoneyWon.wav');
elseif strcmp(Kind, 'day2_training')
    sound = dir('./Misc/rewards/ConstantMoneyLose.wav');
end
[ConstantMoneySound] = audioread(sprintf('Misc/rewards/%s',sound.name)); % load sound file (make sure that it is in the same folder as this script
if strcmp(Kind, 'day1_training') || strcmp(Kind, 'day1_training_demo') || strcmp(Kind, 'day3_reinstatement') || strcmp(Kind, 'day3_random_houses')
    ConstantMoneySound_pahandle = PsychPortAudio('Open', [], [], 2, 10000, 1); % opens sound buffer at a different frequency
elseif strcmp(Kind, 'day2_training')
    ConstantMoneySound_pahandle = PsychPortAudio('Open', [], [], 2, 43537, 2); % opens sound buffer at a different frequency
end
PsychPortAudio('FillBuffer', ConstantMoneySound_pahandle, ConstantMoneySound'); % loads data into buffer. The time of this Playback is between 0.5-0.53 Secs

%++++++++++++++++++++++++++++
%Neutral Welcome Sound
%++++++++++++++++++++++++++++
sound = dir('./Misc/assignment/Neutral/NeutralWelcome.wav');
[NeutralWelcome] = audioread(sprintf('Misc/assignment/Neutral/%s',sound.name)); % load sound file (make sure that it is in the same folder as this script
NeutralWelcome_pahandle = PsychPortAudio('Open', [], [], 2, 19000, 1); % opens sound buffer at a different frequency
PsychPortAudio('FillBuffer', NeutralWelcome_pahandle, NeutralWelcome'); % loads data into buffer. The time of this Playback is between 0.5-0.53 Secs
%PsychPortAudio('Start', NeutralWelcome_pahandle); %Play to check the sound at the begining...
%++++++++++++++++++++++++++++
%Door Sound
%++++++++++++++++++++++++++++
sound = dir('./Misc/doors/OpeningDoorSound.wav');
[DoorSound] = audioread(sprintf('Misc/doors/%s',sound.name)); % load sound file (make sure that it is in the same folder as this script
DoorSound_pahandle = PsychPortAudio('Open', [], [], 2, 40000, 2); % opens sound buffer at a different frequency
PsychPortAudio('FillBuffer', DoorSound_pahandle, DoorSound'); % loads data into buffer. The time of this Playback is between 0.5-0.53 Secs
%---------------------------------------------------------------
%% 'Display Main Instructions'
%---------------------------------------------------------------

Screen('TextSize',w, 70);
Screen('TextStyle',w ,1);
DrawFormattedText(w, TextBlock{1} , 'center', screenYpixels*0.15, [50 255 50])
Screen('TextSize',w, 45);
Screen('TextStyle',w ,1);
DrawFormattedText(w, TextBlock{2} , 'center', screenYpixels*0.30, [255 255 255],  0, 0, 0, 1.2)
Screen('TextStyle',w ,0);
DrawFormattedText(w, TextBlock{3} , 'center', screenYpixels*0.50, [255 255 255],  0, 0, 0, 1.2)
Screen('TextStyle',w ,1);
DrawFormattedText(w, TextBlock{4} , 'center', screenYpixels*0.77, [255 255 255])
Screen('TextStyle',w ,0);
DrawFormattedText(w, TextBlock{5} , 'center', screenYpixels*0.82, [50 255 50])
Screen(w,'Flip');

Screen('TextSize',w,40); % return to normal size

noResponse=1;
while noResponse
    [keyIsDown,~,~] = KbCheck; %(experimenter_device);
    if keyIsDown && noResponse
        noResponse=0;
    end;
end;
WaitSecs(0.001);

%---------------------------------------------------------------
%%  'TRIAL PRESENTATION'
%---------------------------------------------------------------

% Setting the size of the variables for the loop
%---------------------------
shuff_contexts = cell(1,total_num_runs_training);
shuff_ind_contexts = cell(1,total_num_runs_training);
shuff_names = cell(1,total_num_runs_training);
shuff_ind = cell(1,total_num_runs_training);
Cue_time = cell(1,total_num_runs_training);
actual_onset_time = cell(1,total_num_runs_training);
fix_time = cell(1,total_num_runs_training);
fixcrosstime = cell(1,total_num_runs_training);

%%%%% everything related to those was made for debugging purposes:
AssignmentNum = 1;
AssignmentFollow = cell(total_num_runs_training*length(shuff_contexts{1})*NumOfAssignments,30);

anchor = GetSecs ; % (before baseline fixation) ;

%  for runNum = runInd:runInd+3; % for debugging 4 runs starting with runInd
for runNum = runInd:total_num_runs_training %this for loop allows all runs to be completed    
    
    %   'Write output file header'
    %---------------------------------------------------------------
    c = clock;
    hr = sprintf('%02d', c(4));
    minutes = sprintf('%02d', c(5));
    timestamp = [date,'_',hr,'h',minutes,'m'];
    
    if strcmp(Kind, 'day1_training')
        fid1 = fopen([outputPath '/' subjectID '_day1_training_run_' sprintf('%02d',runNum) '_' timestamp '.txt'], 'a');
        fprintf(fid1,'subjectID\trunNum\tcontext\tIsHappy\tTrialType\titemName\tonsetTime\tCueWasPresented\tCueTime\tWasAssignment\tNoRespone\tTimeOfSuccess\tfixationTime\tMoneyAccumulated\n'); %write the header line
    elseif strcmp(Kind, 'day2_training')
        fid1 = fopen([outputPath '/' subjectID '_day2_training_run_' sprintf('%02d',runNum) '_' timestamp '.txt'], 'a');
        fprintf(fid1,'subjectID\trunNum\tcontext\tIsSad\tTrialType\titemName\tonsetTime\tCueWasPresented\tCueTime\tWasAssignment\tNoRespone\tTimeOfSuccess\tfixationTime\tMoneyAccumulated\n'); %write the header line
    elseif strcmp(Kind, 'day3_reinstatement')
        fid1 = fopen([outputPath '/' subjectID '_day3_reinstatement_run_' sprintf('%02d',runNum) '_' timestamp '.txt'], 'a');
        fprintf(fid1,'subjectID\trunNum\tcontext\tIsHappy\tTrialType\titemName\tonsetTime\tCueWasPresented\tCueTime\tWasAssignment\tNoRespone\tTimeOfSuccess\tfixationTime\tMoneyAccumulated\n'); %write the header line
    elseif strcmp(Kind, 'day1_training_demo')
        fid1 = fopen([outputPath '/' subjectID '_day1_trainingDemo_run_' sprintf('%02d',runNum) '_' timestamp '.txt'], 'a');
        fprintf(fid1,'subjectID\tcontext\tIsHappy\tTrialType\titemName\tonsetTime\tCueWasPresented\tCueTime\tWasAssignment\tNoRespone\tTimeOfSuccess\tfixationTime\n'); %write the header line
     elseif strcmp(Kind, 'day3_random_houses')
        fid1 = fopen([outputPath '/' subjectID '_day3_random_houses_run_' timestamp '.txt'], 'a');
        fprintf(fid1,'subjectID\tcontext\tIsHappy\tTrialType\titemName\tonsetTime\tCueWasPresented\tCueTime\tWasAssignment\tNoRespone\tTimeOfSuccess\tfixationTime\n'); %write the header line
    end
    
    
    
    %   'pre-trial fixation'
    %---------------------------
    
    firstOrSecond = mod(runNum,2);
    
    switch firstOrSecond
        case 1
            prebaseline = GetSecs;
            % baseline fixation - currently 10 seconds = 4*Volumes (2.5 TR)
            while GetSecs < prebaseline + baseline_fixation
                %CenterText(w,'+', white,0,-30);
                Screen('TextSize',w, 60);
                Screen(w,'Flip');
            end
        case 0
            prebaseline = GetSecs;
            % baseline fixation - currently 10 seconds = 4*Volumes (2.5 TR)
            while GetSecs < prebaseline + afterrunfixation
                %CenterText(w,'+', white,0,-30);
                Screen('TextSize',w, 60);
                Screen(w,'Flip');
            end
    end
    
    if strcmp(Kind, 'day1_training') || strcmp(Kind, 'day2_training') || strcmp(Kind, 'day3_random_houses')
        [shuff_contexts{runNum},shuff_ind_contexts{runNum}] = Shuffle(contexts{1});
    elseif strcmp(Kind, 'day1_training_demo')
        shuff_contexts{runNum} = contexts{1};
    elseif strcmp(Kind, 'day3_reinstatement')
        shuff_contexts{runNum} = PairedContexts;
    end
    
    %   reading in contexts
    %---------------------------
    context_items = cell(1, length(shuff_contexts{runNum}));
    
    if strcmp(Kind, 'day1_training') || strcmp(Kind, 'day2_training') || strcmp(Kind, 'day3_random_houses')
        for i = 1:length(shuff_contexts{runNum})
            context_items{i} = imread(sprintf('stim/contexts/%s',shuff_contexts{runNum}{i}));
        end
    elseif strcmp(Kind, 'day1_training_demo')
        for i = 1:length(shuff_contexts{runNum})
            context_items{i} = imread(sprintf('stim/contexts/demo/%s',shuff_contexts{runNum}{i}));
        end
    elseif strcmp(Kind, 'day3_reinstatement')
        for i = 1:length(shuff_contexts{runNum})
            context_items{i} = uint8(zeros(round(screenYpixels*0.8361),screenXpixels,3));
        end
    end

    %   Making the cropped contexts accordingly
    %---------------------------
    CroppedContextsItems = cell(1,length(context_items));
    for i = 1 : length(context_items)
        CroppedContextsItems{i} = context_items{i}(YCropingFromTop:YCropingFromButtom,XCropingFromLeft:XCropingFromRight,:); %The cropping variables are defined inside DoorsAnimationSettings.m
    end
    
    %  Presenting 'All the houses' screen
    %----------------------------------------
    if (runNum == runInd || strcmp(Kind, 'day1_training_demo')) && ~strcmp(Kind, 'day3_random_houses')
        if strcmp(Kind, 'day1_training') || (strcmp(Kind, 'day1_training_demo') && total_num_runs_training == 2) % i.e. the first demo of the first day.
            [ShuffledCroppedContextsItemsForSmallHouses, ShuffledCroppedContextsItemsForSmallHousesIND] = Shuffle(CroppedContextsItems);
            Day1AllHousesOrder = shuff_contexts{runNum}(ShuffledCroppedContextsItemsForSmallHousesIND);
            save([outputPath '/' subjectID '_NeighborhoodOrder_' Kind],'Day1AllHousesOrder')
        elseif strcmp(Kind, 'day2_training')
            load([outputPath '/' subjectID '_NeighborhoodOrder_day1_training'],'Day1AllHousesOrder')
            ShuffledCroppedContextsItemsForSmallHouses = cell(1, length(Day1AllHousesOrder));
            for i = 1:length(shuff_contexts{runNum})
                ShuffledCroppedContextsItemsForSmallHouses{i} = imread(sprintf('stim/contexts/%s',Day1AllHousesOrder{i}));
                ShuffledCroppedContextsItemsForSmallHouses{i} = ShuffledCroppedContextsItemsForSmallHouses{i}(YCropingFromTop:YCropingFromButtom,XCropingFromLeft:XCropingFromRight,:); %The cropping variables are defined inside DoorsAnimationSettings.m
            end
        elseif strcmp(Kind, 'day1_training_demo') && total_num_runs_training == 1 %i.e. The second demo
            load([outputPath '/' subjectID '_NeighborhoodOrder_day1_training_demo'],'Day1AllHousesOrder')
            ShuffledCroppedContextsItemsForSmallHouses = cell(1, length(Day1AllHousesOrder));
            for i = 1:length(shuff_contexts{runNum})
                ShuffledCroppedContextsItemsForSmallHouses{i} = imread(sprintf('stim/contexts/demo/%s',Day1AllHousesOrder{i}));
                ShuffledCroppedContextsItemsForSmallHouses{i} = ShuffledCroppedContextsItemsForSmallHouses{i}(YCropingFromTop:YCropingFromButtom,XCropingFromLeft:XCropingFromRight,:); %The cropping variables are defined inside DoorsAnimationSettings.m
            end
        elseif strcmp(Kind, 'day3_reinstatement')
            ShuffledCroppedContextsItemsForSmallHouses(1:num_of_contexts_for_neighborhood) = CroppedContextsItems(1);
        end
        Screen('FillRect', w , [20 200 20] ,PathBordersDrawingMatrix)
        Screen('FillRect', w , [130 130 130] ,PathDrawingMatrix)
        for i = 1:size(SmallHousesPositionMatrixOnX,1)
            for j = 1:size(SmallHousesPositionMatrixOnY,1)
                Screen('DrawTextures', w, imageTextureSmallHouse, [], [SmallHousesPositionMatrixOnX(i,1), SmallHousesPositionMatrixOnY(j,1) ,SmallHousesPositionMatrixOnX(i,2), SmallHousesPositionMatrixOnY(j,2)]);
                if i==1 && j==1
                    Screen('PutImage',w,ShuffledCroppedContextsItemsForSmallHouses{(i-1)*size(SmallHousesPositionMatrixOnY,1)+j},[SmallHousesPositionMatrixOnX(i,1)+SmallCroppedContextsItemsLocAdjustmentsX, SmallHousesPositionMatrixOnY(j,1)+SmallCroppedContextsItemsLocAdjustmentsY ,SmallHousesPositionMatrixOnX(i,1)+SmallCroppedContextsItemsWidth+SmallCroppedContextsItemsLocAdjustmentsX, SmallHousesPositionMatrixOnY(j,1)+SmallCroppedContextsItemsHeight+SmallCroppedContextsItemsLocAdjustmentsY]);
                elseif j ~= 1 && i ~= 1
                    Screen('PutImage',w,ShuffledCroppedContextsItemsForSmallHouses{(i-1)*size(SmallHousesPositionMatrixOnY,1)+j},[SmallHousesPositionMatrixOnX(i,1)+SmallCroppedContextsItemsLocAdjustmentsX-1, SmallHousesPositionMatrixOnY(j,1)+SmallCroppedContextsItemsLocAdjustmentsY-1 ,SmallHousesPositionMatrixOnX(i,1)+SmallCroppedContextsItemsWidth+SmallCroppedContextsItemsLocAdjustmentsX-1, SmallHousesPositionMatrixOnY(j,1)+SmallCroppedContextsItemsHeight+SmallCroppedContextsItemsLocAdjustmentsY-1]);
                elseif j ~= 1
                    Screen('PutImage',w,ShuffledCroppedContextsItemsForSmallHouses{(i-1)*size(SmallHousesPositionMatrixOnY,1)+j},[SmallHousesPositionMatrixOnX(i,1)+SmallCroppedContextsItemsLocAdjustmentsX, SmallHousesPositionMatrixOnY(j,1)+SmallCroppedContextsItemsLocAdjustmentsY-1 ,SmallHousesPositionMatrixOnX(i,1)+SmallCroppedContextsItemsWidth+SmallCroppedContextsItemsLocAdjustmentsX, SmallHousesPositionMatrixOnY(j,1)+SmallCroppedContextsItemsHeight+SmallCroppedContextsItemsLocAdjustmentsY-1]);
                elseif i ~= 1
                    Screen('PutImage',w,ShuffledCroppedContextsItemsForSmallHouses{(i-1)*size(SmallHousesPositionMatrixOnY,1)+j},[SmallHousesPositionMatrixOnX(i,1)+SmallCroppedContextsItemsLocAdjustmentsX-1, SmallHousesPositionMatrixOnY(j,1)+SmallCroppedContextsItemsLocAdjustmentsY ,SmallHousesPositionMatrixOnX(i,1)+SmallCroppedContextsItemsWidth+SmallCroppedContextsItemsLocAdjustmentsX-1, SmallHousesPositionMatrixOnY(j,1)+SmallCroppedContextsItemsHeight+SmallCroppedContextsItemsLocAdjustmentsY]);
                end
                Screen('DrawTextures', w, imageTextureDoor(1), [], [(SmallHousesPositionMatrixOnX(i,2)+SmallHousesPositionMatrixOnX(i,1))/2-SmallDoorSize(1)/2, SmallHousesPositionMatrixOnY(j,1) + SmallDoorAdjustmentsY ,(SmallHousesPositionMatrixOnX(i,2)+SmallHousesPositionMatrixOnX(i,1))/2+SmallDoorSize(1)/2, SmallHousesPositionMatrixOnY(j,1)+SmallDoorSize(2) + SmallDoorAdjustmentsY] , 0);
            end
        end
        Screen('TextSize',w, 45);
        DrawFormattedText(w, TextBlock{6} , 'center', screenYpixels*0.01, [255 255 255])
        Screen('Flip',w,0,1);
        % Play welcome sound
        PsychPortAudio('Start', NeutralWelcome_pahandle); % Play the Welcome Sound

        
        noResponse=1;
        while noResponse
            [keyIsDown,~,~] = KbCheck; %(experimenter_device);
            if keyIsDown && noResponse
                while keyIsDown
                    [keyIsDown,~,~] = KbCheck;
                end
                noResponse=0;
            end;
        end;
        Screen('FillRect', w , black ,[0, 0 , screenXpixels , floor(SmallHousesPositionMatrixOnY(end,1)+round(0.0111*screenYpixels))])
        DrawFormattedText(w, TextBlock{23} , 'center', screenYpixels*0.02, [255 255 255])
        Screen('Flip',w);
        WaitSecs(7);
        Screen('TextSize',w, 60);
    end
    %tempStartAllContexts = GetSecs;
    % NEW LOOP HERE:
    for blockNum = (1:length(shuff_contexts{runNum})) % In each block the context changes.
        
        
        %This next part was cancelled in Version 5 to make the order of the reinforcment
        %presentations the same:     
%         if strcmp(Kind, 'day1_training')
%             %* 'Randomize the array of rewards and assignments (and fractals) for the "happy_context" or the other contexts
%             %---------------------------
%             give_reward = Shuffle(give_reward_baseline); %1Notchanging between contexts!!! change location and check other randimazations!!!! % 1 calls reward, 2 calls assignment.
%         elseif strcmp(Kind, 'day1_training_demo')
%             %Defining Arrays alternatives for the demo:
%             if blockNum == 1 % This loop was made so all demos for all subjects will be the same.
%                 give_reward = [1 1 2 1];
%             elseif blockNum == 2
%                 give_reward = [1 2 1 1];
%             elseif blockNum == 3 % This loop was made so all demos for all subjects will be the same.
%                 give_reward = [2 1 1 1];
%             elseif blockNum == 4
%                 give_reward = [1 2 1 1];
%             end
%         end
% 
%         % The next loop is for preventing 2 assignment in a raw. it will shuffle again until it will be separated.
%         flag = 1;
%         while flag
%             for i = 1:length(give_reward)-1
%                 if give_reward(i) + give_reward(i+1) == 4
%                     give_reward = Shuffle(give_reward_baseline);
%                     break
%                 elseif i == length(give_reward)-1
%                     flag = 0;
%                 end
%             end
%         end
        
        %   'load onsets'
        %---------------------------
        %r = Shuffle(1:4);
        %load(['Onset_files/train_onset_' num2str(r(1)) '.mat']);
        %load('Onset_files/train_onset_1.mat'); % for debugging
        onsets = [1.5 3 4.5];
        
%         if runNum == runInd || blockNum~=1
%             if runNum == runInd && blockNum == 1 % If it's the first block in the first run
%                 %TextBlock = [1489 1512 1490 1506 32 1513 1488 1514 47 1492 32 1502 1493 1499 1503 47 1492 32 1514 1495 1500 47 1497 32 1489 1505 1497 1493 1512 46 10 10 1500 1495 1509 47 1497 32 1506 1500 32 1502 1511 1513 32 1499 1500 1513 1492 1493 32 1499 1491 1497 32 1500 1492 1497 1499 1504 1505 32 1500 1495 1491 1512 32 1492 1512 1488 1513 1493 1503 46];
%                 Screen('PutImage', w, TravelingSheep, SheepPosition);
%                 Screen('TextStyle', w, 1);
%                 DrawFormattedText(w, TextBlock{7} , 'center', screenYpixels*0.10, [255 255 255], 0, 0, 0, 0.65)
%                 Screen('Flip',w);
%                 noresp = 1;
%                 while noresp,
%                     [keyIsDown,~,~] = KbCheck;
%                     if keyIsDown && noresp,
%                         noresp = 0;
%                     end;
%                 end;
%             end
%         end
        TextSizeBeforeRoomEntrance = Screen('TextSize',w);
        %TextBlock = [1489 1512 1490 1506 32 1513 1488 1514 47 1492 32 1502 1493 1499 1503 47 1492 32 1514 1502 1513 1497 1498 47 1497 32 1500 1488 1494 1493 1512 32 1492 1489 1488];
        %DrawFormattedText(w, TextBlock{8} , 'center', screenYpixels*0.15, [255 255 255], 0, 0, 0, 1.2)
        %Screen('DrawTextures', w, imageTextureVillage, [], dstRectVillage);
        Screen('DrawTextures', w, imageTexturePath, [], dstRectPath);
        Screen('DrawTextures', w, imageTextureHouse, [], dstRectHouse);
        Screen('PutImage',w,CroppedContextsItems{blockNum},[XCropingFromLeft-1,YCropingFromTop-1,XCropingFromRight,YCropingFromButtom]);
        Screen('DrawTextures', w, imageTextureDoor(1), [], DoorsPosition , 0);
        PressLetterOfTwo(w,ChosenLanguage)
        Screen('Flip',w);
        for i = 2:length(imageTextureDoor)
            %Screen('DrawTextures', w, imageTextureVillage, [], dstRectVillage);
            Screen('DrawTextures', w, imageTexturePath, [], dstRectPath);
            Screen('DrawTextures', w, imageTextureHouse, [], dstRectHouse);
            Screen('PutImage',w,CroppedContextsItems{blockNum},[XCropingFromLeft-1,YCropingFromTop-1,XCropingFromRight,YCropingFromButtom]);
            Screen('DrawTextures', w, imageTextureDoor(i), [], DoorsPosition , 0);
            PressLetterOfTwo(w,ChosenLanguage,2)
            Screen(w,'Flip');
            WaitSecs(0.04)
            if i == 2
                PsychPortAudio('Start', DoorSound_pahandle);
            end
        end
        WaitSecs(0.1)
        Screen('TextSize',w, TextSizeBeforeRoomEntrance);
        
        
        % indicator for special contexts
        IsHappy = 0;
        %Indicates if it's the special context
        if ismember(shuff_contexts{runNum}{blockNum}, PairedContexts)
            IsHappy = 1;
        end
        
        % Initialize Assignment Timer.
        TimeOfAssignmentsToConsider = 0;
        
        % HERE THE CONTEXT WILL BE PRESENTED FOR THE FIRST TIME:
        Screen('DrawTextures', w, imageTextureFloor, [], FloorPosition , 0);
        Screen('PutImage',w,context_items{blockNum},PictureLocationVector);
        Screen('Flip',w,0,1); % display images according to Onset times
        %WaitSecs(0.5); % I HAVE ADDED THIS
%tempStartContext = GetSecs
       
        
        %   Reading the fractals
        %---------------------------
        [shuff_names{runNum},shuff_ind{runNum}] = Shuffle(fractals{1});
        shuff_names{runNum}=shuff_names{runNum}(1:steps_per_context);
        shuff_ind{runNum}=shuff_ind{runNum}(1:steps_per_context);
                
        %	pre-allocating matrices --- maybe for timing of the responses --- REMOVE LATER
        %---------------------------
        Cue_time{runNum}(1:length(shuff_names{runNum}),1) = 999;
        
        %   reading in images
        %---------------------------
        fractal_items = cell(1, length(shuff_names{runNum}));
        for i = 1:length(shuff_names{runNum})
            fractal_items{i} = imread(sprintf('stim/fractals/%s',shuff_names{runNum}{i}));
        end
        
        %   Loop through all trials in a run
        %---------------------------
        runStartTime = GetSecs - anchor;
        
        % tempStartContextTime = GetSecs; % for debugging.
        for trialNum = 1:length(shuff_names{runNum})   % To cover all the items (fractals) in one run.
            
            noresp = 1;
            cue_was_presented = 0;
            TrialType = 0; % 0 - only fractal presentation. 1 - Conatant Reward. 2 - Assignment.
            WasAssignment = 0;
            TimeOfSucces = 0;
            Screen('TextStyle', w, 1);
            
            if give_reward(trialNum) == 2 %assignment.
                if ismember(shuff_contexts{runNum}{blockNum}, PairedContexts)
%                     %----------------
%                     %% HAPPY ASSIGNMENT:    WELCOME SCREEN
%                     %------------------------------------
%                     
%                     % I can take this 3 next lines to the begining later, and specify the variables.
%                     TimeForAnim = TimeForWelcomeAnim; %The error I measured in actual time for the loop goes upto 0.03.
%                     NumAnimSteps = Welcome_animation_position_steps;
%                     AnimOnsetsVec = linspace(0, TimeForAnim, NumAnimSteps); % IMPORTANT: TimeForAnim/NumAnimSteps should NOT be more than 40. i.e not more than 40 changes in second. for Hebrew it's better even 20 per second.
%                     
%                     
%                     %Instrution vector(hebrew):
%                     %TextBlock = [1504 1505 1492 47 1497 32 1500 1492 1512 1493 1493 1497 1495 32 1499 1502 1492 32 1513 1497 1493 1514 1512 33 10 1492 1511 1500 1491 47 1497 32 1488 1514 32 1492 1512 1510 1507 32 1513 1497 1493 1508 1497 1506 32 1489 1502 1492 1497 1512 1493 1514 32 1492 1488 1508 1513 1512 1497 1514 58];
%                     
%                     
%                     % tempRa=GetSecs-AssignmentStartTime; % for debugging.
% 
%                     ind = 1;
%                     BaselineAnimTime = GetSecs;
%                     while ind <= NumAnimSteps
%                         if  GetSecs - BaselineAnimTime >= AnimOnsetsVec(ind)
%                             Screen('DrawTextures', w, imageTextureFloor, [], FloorPosition , 0);
%                             Screen('PutImage',w,context_items{blockNum},PictureLocationVector);
%                             Screen('DrawTextures', w, imageTextureCarpet, [], Carpet_start_point + [0,Welcome_Y_animation_vector(end),0,Welcome_Y_animation_vector(end)]+[(NumAnimSteps - ind) * 10, 0, (NumAnimSteps - ind) * -10, 0], 0);
%                             CenterText(w,'Get Ready', Welcome_Color ,0,Welcome_Y_animation_vector(ind));
%                             %DrawFormattedText(w, TextBlock{9} , 'center', screenYpixels*0.9 + Welcome_Y_animation_vector(ind), Welcome_Color, 0, 0, 0, 1.5)
%                             Screen(w,'Flip');
%                             if ind == 1
%                                 image_start_time = GetSecs;
%                                 actual_onset_time{runNum}(trialNum,1) = image_start_time - anchor;
%                             end
%                             ind = ind+1;
%                         end
%                     end
%                     
%                     %tempRb=GetSecs-AssignmentStartTime; % for debugging.
% 
%                     WaitSecs(0.3)
%                     Screen('DrawTextures', w, imageTextureFloor, [], FloorPosition , 0);
%                     Screen('PutImage',w,context_items{blockNum},PictureLocationVector);
%                     Screen(w,'Flip');

                    % The next lines were moved here after the kiled the
                    % welcome screen:
                    WaitSecs((anchor+onsets(trialNum)+runStartTime+TimeOfAssignmentsToConsider) - GetSecs)
                    AssignmentStartTime = GetSecs;


                    %%                 The HAPPY Assginment - EXECUTION
                    %++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

                    Screen('DrawTextures', w, imageTextureFloor, [], FloorPosition , 0);
                    Screen('PutImage',w,context_items{blockNum},PictureLocationVector);
                    Screen('DrawTextures', w, imageTextureColumn, [], LeftColumnPosition , 0);
                    Screen('DrawTextures', w, imageTextureColumn, [], RightColumnPosition , 0);
                    Screen('DrawTextures', w, imageTextureArrow(1), [], LeftArrowsPosition , 0);
                    Screen('DrawTextures', w, imageTextureArrow(1), [], RightArrowsPosition, 0);
                    Screen('DrawTextures', w, imageTextureAssignmentBlackBackground, [], AssignmentBlackBackgroundPosition , 0);
                    Screen(w,'Flip',0,1);
                    
                    % The next line was removed here after the kiled
                    % welcome screen:
                    image_start_time = GetSecs;
                    actual_onset_time{runNum}(trialNum,1) = image_start_time - anchor;

                    %WaitSecs(0.2)
                    % Set and present the sequence of letters for the assignment
                    LengthOfSequence = 3;
                    %ABC='A':'Z';
                    %ABC = Shuffle(ABC);
                    %RealSequence = ABC(1:LengthOfSequence);
                    RealSequence = 'RTY';
                    % Show Sequenace
                    Screen('TextSize',w, 50);
                    Screen('TextStyle',w,1);
                    Screen('TextFont',w,theFont);
                    
                    %tempRc=GetSecs-AssignmentStartTime; % for debugging.

                    CenterText(w,[RealSequence(1) '   ' RealSequence(2) '   ' RealSequence(3)], [0,200,0] ,0,-10);
                    % Add instructions in hebrew HERE.
                    %TextBlock = [1492 1512 1510 1507 32 1492 1493 1488 58];
                    DrawFormattedText(w, TextBlock{10} , 'center', screenYpixels*0.40, [255 255 255])
                    % Winning pointers:
                    Screen('TextSize',w, 40);
                    
                    % Drawing the numbers on the columns
%                     step = screenYpixels/25;
%                     for i = 1:11
%                         Number2Print = 20 - (i-1)*2;
%                         if Number2Print >= 10
%                             CenterText(w,sprintf('%.0f -',Number2Print), [0,250,0] ,screenXpixels * 0.31, screenYpixels * -0.25 +i*step);
%                         else
%                             CenterText(w,sprintf('  %.0f -',Number2Print), [0,250,0] ,screenXpixels * 0.31, screenYpixels * -0.25 +i*step);
%                         end
%                     end
                    
                    Screen(w,'Flip',0,1);
                    %WaitSecs(0.3);
                    Screen('TextSize',w, 60);
                    Screen('TextStyle',w,1);
                    CenterText(w,'GO !', [250,0,0] ,0,80);
                    WaitSecs(0.05);
                    Screen(w,'Flip',0,1);
                    %tempRd=GetSecs-AssignmentStartTime; % for debugging.

                    %TimeForAnim = 2;
                    NumAnimSteps = 7;% There are 7 pictures but the first one is already on...
                    AnimOnsetsVec = linspace(0, TimeToPressTheSequence, NumAnimSteps); % IMPORTANT: TimeForAnim/NumAnimSteps should NOT be more than 40. i.e not more than 40 changes in second.
                    %??? Add Here Sound
                    
                    MaxAssignmentReward = 0.2; % Reward from assignment
                    %I can add AssignmentReward = InitialAssigmentReward, and define it at the top...
                    NumWinningOptions = 11;
                    WinningOptions = linspace(MaxAssignmentReward, 0, NumWinningOptions);
                    TimeWinningIntervals = linspace(0, TimeToPressTheSequence, NumWinningOptions);
                    
                    % Set variables for Sequence
                    RightAnswers = 0;
                    LocationInSequence = 1;
                    
                    AssignmentFollow{AssignmentNum,1}='Happy';
                    AssignmentFollow{AssignmentNum,2}=RealSequence;
                    AttemptNum = 3;
                    
                    KbQueueCreate(-1)
                    KbQueueStart
                    ind = 1; %Because 1 indicates time 0.
                    BaselineAnimTime = GetSecs;
                    while ind <= NumAnimSteps && GetSecs - BaselineAnimTime < TimeToPressTheSequence && RightAnswers < LengthOfSequence
                        if  GetSecs - BaselineAnimTime >= AnimOnsetsVec(ind)
                            %        Screen('PutImage',w,context_items{blockNum});
                            if ind ~= NumAnimSteps % to prevent from the first picture to appear again.
                                Screen('DrawTextures', w, imageTextureArrow(mod(ind,7)+1), [], LeftArrowsPosition , 0);
                                Screen('DrawTextures', w, imageTextureArrow(mod(ind,7)+1), [], RightArrowsPosition, 0);
                                Screen(w,'Flip',0,1);
                                %if ind == 1
                                %    Assignmet_start_time = GetSecs-BaselineAnimTime;
                                %end
                                while RightAnswers < LengthOfSequence && GetSecs - BaselineAnimTime < AnimOnsetsVec(ind+1)
                                    Pressed=0;
                                    while Pressed == 0 && GetSecs - BaselineAnimTime < AnimOnsetsVec(ind+1)
                                        [Pressed,firstPress] = KbQueueCheck;
                                    end
                                    KbQueueStop % If we got here it means 'Pressed' is now 1.
                                    PressedSequence = upper(KbName(firstPress));
                                    KbQueueFlush
                                    KbQueueStart
                                    AssignmentFollow{AssignmentNum, AttemptNum} = PressedSequence;
                                    AttemptNum = AttemptNum + 1;
                                    if iscell(PressedSequence) % Means the subject pressed few buttons together
                                        PressedSequence='';% Prevents error and cancells his press.
                                        noresp = 0;
                                    end
                                    if Pressed % maybe the condition here is not necessary...
                                        if PressedSequence == RealSequence(LocationInSequence)
                                            RightAnswers = RightAnswers + 1;
                                            LocationInSequence = LocationInSequence+1;
                                        else
                                            RightAnswers = 0;
                                            LocationInSequence = 1;
                                        end
                                        noresp = 0;
                                    end
                                end
                                ind = ind+1;
                            end
                        end
                    end
                    TimeOfSucces = GetSecs-BaselineAnimTime;
                    %tempRe=GetSecs-AssignmentStartTime;% for debugging.

                    AssignmentNum = AssignmentNum +1;
                    
                    KbQueueRelease;
                    % Check, present and add the amount won.
                    MoneyEarned = 0;
                    
                    Screen('DrawTextures', w, imageTextureAssignmentBlackBackground, [], AssignmentBlackBackgroundPosition , 0);
                    for i = 2:length(TimeWinningIntervals)
                        if TimeOfSucces <= TimeWinningIntervals(i)
                            MoneyEarned = WinningOptions(i-1);
                            if strcmp(Kind, 'day2_training')
                                MoneyEarned = MoneyEarned - MaxAssignmentReward;
                            end
                            % Present the amount:
                            %TextBlock = [1497 1508 1492 32 33];
                            CenterText(w,TextBlock{11}, [255,255,255] ,0,-45);
                            Screen(w,'Flip',0,1);
                            %WaitSecs(0.2)
                            %TextBlock = [1494 1499 1497 1514 32 1489 45  32 32 32 32 32 32 32 32 32 32 1513 34 1495];
                            % Adapting the language:
                            AssignmentMoneyWonPresentation = sprintf('%.0f', abs(MoneyEarned*100));
                            if ~Is_El_Capitan_Or_Newer %i.e. if the experiment is in the testing rooms (matlab 2014 version)
                                MoneyWonPresentationText = [double(AssignmentMoneyWonPresentation) TextBlock{12}];
                            else
                                MoneyWonPresentationText = [TextBlock{12} double(AssignmentMoneyWonPresentation)];
                            end
                            for j = 0:4
                                CenterText(w,MoneyWonPresentationText, Colors{mod(j+ColoringOrderFactor,2)+1} ,0,25);
                                Screen('Flip',w,0,1);
                                WaitSecs(0.15)
                            end
                            Screen(w,'Flip');
                            break
                        end
                    end
                    if strcmp(Kind, 'day2_training') && MoneyEarned == 0
                        MoneyEarned = MoneyEarned - MaxAssignmentReward;
                    end
                    
                    accumulated_money = accumulated_money + MoneyEarned;
                    if (strcmp(Kind, 'day1_training') && MoneyEarned == 0) || (strcmp(Kind, 'day3_reinstatement') && MoneyEarned == 0)  || (strcmp(Kind, 'day2_training') && MoneyEarned == 0 - MaxAssignmentReward)
                        %TextBlock = [1488 1497 1503 32 1494 1499 1497 1497 1492];
                        for j = 0:4
                            CenterText(w, TextBlock{13}, Colors{mod(j+ColoringOrderFactor,2)+1} ,0,-10);
                            Screen('Flip',w,0,1);
                            WaitSecs(0.15)
                        end
                        Screen(w,'Flip');
                    end
                    WaitSecs(0.5)

                    %tempRf=GetSecs-AssignmentStartTime; % for debugging.

                    % Setting the output to indicate no fractal was presented & the TrialType etc.
                    shuff_names{runNum}{trialNum} = '0';
                    TrialType = give_reward(trialNum);
                    WasAssignment = 1;
                    TimeOfAssignment = GetSecs - AssignmentStartTime;
                    TimeOfAssignmentsToConsider = TimeOfAssignmentsToConsider + TimeOfAssignment - image_duration;
                    
                    %tempGoodAssignment(end+1) = GetSecs - AssignmentStartTime
                    %++++++++++++++++++++++++++++++++++++++++++++++++++++++++ end of assignment
                else % Neutral assignment
%                     %----------------
%                     %% NEUTRAL ASSIGNMENT:  WELCOME SCREEN
%                     %--------------------------------------
%                     
%                     % I can take this 3 next lines to the begining later, and specify the variables.
%                     TimeForAnim = TimeForWelcomeAnim; %The error I measured in actual time for the loop goes upto 0.03.
%                     NumAnimSteps = Welcome_animation_position_steps;
%                     AnimOnsetsVec = linspace(0, TimeForAnim, NumAnimSteps); % IMPORTANT: TimeForAnim/NumAnimSteps should NOT be more than 40. i.e not more than 40 changes in second. for Hebrew it's better even 20 per second.
%                     
%                     
%                     %Instrution vector(hebrew):
%                     %TextBlock = [1492 1511 1500 1491 47 1497 32 1488 1514 32 1492 1512 1510 1507 32 1513 1497 1493 1508 1497 1506 32 1489 1502 1492 1497 1512 1493 1514 32 1492 1488 1508 1513 1512 1497 1514 58];
%                     
%                     %tempNa=GetSecs-AssignmentStartTime; % for debugging.
%                     ind = 1;
%                     BaselineAnimTime = GetSecs;
%                     while ind <= NumAnimSteps
%                         if  GetSecs - BaselineAnimTime >= AnimOnsetsVec(ind)
%                             Screen('DrawTextures', w, imageTextureFloor, [], FloorPosition , 0);
%                             Screen('PutImage',w,context_items{blockNum},PictureLocationVector);
%                             Screen('DrawTextures', w, imageTextureCarpet, [], Carpet_start_point + [0,Welcome_Y_animation_vector(end),0,Welcome_Y_animation_vector(end)]+[(NumAnimSteps - ind) * 10, 0, (NumAnimSteps - ind) * -10, 0], 0);
%                             CenterText(w,'Get Ready', Welcome_Color ,0,Welcome_Y_animation_vector(ind));
%                             %DrawFormattedText(w, TextBlock{14} , 'center', screenYpixels*0.9 + Welcome_Y_animation_vector(ind), Green, 0, 0, 0, 1.5)
%                             Screen(w,'Flip');
%                             if ind == 1
%                                 image_start_time = GetSecs;
%                                 actual_onset_time{runNum}(trialNum,1) = image_start_time - anchor;
%                             end
%                             ind = ind+1;
%                         end
%                     end
%                     
%                     %tempNb=GetSecs-AssignmentStartTime; % for debugging.
%                     
%                     WaitSecs(0.3)
%                     Screen('DrawTextures', w, imageTextureFloor, [], FloorPosition , 0);
%                     Screen('PutImage',w,context_items{blockNum},PictureLocationVector);
%                     Screen(w,'Flip');
%                                          

                    % The next lines were moved here after the kiled the
                    % welcome screen:
                    WaitSecs((anchor+onsets(trialNum)+runStartTime+TimeOfAssignmentsToConsider) - GetSecs)
                    AssignmentStartTime = GetSecs;
                    
                    
                    %%                 The NEUTRAL Assginment - EXECUTION
                    %++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

                    Screen('DrawTextures', w, imageTextureFloor, [], FloorPosition , 0);
                    Screen('PutImage',w,context_items{blockNum},PictureLocationVector);
                    Screen('DrawTextures', w, imageTextureColumn, [], LeftColumnPosition , 0);
                    Screen('DrawTextures', w, imageTextureColumn, [], RightColumnPosition , 0);
                    Screen('DrawTextures', w, imageTextureArrow(1), [], LeftArrowsPosition , 0);
                    Screen('DrawTextures', w, imageTextureArrow(1), [], RightArrowsPosition, 0);
                    Screen('DrawTextures', w, imageTextureAssignmentBlackBackground, [], AssignmentBlackBackgroundPosition , 0);
                    Screen(w,'Flip',0,1);
                    
                    % The next line was removed here after the kiled
                    % welcome screen:
                    image_start_time = GetSecs;
                    actual_onset_time{runNum}(trialNum,1) = image_start_time - anchor;
                    
                    %WaitSecs(0.2)
                    % Set and present the sequence of letters for the assignment
                    LengthOfSequence = 3;
                    %ABC='A':'Z';
                    %ABC = Shuffle(ABC);
                    %RealSequence = ABC(1:LengthOfSequence);
                    RealSequence = 'RTY';
                    % Show Sequenace
                    Screen('TextSize',w, 50);
                    Screen('TextStyle',w,1);
                    Screen('TextFont',w,theFont);
                    
                    
                    CenterText(w,[RealSequence(1) '   ' RealSequence(2) '   ' RealSequence(3)], [0,200,0] ,0,-10);
                    % Add instructions in hebrew HERE.
                    %TextBlock = [1492 1512 1510 1507 32 1492 1493 1488 58];
                    DrawFormattedText(w, TextBlock{15} , 'center', screenYpixels*0.40, [255 255 255])
                    % Winning pointers:
                    Screen('TextSize',w, 40);

                    Screen(w,'Flip',0,1);
                    %WaitSecs(0.3);
                    Screen('TextSize',w, 60);
                    Screen('TextStyle',w,1);
                    CenterText(w,'GO !', [250,0,0] ,0,80);
                    WaitSecs(0.05);
                    Screen(w,'Flip',0,1);
                    %tempNc=GetSecs-AssignmentStartTime; % for debugging.

                    %TimeForAnim = 2;
                    NumAnimSteps = 7;% There are 7 pictures but the first one is already on...
                    AnimOnsetsVec = linspace(0, TimeToPressTheSequence, NumAnimSteps); % IMPORTANT: TimeForAnim/NumAnimSteps should NOT be more than 40. i.e not more than 40 changes in second.
                                       
                    % Set variables for Sequence
                    RightAnswers = 0;
                    LocationInSequence = 1;
                    
                    AssignmentFollow{AssignmentNum,1}='Neutral';
                    AssignmentFollow{AssignmentNum,2}=RealSequence;
                    AttemptNum = 3;
                    
                    KbQueueCreate(-1)
                    KbQueueStart
                    ind = 1; %Because 1 indicates time 0.
                    BaselineAnimTime = GetSecs;
                    while ind <= NumAnimSteps && GetSecs - BaselineAnimTime < TimeToPressTheSequence && RightAnswers < LengthOfSequence
                        if  GetSecs - BaselineAnimTime >= AnimOnsetsVec(ind)
                            %        Screen('PutImage',w,context_items{blockNum});
                            if ind ~= NumAnimSteps % to prevent from the first picture to appear again.
                                Screen('DrawTextures', w, imageTextureArrow(mod(ind,7)+1), [], LeftArrowsPosition , 0);
                                Screen('DrawTextures', w, imageTextureArrow(mod(ind,7)+1), [], RightArrowsPosition, 0);
                                Screen(w,'Flip',0,1);
                                %        a=GetSecs-BaselineAnimTime
                                %if ind == 1
                                %    Assignmet_start_time = GetSecs-BaselineAnimTime;
                                %end
                                while RightAnswers < LengthOfSequence && GetSecs - BaselineAnimTime < AnimOnsetsVec(ind+1)
                                    Pressed=0;
                                    while Pressed == 0 && GetSecs - BaselineAnimTime < AnimOnsetsVec(ind+1)
                                        [Pressed,firstPress] = KbQueueCheck;
                                    end
                                    KbQueueStop % If we got here it means 'Pressed' is now 1.
                                    PressedSequence = upper(KbName(firstPress));
                                    KbQueueFlush
                                    KbQueueStart
                                    AssignmentFollow{AssignmentNum, AttemptNum} = PressedSequence;
                                    AttemptNum = AttemptNum + 1;
                                    if iscell(PressedSequence) % Means the subject pressed few buttons together
                                        PressedSequence='';% Prevents error and cancells his press.
                                        noresp = 0;
                                    end
                                    if Pressed
                                        if PressedSequence == RealSequence(LocationInSequence)
                                            RightAnswers = RightAnswers + 1;
                                            LocationInSequence = LocationInSequence+1;
                                        else
                                            RightAnswers = 0;
                                            LocationInSequence = 1;
                                        end
                                        noresp = 0;
                                    end
                                end
                                ind = ind+1;
                            end
                        end
                    end
                    TimeOfSucces = GetSecs-BaselineAnimTime;
                    %tempNd=GetSecs-AssignmentStartTime;% for debugging.

                    AssignmentNum = AssignmentNum +1;
                    
                    KbQueueRelease;
                    % Check, present and add the amount won.
                    
                    Screen('DrawTextures', w, imageTextureAssignmentBlackBackground, [], AssignmentBlackBackgroundPosition , 0);
                    if TimeOfSucces <= TimeToPressTheSequence
                        % Inform the subject that he typed correct:
                        %TextBlock = [1489 1493 1510 1506];
                        for j = 0:4
                            CenterText(w, TextBlock{16}, Colors{mod(j,2)+1} ,0,-10);
                            Screen('Flip',w,0,1);
                            WaitSecs(0.15)
                        end
                        Screen(w,'Flip');
                    else
                        %TextBlock = [1500 1488 32 1489 1493 1510 1506];
                        for j = 0:4
                            CenterText(w, TextBlock{17}, Colors{mod(j,2)+1} ,0,-10);
                            Screen('Flip',w,0,1);
                            WaitSecs(0.15)
                        end
                        Screen(w,'Flip');
                    end
                    WaitSecs(0.5)
                    %tempNe=GetSecs-AssignmentStartTime;% for debugging.

                    % Setting the output to indicate no fractal was presented & the TrialType etc.
                    shuff_names{runNum}{trialNum} = '0';
                    TrialType = give_reward(trialNum);
                    WasAssignment = 10; % To indicate the neutral assignment.
                    TimeOfAssignment = GetSecs - AssignmentStartTime;
                    TimeOfAssignmentsToConsider = TimeOfAssignmentsToConsider + TimeOfAssignment - image_duration;
                    
                    %tempNeutralAssinment(end+1) = GetSecs - AssignmentStartTime
                end
                %++++++++++++++++++++++++++++++++++++++++++++++++++++++++ end of assignment
                % Show fixation:
                %---------------------------
                Screen('DrawTextures', w, imageTextureFloor, [], FloorPosition , 0);
                Screen('PutImage',w,context_items{blockNum},PictureLocationVector);
                %CenterText(w,'+', white,0,-30);
                Screen('TextSize',w, 60);
                Screen(w,'Flip');
                fix_time{runNum}(trialNum,1) = GetSecs ;
                fixcrosstime{runNum} = GetSecs;
                
            else % normal fractals presentation and rewards in the Happy Context.
                Screen('DrawTextures', w, imageTextureFloor, [], FloorPosition , 0);
                Screen('PutImage',w,context_items{blockNum},PictureLocationVector);
                Screen('Flip',w,anchor+onsets(trialNum)+runStartTime+TimeOfAssignmentsToConsider); % display images according to Onset times
                image_start_time = GetSecs;
                actual_onset_time{runNum}(trialNum,1) = image_start_time - anchor;
                
                TextSizeBeforeReward = Screen('TextSize',w);
                TextStyleBeforeReward = Screen('TextStyle',w);
                Screen('TextSize',w, 60);
                Screen('TextStyle',w,3);

                %---------------------------------------------------
                %% REINFORCEMENT
                %---------------------------------------------------
                flag = 1;% Added to keep only one presentation.
                while (GetSecs-image_start_time < image_duration)
                    
                    if ismember(shuff_contexts{runNum}{blockNum}, PairedContexts) && give_reward(trialNum) == 1 && (GetSecs-image_start_time >= 0 - flip_interval) && flag
                        % I can take this 3 nest lines to the begining later, and specify the variables.
                        TimeForAnim = 1; %The error I measured in actual time for the loop goes upto 0.03. THE ACTUAL TIME IS 0.800 ms, BUT IT MAKES IT FASTER THIS WAY;
                        NumAnimSteps = 20;
                        AnimOnsetsVec = linspace(0, TimeForAnim, NumAnimSteps); % IMPORTANT: TimeForAnim/NumAnimSteps should NOT be more than 40. i.e not more than 40 changes in second.
                        
                        PsychPortAudio('Start', ConstantMoneySound_pahandle); % Play the Cue Sound
                        
                        ind = 1;
                        BaselineAnimTime = GetSecs;
                        while ind <= NumAnimSteps && (GetSecs-image_start_time < image_duration)
                            if  GetSecs - BaselineAnimTime >= AnimOnsetsVec(ind)
                                Screen('DrawTextures', w, imageTextureFloor, [], FloorPosition , 0);
                                Screen('PutImage',w,context_items{blockNum},PictureLocationVector);
                                if strcmp(Kind, 'day1_training') || strcmp(Kind, 'day1_training_demo') || strcmp(Kind, 'day3_reinstatement')
                                    DrawFormattedText(w, ['+ ' num2str(Rewards_Vector(Rewards_Vector_Placer))], screenXpixels*0.57, screenYpixels*0.50 + Cue_Y_animation_vector(ind), [255 255 0])
                                elseif strcmp(Kind, 'day2_training')
                                    DrawFormattedText(w, ['- ' num2str(Rewards_Vector(Rewards_Vector_Placer)*-1)], screenXpixels*0.57, screenYpixels*0.50 + Cue_Y_animation_vector(ind), [255 255 0])
                                end
                                Screen('DrawTextures', w, imageTextureCue, [], dstRectCue + [0,Cue_Y_animation_vector(ind),0,Cue_Y_animation_vector(ind)], 0);
                                %Screen('DrawTextures', w, imageTextureTextCue, [], dstTextRectCue + [0,Cue_Y_animation_vector(ind),0,Cue_Y_animation_vector(ind)], 0);
                                Screen(w,'Flip');
                                if ind == 1
                                    %tempAAA = GetSecs;
                                    Cue_time{runNum}(trialNum,1) = GetSecs-image_start_time;
                                    cue_was_presented = 1;
                                end
                                %tempLastInd(end+1) = ind;
                                ind = ind+1;
                            end
                        end
                        %tempMoneyTime(end+1) = GetSecs - BaselineAnimTime;% for debugging.
                        flag = 0;% Added in the demo.
                                        %tempMoneyAppearing(end+1) = GetSecs - TempAAA;

                    end
                end
                %Add the awarded money & update TrialType:
                if ismember(shuff_contexts{runNum}{blockNum}, PairedContexts) && give_reward(trialNum) == 1
                    accumulated_money = accumulated_money + Rewards_Vector(Rewards_Vector_Placer)/100;
                    Rewards_Vector_Placer = Rewards_Vector_Placer + 1;
                    TrialType = give_reward(trialNum);
                end
                
                Screen('TextSize',w, TextSizeBeforeReward);
                Screen('TextStyle',w,TextStyleBeforeReward);
                
                %   Show fixation
                %---------------------------
                %Screen('FillRect', w, black);
                Screen('DrawTextures', w, imageTextureFloor, [], FloorPosition , 0);
                Screen('PutImage',w,context_items{blockNum},PictureLocationVector);
                %CenterText(w,'+', white,0,-30);
                Screen('TextSize',w, 60);
                Screen(w,'Flip', image_start_time+1);
                fix_time{runNum}(trialNum,1) = GetSecs ;
                fixcrosstime{runNum} = GetSecs;
                %tempFtime(end+1) = GetSecs-image_start_time;% for debugging.
            end
            
            %%   'Save data'
            %---------------------------
            if strcmp(Kind, 'day1_training') || strcmp(Kind, 'day2_training') || strcmp(Kind, 'day3_reinstatement')
                fprintf(fid1,'%s\t %d\t %s\t %d\t %d\t %s\t %d\t %d\t %d\t %d\t %d\t %d\t %d\t %.2f\n', subjectID, runNum, shuff_contexts{runNum}{blockNum}, IsHappy, TrialType, shuff_names{runNum}{trialNum}, actual_onset_time{runNum}(trialNum,1),cue_was_presented, Cue_time{runNum}(trialNum,1)*1000, WasAssignment, noresp, TimeOfSucces, fix_time{runNum}(trialNum,1)-anchor, accumulated_money);
            elseif strcmp(Kind, 'day1_training_demo') || strcmp(Kind, 'day3_random_houses')
                fprintf(fid1,'%s\t %s\t %d\t %d\t %s\t %d\t %d\t %d\t %d\t %d\t %d\t %d\n', subjectID, shuff_contexts{runNum}{blockNum}, IsHappy, TrialType, shuff_names{runNum}{trialNum}, actual_onset_time{runNum}(trialNum,1),cue_was_presented, Cue_time{runNum}(trialNum,1)*1000, WasAssignment, noresp, TimeOfSucces, fix_time{runNum}(trialNum,1)-anchor);
            end
            %%%%% POSSIBLE... TO CHANGE LATER THE A MATRIX AND BE VARIATE EACH ITERATION LIKE OTHER VARIABLES HERE...
        end; %	End the big trialNum loop showing all the images in one run.
        %%%MAKE SURE THE NEXT END IS IN THE RIGHT PLACE
        WaitSecs(1); % I HAVE ADDED
    %tempInContext(end+1) = GetSecs - TempStartContext
    end
    %    KbQueueFlush;
    %tempContextsTime(end+1) = GetSecs - TempStartAllContexts % for debugging.
    %%%% may be use to see how to count the correct answers for instance.
    %%%% for the meanRT as well maybe... REMOVE LATER
    %correct{runNum}(1) = length(find(respInTime{runNum} == 11 | respInTime{runNum} == 110 | respInTime{runNum} == 22 | respInTime{runNum} == 220 ));
    %numGoTrials(runNum) = length(find(trialType{runNum} == 11 | trialType{runNum} == 22));
    %mean_RT{runNum} = mean(respTime{runNum}(respInTime{runNum} == 110 | respInTime{runNum} == 220));
    
    % afterrun fixation
    % ---------------------------
    postexperiment = GetSecs;
    while GetSecs < postexperiment+afterrunfixation
        %CenterText(w,'+', white,0,-30);
        Screen('TextSize',w, 60);
        Screen(w,'Flip');
    end
    
    if runNum ~= total_num_runs_training % && runNum ~= runInd % if this is not the last run, but it is an even run and there was a run before (runNum~=runInd), display instructions again for the next run
        %        goodTrials = correct{runNum-1} + correct{runNum}; %%%% REMOVE LATER
        %        goTrials = numGoTrials(runNum-1) + numGoTrials(runNum);
        %        Screen('TextSize', w, 40); %Set textsize
        %        if goodTrials < goTrials/2
        %             CenterText(w,strcat(sprintf('You responded on %.2f', ((correct{runnum-1}(1)+correct{runnum}(1)))/20*100), '% of Go trials'), white, 0,-270);
        %            CenterText(w,sprintf('Please try to respond faster, as fast as you can'), white, 0,-300);
        %        else
        %TextBlock = [1489 1512 1490 1506 32 1513 1488 1514 47 1492 32 1502 1493 1499 1503 32 1514 1510 1488 32 1500 1505 1497 1493 1512 32 1504 1493 1505 1507 32 1489 1497 1503 32 1492 1488 1494 1493 1512 1497 1501 32 1492 1513 1493 1504 1497 1501];
        
        TextSizeBeforeSheep = Screen('TextSize',w);
        Screen('TextSize',w, 45);
        
        if ~strcmp(Kind, 'day1_training_demo')
            
            Screen('PutImage', w, TravelingSheep, SheepPosition);
            CenterText(w,TextBlock{18}, white, 0,-470);
            PressLetterOfTwo(w,ChosenLanguage,3)
            
        else
            DistanceFromCenterOnY = screenYpixels * 0.037;

            CenterText(w,TextBlock{21}, white, 0,-DistanceFromCenterOnY);
            Screen('Flip',w,0,1);
            
            UnCorrectResponse=1;
            while UnCorrectResponse
                [~,~,KeyCode] = KbCheck; %(experimenter_device);
                KeyPressed = KbName(KeyCode);
                if strcmpi(KeyPressed, ExperimenterControlKey)
                    UnCorrectResponse=0;
                end;
            end;
            WaitSecs(0.001);
            
            CenterText(w,TextBlock{22}, white, 0,DistanceFromCenterOnY);
            Screen('Flip',w);
            
            noResponse=1;
            while noResponse
                KbWait([], 2); %Wait for the release of the previous key pressed.
                [keyIsDown,~,~] = KbCheck; %(experimenter_device);
                if keyIsDown && noResponse
                    noResponse=0;
                end;
            end;
            WaitSecs(0.001);
        end
        
        Screen('TextSize',w, TextSizeBeforeSheep);

        Screen('Flip',w);
        WaitSecs(0.5);
    end
end % End the run loop to go over all the runs
%---------------------------------------------------------------
%%   save accumulative winning to a file
%---------------------------------------------------------------
if strcmp(Kind, 'day1_training')
    fid2 = fopen([outputPath '/' subjectID '_day1_Accumulated_Amount.txt'],'a');
    fprintf(fid2, 'In additioin to your payment, YOU WON ANOTHER %.2f SHEKELS.\n', accumulated_money);
    fclose(fid2);
elseif strcmp(Kind, 'day2_training')
    fid2 = fopen([outputPath '/' subjectID '_day2_Accumulated_Amount.txt'],'a');
    fprintf(fid2, 'YOU LOST %.2f SHEKELS, that will be substracted from your today''s payment.\n', accumulated_money*-1);
    fclose(fid2);
elseif strcmp(Kind, 'day3_reinstatement')
    fid2 = fopen([outputPath '/' subjectID '_day3_Accumulated_Amount.txt'],'a');
    fprintf(fid2, 'In additioin to your payment, YOU WON ANOTHER %.2f SHEKELS.\n', accumulated_money);
    fclose(fid2);
end

%---------------------------------------------------------------
%%   save data to a .mat file & close out
%---------------------------------------------------------------
% outfile = strcat(outputPath, '/', subjectID,'_training_run', sprintf('%02d',runInd),'_to_run', sprintf('%02d',runNum), '_eyetracking_', timestamp,'.edf');
if strcmp(Kind, 'day1_training')
    outfile = strcat(outputPath, '/', subjectID,'_day1_training_run', sprintf('%02d',runInd),'_to_run', sprintf('%02d',runNum),'_', timestamp,'.mat');
elseif strcmp(Kind, 'day2_training')
    outfile = strcat(outputPath, '/', subjectID,'_day2_training_run', sprintf('%02d',runInd),'_to_run', sprintf('%02d',runNum),'_', timestamp,'.mat');
elseif strcmp(Kind, 'day1_training_demo')
    outfile = strcat(outputPath, '/', subjectID,'_day1_training_demo_', timestamp,'.mat');
elseif strcmp(Kind, 'day3_reinstatement')
    outfile = strcat(outputPath, '/', subjectID,'_day3_reinstatement_', timestamp,'.mat');
elseif strcmp(Kind, 'day3_random_houses')
    outfile = strcat(outputPath, '/', subjectID,'_day3_random_houses_', timestamp,'.mat');
end

% create a data structure with info about the run
run_info.subject = subjectID;
run_info.date = date;
run_info.outfile = outfile;
run_info.script_version = script_version;
run_info.revision_date = revision_date;
run_info.script_name = mfilename;
run_info.task_name = Kind;
%Removes veriables that may be very heavy and are un necessary:
clear fractal_items context_items CroppedContextsItems ShuffledCroppedContextsItemsForSmallHouses ConstantMoneyWon ConstantMoneySound CueImage CueImageAlpha DoorSound DoorsAlpha ValuableArrowAlpha ValuableArrow_items HappyCarpetImage HappyCarpetImageAlpha HappyColumnImage HappyColumnImageAlpha HappyWelcome NeutralWelcome TextCueImage TextCueImageAlpha TravelingSheep doors_items AssignmentBlackBackgroundImage AssignmentBlackBackgroundImageAlpha HouseImage HouseImageAlpha VillageImage VillageImageAlpha PathImage PathImageAlpha SmallHousesImage SmallHousesImageAlpha FloorImage FloorImageAlpha;

save(outfile);


%   outgoing msg & closing
% ------------------------------
ChangingColors = {Green Red Blue};

%Screen('TextSize',w,45);
Screen('TextSize',w,52);

%Screen('TextFont',w,'Arial');

%TextBlock = [1506 1489 1493 1491 1492 32 1496 1493 1489 1492 32 33];
if strcmp(Kind, 'day1_training') || strcmp(Kind, 'day2_training') || strcmp(Kind, 'day3_reinstatement')
    CenterText(w, TextBlock{19},Green, 0,-275);
elseif strcmp(Kind, 'day1_training_demo') || strcmp(Kind, 'day3_random_houses')
    CenterText(w, TextBlock{18},Green, 0,-275);
end
Screen('Flip',w,0,1);
WaitSecs(0.8)
%TextBlock = [1495 1500 1511 32 1494 1492 32 1492 1505 1514 1497 1497 1501];
if strcmp(Kind, 'day1_training') || strcmp(Kind, 'day2_training') || strcmp(Kind, 'day3_reinstatement')
CenterText(w,TextBlock{20},white, 0,-190);
elseif strcmp(Kind, 'day1_training_demo') || strcmp(Kind, 'day3_random_houses')
CenterText(w,TextBlock{19},white, 0,-190);
end
Screen('Flip',w,0,1);
WaitSecs(0.8)

%TextBlock = [1494 1499 1497 1514 32 1489 45 32 32 32 32 32 32 32 32 32 32 32 1513 34 1495];
%Making the money presentation for th eidfferent languages:
if strcmp(Kind, 'day1_training') || strcmp(Kind, 'day2_training') || strcmp(Kind, 'day3_reinstatement')
    if strcmp(ChosenLanguage,'Hebrew')
        WonMoneyPresentation = sprintf('%.2f    ', abs(accumulated_money));
    else
        WonMoneyPresentation = sprintf('          %.2f', accumulated_money);
    end
    for i = 0:17
        CenterText(w,TextBlock{21} ,ChangingColors{mod(i+ColoringOrderFactor,3)+1}, 0,-105);
        CenterText(w,WonMoneyPresentation,ChangingColors{mod(i+ColoringOrderFactor,3)+1}, 0,-105);
        Screen('Flip',w,0,1);
        WaitSecs(0.1)
    end
    WaitSecs(0.8)
    %TextBlock = [1495 1500 1511 32 50 32 1497 1495 1500 32 1489 1511 1512 1493 1489 44 10 1488 1504 1488 32 1511 1512 1488 32 1500 1504 1505 1497 1497 1503 46];
    Screen('TextSize',w,45);
    DrawFormattedText(w, TextBlock{22} , 'center', screenYpixels*0.52, white, 0, 0, 0, 1.5)
elseif strcmp(Kind, 'day1_training_demo') || strcmp(Kind, 'day3_random_houses')
    CenterText(w,TextBlock{20},white, 0,-85);
end
Screen('Flip',w);


noresp = 1;
while noresp
    [keyIsDown,~,~] = KbCheck;%(experimenter_device);
    if keyIsDown && noresp
        noresp = 0;
    end;
end;
WaitSecs(0.2);

Screen('CloseAll');
ShowCursor;

end % end function

