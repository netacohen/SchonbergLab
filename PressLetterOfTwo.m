function PressLetterOfTwo(screen,ChosenLanguage,WhichOperation)
% Press a button out of two to continue
% input: Screen Name
% WhichOperation: 1 - default, i.e. the full operation. 2 - Just showing the
% text. 3 Like 1 but in a different location.

if nargin < 3
    WhichOperation = 1;
end

% Press a button out of two to "go to the next room"
%ABC='A':'Z';
%ABC = Shuffle(ABC);
%NumOfLetterOptionsToContinue = 2;
%OptionalLetters = ABC(1:NumOfLetterOptionsToContinue);

if WhichOperation < 3
    Screen('TextSize',screen, 45);
    OptionalLetters = 'T';
    Y_Axis_Location = -230;
else
    Screen('TextSize',screen, 45);
    OptionalLetters = 'N';
    Y_Axis_Location = -370;
end
    

LetterChosenToContinue = '';
PressedToContinue = 0;

if strcmp(ChosenLanguage,'Hebrew')
    % Check if reverse hebew by checking matlab version:
    Versions = ver;
    % Find the right line to look at in the struct:
    index = find(strcmp({Versions.Name}, 'MATLAB')==1);
    MatlabVersion = Versions(index).Release;
    ChangeDirection = strfind(MatlabVersion,'2014');
    
    if ~isempty(ChangeDirection)
        TextBlock{1} = fliplr([1500 1495 1509 47 1497 32 1506 1500 32 1492 1502 1511 1513 32 32 32 32 32 32 32]);
        TextBlock{2} = fliplr([1499 1491 1497 32 1500 1492 1514 1495 1497 1500 32 1489 1505 1497 1493 1512]);
        CenterText(screen,[TextBlock{2} TextBlock{1}], [250 250 250],0,Y_Axis_Location+10);
        CenterText(screen,sprintf('    ''%s'' ', OptionalLetters(1)), [250 250 250],0,Y_Axis_Location+10);
    else
        TextBlock{1} = [1500 1495 1509 47 1497 32 1506 1500 32 1492 1502 1511 1513 32 32 32 32 32 32 32];
        TextBlock{2} = [1499 1491 1497 32 1500 1492 1514 1495 1497 1500 32 1489 1505 1497 1493 1512];
        CenterText(screen,[TextBlock{1} TextBlock{2}], [250 250 250],0,Y_Axis_Location);
        CenterText(screen,sprintf('    ''%s'' ', OptionalLetters(1)), [250 250 250],0,Y_Axis_Location);
    end
else
    TextBlock{1} = 'Press the button ';
    TextBlock{2} = ' to get inside.';
    %CenterText(screen,[TextBlock{1} sprintf('''%s''', OptionalLetters(1)) TextBlock{2} sprintf('''%s''',OptionalLetters(2)) TextBlock{3}], [250 250 250],0,-170);
    CenterText(screen,[TextBlock{1} sprintf('''%s''', OptionalLetters(1)) TextBlock{3}], [250 250 250],0,Y_Axis_Location);
end

if WhichOperation == 2
    return
end

Screen('Flip',screen,0,1);

KbQueueCreate(-1)
while isempty(strfind(OptionalLetters,LetterChosenToContinue))
    KbQueueStart
    while PressedToContinue == 0
        [PressedToContinue,firstPressToContinue] = KbQueueCheck;
    end
    LetterChosenToContinue = upper(KbName(firstPressToContinue));
    if iscell(LetterChosenToContinue) % Means the subject pressed few buttons together
       LetterChosenToContinue='';% Prevents error and cancells his press.
    end
        KbQueueStop;
        KbQueueFlush;
        PressedToContinue = 0;
end

KbQueueRelease;
end