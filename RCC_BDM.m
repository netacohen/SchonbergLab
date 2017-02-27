function RCC_BDM(subjectID, sessionNum, ChosenLanguage, Kind)
%=========================================================================
% BDM task
%=========================================================================
% BDM_Fractals(subjectID, sessionNum, ChosenLanguage)
% creates the output file: [subjectID '_Fractals_BDM_day' num2str(sessionNum) '_' timestamp '.txt']

c=clock;
hr=num2str(c(4));
minute=num2str(c(5));
timestamp=[date,'_',hr,'h',minute,'m'];

rng shuffle

tic
%--------------------------------------------------------------------------
%% Locations, File Types & Names PARAMETERS
%--------------------------------------------------------------------------
% Stimuli:
if any(strcmp(Kind, {'fractals_BDM1' 'fractals_BDM2'}))
    StimLocation = 'stim/contexts/';
elseif strcmp(Kind, 'fractals_BDM_demo')
    StimLocation = 'stim/contexts/demo/';
elseif strcmp(Kind, 'faces_BDM')
    StimLocation = 'stim/faces/';
end

% for output file
OutputFolder = 'Output/';

if strcmp(Kind, 'faces_BDM')
    StimuliName = 'Faces';
    StimFileType = 'tif';
else
    StimuliName = 'Fractals';
    StimFileType = 'jpg';
end

%--------------------------------------------------------------------------
%% PARAMETERS FOR THE RANKING AXIS
%--------------------------------------------------------------------------
% Parameters for RANKING RANGE
RankingMin = 0;
RankingMax = 10;

% Parameters for Creatining the RANKING AXIS:
RelativeSizeOfRankingAxisFromScreenSize = 1/3;
YaxisRelativeMiddlePoint = 0.9;
YaxisWidthFactor = 0.0102;

% Parameters for the MOVING INDICATOR on the ranking axis:
penWidth = 3;
AdditionalMovingIndicatorLengthFactor = 0.018; % Extension from Each side of the ranking axis.

% Parameters for FIGURES PRESENTATION:
TextSizeForFiguresOnAxis = 30;
DistanceOfFiguresFactor = 0.0065;

% Fixation cross fix:
FixForFixationCrossLocation = -33.5; % A fix for fixation cross on center text to be in center on the Y axis. Relevant for text size 60.

%--------------------------------------------------------------------------
%% PARAMETERS FOR THE STIMULI SIZE AND LOCATION
%--------------------------------------------------------------------------
StartingPointOnX = 0;
StartingPointOnY = 0;
StimuliWidthScaleFactor = 1;
StimuliHeightScaleFactor = 0.8361;

%---------------------------------------------------------------
%% Load chosen language:
%---------------------------------------------------------------
if any(strcmp(Kind, {'fractals_BDM1' 'fractals_BDM2'}))
    TextBlock = Language(ChosenLanguage, 'BDM_Fractals');% mfilename gets the name of the running function;
elseif strcmp(Kind, 'fractals_BDM_demo')
    TextBlock = Language(ChosenLanguage, 'BDM_Fractals_demo');% mfilename gets the name of the running function;
elseif strcmp(Kind, 'faces_BDM')
    TextBlock = Language(ChosenLanguage, 'BDM_Faces');
end
%---------------------------------------------------------------
%% 'INITIALIZE Screen variables'
%---------------------------------------------------------------
Screen('Preference', 'VisualDebuglevel', 3); %No PTB intro screen
screennum = min(Screen('Screens'));

pixelSize=32;

%[w] = Screen('OpenWindow',screennum,[],[0 0 640 480],pixelSize);% %debugging screensize
[w] = Screen('OpenWindow',screennum,[],[],pixelSize);

% Here Be Colors
black=BlackIndex(w); % Should equal 0.
white=WhiteIndex(w); % Should equal 255.
%yellow=[0 255 0];


% set up Screen positions for stimuli
[screenXpixels, screenYpixels]=Screen('WindowSize', w);
xcenter=screenXpixels/2;
ycenter=screenYpixels/2;

Screen('FillRect', w, black);  % NB: only need to do this once!
Screen('Flip', w);

% text stuffs
theFont='Arial';
Screen('TextFont',w,theFont);

instrSZ=45;
betsz=60;

%--------------------------------------------------------------------------
%% SETTINGS FOR THE RANKING AXIS
%--------------------------------------------------------------------------
% Settings for Creatining the RANKING AXIS:
AxisFromX = screenXpixels*RelativeSizeOfRankingAxisFromScreenSize; % Starting point on X axis
AxisToX = screenXpixels*(1-RelativeSizeOfRankingAxisFromScreenSize); % Ending point on X axis
AxisFromY = round(screenYpixels * (YaxisRelativeMiddlePoint - (YaxisRelativeMiddlePoint * YaxisWidthFactor))); % Starting point on Y axis
AxisToY = round(screenYpixels * (YaxisRelativeMiddlePoint + (YaxisRelativeMiddlePoint * YaxisWidthFactor))); % Ending point on Y axis

% Settings for the MOVING INDICATOR on the ranking axis:
CenterOfMovingIndicator = mean([AxisFromY AxisToY]);
AdditionToYAxisFromEachSide = screenYpixels*AdditionalMovingIndicatorLengthFactor;

% Settings for FIGURES PRESENTATION:
RankingIntegers = RankingMax - RankingMin + 1;
SpotsForIndicatorsOnAxis = linspace(AxisFromX, AxisToX, RankingIntegers);
DistanceOfFiguresFromAxis = round(screenYpixels * DistanceOfFiguresFactor) + AdditionToYAxisFromEachSide ;
FixForFiguresOnXaxis = round(screenYpixels * 0.0074);

%--------------------------------------------------------------------------
%% SETTINGS FOR THE STIMULI SIZE AND LOCATION
%--------------------------------------------------------------------------
PictureSizeOnX = round(screenXpixels * StimuliWidthScaleFactor);
PictureSizeOnY = round(screenYpixels * StimuliHeightScaleFactor);
if strcmp(Kind, 'faces_BDM')
    PictureLocationVector = [];
else
    PictureLocationVector = [StartingPointOnX, StartingPointOnY, StartingPointOnX + PictureSizeOnX, StartingPointOnY + PictureSizeOnY];
end

% PictureLocationVector = []; Activate it to draw the picture in the original size and in the center.

%---------------------------------------------------------------
%% 'LOAD image arrays'
%---------------------------------------------------------------
stimuli_images=dir([StimLocation '*.' StimFileType]);
if any(strcmp(Kind, {'fractals_BDM1' 'fractals_BDM2' 'faces_BDM'}))
    shuffledlist=Shuffle(1:length(stimuli_images));
elseif strcmp(Kind, 'fractals_BDM_demo')
    shuffledlist=1:length(stimuli_images);
end

for i=1:length(shuffledlist)
    imageArrays{i}=imread([StimLocation stimuli_images(shuffledlist(i)).name]);
end

%---------------------------------------------------------------
%% 'Write output file header'
%---------------------------------------------------------------
if strcmp(Kind, 'fractals_BDM1')
    fid1=fopen([OutputFolder subjectID '_day' num2str(sessionNum) '_' StimuliName '_BDM1_' timestamp '.txt'], 'a');
elseif strcmp(Kind, 'fractals_BDM2')
    fid1=fopen([OutputFolder subjectID '_day' num2str(sessionNum) '_' StimuliName '_BDM2_' timestamp '.txt'], 'a');
elseif strcmp(Kind, 'fractals_BDM_demo')
    fid1=fopen([OutputFolder subjectID '_day' num2str(sessionNum) '_' StimuliName '_BDM_demo_' timestamp '.txt'], 'a');
elseif strcmp(Kind, 'faces_BDM')
    fid1=fopen([OutputFolder subjectID '_day' num2str(sessionNum) '_' StimuliName '_BDM_' timestamp '.txt'], 'a');
end
fprintf(fid1,'subjectID runtrial onsettime Name Bid RT first_mouse_movement \n'); %write the header line

%---------------------------------------------------------------
%% 'Display Main Instructions'
%---------------------------------------------------------------

Screen('TextSize',w, 70);
Screen('TextStyle',w ,1);
DrawFormattedText(w, TextBlock{1} , 'center', screenYpixels*0.15, [255 255 255])
Screen('TextSize',w, instrSZ);
Screen('TextStyle',w ,0);
DrawFormattedText(w, TextBlock{2} , 'center', screenYpixels*0.30, [255 255 255])
Screen('TextStyle',w ,1);
DrawFormattedText(w, TextBlock{3} , 'center', screenYpixels*0.37, [255 255 255])
DrawFormattedText(w, TextBlock{4} , 'center', screenYpixels*0.42, [255 255 255])
Screen('TextStyle',w ,0);
DrawFormattedText(w, TextBlock{5} , 'center', screenYpixels*0.52, [255 255 255])
DrawFormattedText(w, TextBlock{6} , 'center', screenYpixels*0.75, [50 255 50])


HideCursor;
Screen('Flip', w);
WaitSecs(0.05); % prevent key spillover
noresp=1;
while noresp
    [keyIsDown] = KbCheck;
    if keyIsDown && noresp
        noresp = 0;
    end
end

Screen('TextSize',w, betsz);
CenterText(w,'+', white,0,FixForFixationCrossLocation);
Screen(w,'Flip');
WaitSecs(0.3);

%---------------------------------------------------------------
%% 'Run Trials'
%---------------------------------------------------------------
runStart=GetSecs;

for trial=1:length(stimuli_images)
    
    bid=[];
    noresp=1;
    Screen('TextSize',w,TextSizeForFiguresOnAxis);
    eventTime=[];
    ShowCursor;
    SetMouse(xcenter,ycenter);
    % Intialize variables for checking when mouse first to moved:
    FirstlyMoved = 0;
    while noresp
        % Track cursor movement and check for response
        [CurrentX,CurrentY,buttons] = GetMouse(w);
        if FirstlyMoved == 0 && CurrentX ~= screenXpixels/2 && CurrentY ~= screenYpixels/2
           FirstMouseMovement = GetSecs - runStart - eventTime;
           FirstlyMoved = 1;
        end
        if CurrentX >= AxisFromX && CurrentX <= AxisToX && CurrentY >= AxisFromY - AdditionToYAxisFromEachSide && CurrentY <= AxisToY + AdditionToYAxisFromEachSide
            Screen('PutImage',w,imageArrays{trial},PictureLocationVector);
            Screen('FillRect', w ,[211 211 211] ,[AxisFromX, AxisFromY,  AxisToX, AxisToY]);
            for i = 1:length(SpotsForIndicatorsOnAxis)
                DrawFormattedText(w, num2str(i-1 + RankingMin), SpotsForIndicatorsOnAxis(i)-FixForFiguresOnXaxis, CenterOfMovingIndicator+DistanceOfFiguresFromAxis, [255 255 255]);
            end
            % write "low value / high value" near the scale:
            DrawFormattedText(w, TextBlock{10} , round(0.2922 * screenXpixels), round(0.8981*screenYpixels), [255 255 255]);
            DrawFormattedText(w, TextBlock{11} , round(0.2865 * screenXpixels), round(0.9213*screenYpixels), [255 255 255]);
            DrawFormattedText(w, TextBlock{12} , round(0.6943 * screenXpixels), round(0.8981*screenYpixels), [255 255 255]);
            DrawFormattedText(w, TextBlock{13} , round(0.6875 * screenXpixels), round(0.9213*screenYpixels), [255 255 255]);
            Screen('DrawLine', w ,[0 0 255], CurrentX, CenterOfMovingIndicator+AdditionToYAxisFromEachSide, CurrentX, CenterOfMovingIndicator-AdditionToYAxisFromEachSide ,penWidth);
            Screen(w,'Flip');
            if buttons(1) == 1
                bid = (CurrentX - AxisFromX) / (AxisToX - AxisFromX) * (RankingMax - RankingMin) + RankingMin; % Number of pixels from X axis beggining / Length of the axis * Units + Beggining of units.
                respTime = GetSecs - runStart - eventTime;
                noresp = 0;
                while any(buttons) % wait for release
                    [~,~,buttons] = GetMouse;
                end
            end
        else
            Screen('PutImage',w,imageArrays{trial},PictureLocationVector);
            Screen('FillRect', w ,[211 211 211] ,[AxisFromX, AxisFromY,  AxisToX, AxisToY]);
            for i = 1:length(SpotsForIndicatorsOnAxis)
                DrawFormattedText(w, num2str(i-1 + RankingMin), SpotsForIndicatorsOnAxis(i)- FixForFiguresOnXaxis, CenterOfMovingIndicator+DistanceOfFiguresFromAxis, [255 255 255]);
            end
            % write "low value / high value" near the scale:
            DrawFormattedText(w, TextBlock{10} , round(0.2922 * screenXpixels), round(0.8981*screenYpixels), [255 255 255]);
            DrawFormattedText(w, TextBlock{11} , round(0.2865 * screenXpixels), round(0.9213*screenYpixels), [255 255 255]);
            DrawFormattedText(w, TextBlock{12} , round(0.6943 * screenXpixels), round(0.8981*screenYpixels), [255 255 255]);
            DrawFormattedText(w, TextBlock{13} , round(0.6875 * screenXpixels), round(0.9213*screenYpixels), [255 255 255]);
            Screen(w,'Flip');
            if isempty(eventTime) % recording the presentation start time
                eventTime = GetSecs-runStart;
            end
        end
    end
    
    %-----------------------------------------------------------------
    % show fixation ITI
    Screen('TextSize',w, betsz);
    CenterText(w,'+', white,0,FixForFixationCrossLocation);
    Screen(w,'Flip');
    WaitSecs(0.3);
    
    %-----------------------------------------------------------------
    % write to output file
    
    fprintf(fid1,'%s %d %d %s %d %d %d \n', subjectID, trial, eventTime, stimuli_images(shuffledlist(trial)).name, bid, respTime, FirstMouseMovement);
end

HideCursor;
Screen('TextSize',w, instrSZ);
CenterText(w,TextBlock{7}, white,0,-60);
Screen('Flip', w, runStart,1);
WaitSecs(1);
CenterText(w,TextBlock{8}, white,0,20);
Screen('Flip', w, 0,1);
WaitSecs(1);
CenterText(w,TextBlock{9}, white,0,100);
Screen('Flip', w);
WaitSecs(3); % prevent key spillover

fclose(fid1);
toc

ShowCursor;
Screen('closeall');

end
