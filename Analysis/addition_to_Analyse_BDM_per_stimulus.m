% Optional code to implement in the Analyse_BDM function to get the data
% sorted by stimuli and then be compatible to compare per stimuli.

% Insert the next lines after the small loop that forms the BDM_TABLES and
% then change all the 'BDM_TABLES' from that point untill the end of the
% code from BDM_TABLES to BDM_SORTED_TABLES.
% Then adapt the code to what ever you need.

    % sort to compare per stimulus
    [~,SortedOrderByStimName1] = sort(BDM_TABLES{1}.Stimulus);
    BDM_SORTED_TABLES{1} = BDM_TABLES{1}(SortedOrderByStimName1,:);
    [~,SortedOrderByStimName2] = sort(BDM_TABLES{2}.Stimulus);
    BDM_SORTED_TABLES{2} = BDM_TABLES{2}(SortedOrderByStimName2,:);
    %
    
% Good luck!

%% As I checked there is no oprion to do it for the t-test for example because there
%% are 3 Paired and 6 Unpaired stimuli so I must average them before the t-test