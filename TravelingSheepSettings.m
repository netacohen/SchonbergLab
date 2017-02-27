%   Making the fractals files list
% - - - - - - - - - - - - - - -
images=dir('./Misc/exploring/Sheep.jpg');
Sheep = images.name;
clear images

%   reading in images
%---------------------------
TravelingSheep = imread(sprintf('Misc/exploring/%s',Sheep));

[SheepHight, SheepWidth, ~] = size(TravelingSheep);

scaleFactorSheep = 1; %change this factor to manipulate arrows' size
SheepPosition = CenterRectOnPointd([0 0 SheepWidth SheepHight] .* scaleFactorSheep, screenXpixels / 2, screenYpixels / 2);

%% Tests
%----------=-=-=-=-=-=-=-=----------------=-=-==-=-=-=-=--=----------------
%CenterText(w,sprintf('Once you are ready you will start you journey!'), white, 0,-300);
%CenterText(w,sprintf('Press any key to enter the first room') ,white,0,-140);

%Screen('PutImage', w, TravelingSheep, SheepPosition);
%Screen('Flip',w);

%CenterText(w,sprintf('When you are ready you will take another round of exploration'), white, 0,-300);
%Screen('PutImage', w, TravelingSheep, SheepPosition);

%PressLetterOfTwo(w)

%Screen('Flip',w);
