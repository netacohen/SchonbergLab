%% Time calculating for the experiment
% ------------------------------------------

FirstDayPreExperiment = 5;
SecondOrThirdDayPreExperiment = 1;

BDMWithDemo = 2;
BDMWitouthDemo = 1.5;
BDMFaces = 5;

TrainingWithDemo = 33;
TrainingWitoutDemo = 31;

Probe = 8;

Reinstatement = 2;
PersonalDetails = 1;

Recognition = 4;
RandomHouses = 1;
SubjectFeedback = 4;

PostExperiment = 2;

Day1 = FirstDayPreExperiment  + BDMWithDemo + TrainingWithDemo + BDMFaces + Probe + BDMWitouthDemo  + PostExperiment

Day2 = SecondOrThirdDayPreExperiment + TrainingWitoutDemo + BDMFaces + Probe + BDMWitouthDemo  + PostExperiment

Day3 = SecondOrThirdDayPreExperiment + Reinstatement + Probe + BDMWitouthDemo + PersonalDetails + Recognition + RandomHouses + SubjectFeedback + PostExperiment
