function personal_details(subjectID, outputPath, sessionNum)

% function personalDetails(subjectID, order, mainPath)
%   This function gets a few personal details from the subject and saves it
%   to file named subjectID '_personalDetails' num2str(sessionNum) '.txt'

% % dummy data for debugging
% subjectID =  'CAr_101';
% order = 1;
% outputPath =[pwd '/Output'];
% sessionNum=1;

% get time and date
c = clock;
hr = sprintf('%02d', c(4));
min = sprintf('%02d', c(5));
timestamp = [date,'_',hr,'h',min,'m'];


% open a txt file for the details
fid1 = fopen([outputPath '/' subjectID '_personalDetails' num2str(sessionNum) '_' timestamp '.txt'], 'a');
fprintf(fid1,'subjectID\tdate\tgender(1-female, 2-male)\tage\tdominant hand (1-right, 2-left)\toccupation\n'); %write the header line

% Telling the subject now we will ask for personal details:
set(groot,'defaultUicontrolFontSize', 20)
questdlg('Now some personal details will be requested. Please fill them in.'... '
    ,'Personal Details','Continue','Continue');
WaitSecs(0.5);

% ask the subject for the details

%set text size of the dialod box:
set(groot,'defaultUicontrolFontSize', 16)
Gender = questdlg('Please select your gender:','Gender','Female','Male','Female');
% options.Resize='on';


while isempty(Gender)
    Gender = questdlg('Please select your gender:','Gender','Female','Male','Female');
end
if strcmp(Gender,'Male')
    Gender = 2;
else
    Gender = 1;
end


%set text size of the dialod box:
set(groot,'defaulttextfontsize',18);
Age = myinputdlg('Please enter your age: ','Age',1);
while isempty(Age) || isempty(Age{1})
    Age = myinputdlg ('Only integers between 18 and 40 are valid. Please enter your age: ','Age',1);
end
Age = cell2mat(Age);
Age = str2double(Age);
while mod(Age,1) ~= 0 || Age < 18 || Age > 40
    Age = myinputdlg ('Only integers between 18 and 40 are valid. Please enter your age: ','Age',1);
    Age = cell2mat(Age);
    Age = str2double(Age);
end


%set text size of the dialod box:
set(groot,'defaultUicontrolFontSize', 16)
DominantHand = questdlg('Please select your domoinant hand:','Dominant hand','Left','Right','Right');
while isempty(DominantHand)
    DominantHand = questdlg('Please select your domoinant hand:','Dominant hand','Left','Right','Right');
end
if strcmp(DominantHand,'Left')
    DominantHand = 2;
else
    DominantHand = 1;
end

%set text size of the dialod box:
set(groot,'defaultUicontrolFontSize', 16)
Occupation = myinputdlg('Please type your occupation (for example- a student for Psychology): ','Occupation',1);
Occupation = cell2mat(Occupation);


%set text size of the dialod box:
%set(groot,'defaultUicontrolFontSize', 16)
%Investigate = myinputdlg('In your opinion, what does this experiment investigate? ','Investigate',1);
%Investigate = cell2mat(Investigate);



%set text size of the dialod box:
%set(groot,'defaultUicontrolFontSize', 16)
%Strategy = myinputdlg('Did you use any Strategies in this experiment? ','Strategy',1);
%Strategy = cell2mat(Strategy);



%set text size of the dialod box:
%set(groot,'defaultUicontrolFontSize', 16)
%Success = myinputdlg('Do you feel you have succedded in the tasks? ','Success',1);
%Success = cell2mat(Success);



%set text size of the dialod box:
%set(groot,'defaultUicontrolFontSize', 16)
%Eat = myinputdlg('When was the last time that you ate? what did you eat at that time? ','Eat',1);
%Eat = cell2mat(Eat);



%set text size of the dialod box:
%set(groot,'defaultUicontrolFontSize', 16)
%Hungry = myinputdlg('How hungry are you right now? 1-not at all, 10- very much): ','Hungry',1);
%while isempty(Hungry) || isempty(Hungry{1})
%    Hungry = myinputdlg ('Please correct. How hungry are you right now? 1-not at all, 10- very much): ','Hungry',1);
%end
%Hungry = cell2mat(Hungry);
%Hungry = str2double(Hungry);
%while mod(Hungry,1) ~= 0 || Hungry < 0 || Hungry > 10
%    Hungry = myinputdlg ('Please correct. How hungry are you right now? 1-not at all, 10- very much): ','Hungry',1);
%    Hungry = cell2mat(Hungry);
%    Hungry = str2double(Hungry);
%end


%set text size of the dialod box:
%set(groot,'defaultUicontrolFontSize', 16)
%Comments = myinputdlg('Any comments?','Comments',1);
%Comments = cell2mat(Comments);

%% finish this part
%set text size of the dialod box
set(groot,'defaultUicontrolFontSize', 24)
end_part=0;
questdlg('thank you!! Please call the experimenter'... '
    ,'Personal Detailes','Continue','Continue');
WaitSecs(1);

% close experiment window, and then start the ranking manually
Screen('CloseAll');
ShowCursor;

exp_break=0;
try
    exp_break = input('Type in "123" when you are ready to continue with the experiment:  ');
catch
end
while end_part==0
    try
        if exp_break==123
            end_part=1;
        else
            fprintf('\n<strong>ERROR: Invalid input.</strong>\n');
            exp_break = input('Type in "123" when you are ready to continue: ');
        end
    catch
    end
end

% Write details to file
fprintf(fid1,'%s\t%s\t%d\t%d\t%d\t%s\n', subjectID, timestamp, Gender, Age, DominantHand, Occupation);
fclose(fid1);
end

