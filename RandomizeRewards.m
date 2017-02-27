function RandomizedVec = RandomizeRewards(RequiredMean, minSum, maxSum, VecLength)

% function RandomizedVec = RandomizedRewards(RequiredMean, min, max, VecLength)
%
% MUST HAVE THE FUNCTION expample.m IN THE SAME FOLDER.
%
% This function will create a randomized vector of integers with average,
% min, and max in a given length.
% avergae will be accurate in 1% deviates up and down.

% For debugging remove all percentage mark.
%minSum = 10;
%maxSum = 50;
%RequiredMean = 20;
%VecLength = 90

interval = 1; % interval: the interval to ceil to (1 for integers)
RandomizedVec = zeros(1,VecLength);

%Check If it should be for uniform distribution.
IsUniformDistribution = (minSum + maxSum)/2 == RequiredMean;

if IsUniformDistribution  
    while mean(RandomizedVec) < 0.99*RequiredMean || mean(RandomizedVec) > 1.01*RequiredMean % && Counter < 10000
        for i = 1:length(RandomizedVec)
            RandomizedVec(i) = randi([minSum,maxSum]);
        end
    end
else
    %Counter = 0;
    while mean(RandomizedVec) < 0.99*RequiredMean || mean(RandomizedVec) > 1.01*RequiredMean % && Counter < 10000
        for i = 1:length(RandomizedVec)
            RandomizedVec(i) = expsample(RequiredMean,minSum,maxSum,interval);
        end
        %Counter = Counter+1
    end
    %mean(RandomSumsOfMoney)
end

end