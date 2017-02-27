%   Making the Doors
% - - - - - - - - - - - - - - - -
images=dir('./Misc/doors/door*.png');
doors{1} = cell((Struct2Vect(images,'name'))') ;
clear images

%   reading in images
%---------------------------
doors_items = cell(1, length(doors{1}));
DoorsAlpha = cell(1, length(doors{1}));
imageTextureDoor = zeros(1,length(doors{1}));

DoorsTransparencyFactor=1;  %change this factor to manipulate cue's transparency

for i = 1:length(doors{1})
    [doors_items{i}, ~,DoorsAlpha{i}] = imread(sprintf('Misc/doors/%s',doors{1}{i}));
    doors_items{i}(:, :, 4) = DoorsAlpha{i}*DoorsTransparencyFactor;
    imageTextureDoor(i) = Screen('MakeTexture', w, doors_items{i});
end

% Get the size of the Arrows
[DoorsHight, DoorsWidth, ~] = size(doors_items{1});

scaleFactorArrow = 2.2; %change this factor to manipulate arrows' size
%DoorsPosition = CenterRectOnPointd([0 0 DoorsWidth DoorsHight] .* scaleFactorArrow, screenXpixels /2, screenYpixels / 1.3);
DoorsPosition = [751,450.769230769231,1169,1000.76923076923]; % Fine Tunning to the "House".

% -------------------------------------------------------
%% 'Visual Elements settings'
%---------------------------------------------------------------
% Village
%++++++++++++++++++++++++++++
VillageImageLocation = './Misc/doors/Village.png';
[VillageImage, ~, VillageImageAlpha] = imread(VillageImageLocation);
transparencyFactor=1;  %change this factor to manipulate cue's transparency
VillageImage(:, :, 4) = VillageImageAlpha*transparencyFactor    ;
[VillageHight, VillageWidth, ~] = size(VillageImage);
scaleFactor = 1; %change this factor to manipulate cue's size
dstRectVillage = CenterRectOnPointd([0 0 VillageWidth VillageHight] .* scaleFactor, screenXpixels/2, screenYpixels/2);
imageTextureVillage = Screen('MakeTexture', w, VillageImage);
%---------------------------------------------------------------
% House
%++++++++++++++++++++++++++++
if ~isempty(strfind(Kind,'training')) || ~isempty(strfind(Kind, 'reinstatement')) || ~isempty(strfind(Kind, 'random_houses'))
    HouseImageLocation = './Misc/doors/House.png';
elseif strfind(Kind,'probe')
    HouseImageLocation = './Misc/doors/HouseForProbe.png';
end
[HouseImage, ~, HouseImageAlpha] = imread(HouseImageLocation);
transparencyFactor=1;  %change this factor to manipulate cue's transparency
HouseImage(:, :, 4) = HouseImageAlpha*transparencyFactor    ;
[HouseHight, HouseWidth, ~] = size(HouseImage);
scaleFactorHouses = 0.99; %change this factor to manipulate cue's size
dstRectHouse = CenterRectOnPointd([0 0 HouseWidth HouseHight] .* scaleFactorHouses, screenXpixels/2, screenYpixels/2.3);
dstRectHouse = dstRectHouse + [0.0023*HouseWidth,-0.0078*HouseHight,0.0023*HouseWidth,-0.0078*HouseHight]; % Fine tunning
imageTextureHouse = Screen('MakeTexture', w, HouseImage);
%---------------------------------------------------------------
% Path
%++++++++++++++++++++++++++++
PathImageLocation = './Misc/doors/Path.png';
[PathImage, ~, PathImageAlpha] = imread(PathImageLocation);
transparencyFactor=1;  %change this factor to manipulate cue's transparency
PathImage(:, :, 4) = PathImageAlpha*transparencyFactor    ;
[PathHight, PathWidth, ~] = size(PathImage);
scaleFactor = 1; %change this factor to manipulate cue's size
dstRectPath = CenterRectOnPointd([0 0 PathWidth*2 PathHight] .* scaleFactor, screenXpixels/2, screenYpixels/1.135);
imageTexturePath = Screen('MakeTexture', w, PathImage);

%% Design Houses etc For Probe
%++++++++++++++++++++++++++++

ScalingRatioForProbeHouses = 0.7576;
scaleFactorHomeForProbe = scaleFactorHouses * ScalingRatioForProbeHouses; %change this factor to manipulate cue's size
dstRectHouseLeft = CenterRectOnPointd([0 0 HouseWidth HouseHight] .* scaleFactorHomeForProbe, screenXpixels*0.25, screenYpixels*0.46);
imageTextureHouseLeft = Screen('MakeTexture', w, HouseImage);

dstRectHouseRight = CenterRectOnPointd([0 0 HouseWidth HouseHight] .* scaleFactorHomeForProbe, screenXpixels*0.75, screenYpixels*0.46);
imageTextureHouseRight = Screen('MakeTexture', w, HouseImage);

PositionForRightCroppedContext = [ 713, 147, 713, 147];
PositionForLeftCroppedContext = [ -247, 147, -247, 147];

%% For Tests:
%+++++++++++++++++++++++++++
%                CenterText(w,sprintf('Once you are ready you will explore the next room'), white, 0,-300);
%                CenterText(w,sprintf('Once you are ready you will explore the next room'), white, 0,-170);


%                Screen('DrawTextures', w, imageTextureDoor(1), [], DoorsPosition , 0);
%                Screen(w,'Flip');
%                for i = 2:length(imageTextureDoor)
%                    Screen('DrawTextures', w, imageTextureDoor(i), [], DoorsPosition , 0);
%                    Screen(w,'Flip');
%                    WaitSecs(0.1)
%                end
%                WaitSecs(0.2)

