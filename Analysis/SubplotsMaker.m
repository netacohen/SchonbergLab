%Figure for every subject
NumOfPlots = length(RelevantSubjects)
NumOfRows = ceil(sqrt(NumOfPlots))
NumOfCols = floor(sqrt(NumOfPlots))

for i = 1:length(RelevantSubjects)
    subplot(NumOfRows,NumOfCols,i)
    NumRelevantDaysForSubject = sum(RelevantDataMatrix(:,1)==RelevantSubjects(i));
    DataForSubject = RelevantDataMatrix(RelevantDataMatrix(:,1)==RelevantSubjects(i),:);
    %figure
    b = bar(1:NumRelevantDaysForSubject, DataForSubject(:,3)./DataForSubject(:,5)*100,0.5);
    ylim([0 100])
    title(['Subject: ' num2str(RelevantSubjects(i))])
    xlabel('Day')
    ylabel('Chosen Paired Stimuli (per.)')
    hold on
    p = plot(1:NumRelevantDaysForSubject, DataForSubject(:,3)./DataForSubject(:,5)*100, 'r*-');
    p.LineWidth = 3;
    b.FaceColor = [ 0 0.447 0.741];
    plot(xlim,[50 50], 'k--')
    set(gca,'YGrid','on')
    set(gca,'GridLineStyle','-')
end
