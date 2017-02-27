function CopyOutputToDropbox(subjectID, mainPath, sessionNum)
% Copy all the output files of a subject to the dropbox "experiments
% outputs" folder in the end of the experiment\session.
% Locate it in the end of the main function of the experiment.

outputPath = [mainPath '/Output'];

% Change this 3 variables according to experiment:
NumOfFoldersBack = 2; % From the experiment folder.
PathFromCommonFolder = 'Dropbox/experimentsOutput/RCC/Output';%The path from the first common folder of the origin and the deatination folder.
if sessionNum == 1
    FilesToCopy = [outputPath '/' subjectID '*'];
else
    FilesToCopy = [outputPath '/' subjectID '*_day' num2str(sessionNum) '*'];
    if sessionNum == 3
        MoreFilesToCopy1 = [outputPath '/' subjectID '*personalDetails*'];
        MoreFilesToCopy2 = [outputPath '/' subjectID '*SubjectFeedback*'];
    end
end

% Creating the destination path:
Slashes = strfind(mainPath,'/');
Destination = mainPath(1:Slashes(end-NumOfFoldersBack+1));
Destination = [Destination PathFromCommonFolder];
% Copy the relevant files:
copyfile(FilesToCopy, Destination);
if sessionNum == 3
    copyfile(MoreFilesToCopy1, Destination);
    copyfile(MoreFilesToCopy2, Destination);
end
fprintf('output files have been copied successfully\n')
end
