
weights = [0.5, 0.3, 0.2, 0.1, 0.1];
weights = weights / sum(weights);

maxN = 1000;
lastN = 20;
startN = 10;

kendall = sin(linspace(1,lastN,maxN)) + (rand(1,maxN)*0.5);
minRatio = 0.1;
maxRatio = 1;
lastRatio = (minRatio + maxRatio) / 2;
updateRate = 0.45;

ratios = zeros(1,maxN - startN);
trends = zeros(1,maxN - startN);

for I = startN:maxN
    
    nWeights = min(length(kendall) - 1, length(weights));
    localKendall = kendall(I - nWeights : I);
    localKendall(abs(localKendall) < eps) = 100*eps*sign(localKendall(abs(localKendall) < eps));
    localKendall(localKendall == 0) = 100*eps;
%    currentRatios = localKendall(2:end) - localKendall(1:end-1);
%    trend = sum(weights(1:nWeights) .* currentRatios(end:-1:1));
    
    avgKendall = sum(weights(1:nWeights) .* localKendall(2:end));
    ratio = (-avgKendall + 1) + minRatio;
    newRatio = lastRatio + updateRate * (ratio - lastRatio);
    newRatio = min(max(newRatio, minRatio), maxRatio);
  
    trends(I) = trend;
    ratios(I) = newRatio;
    lastRatio = newRatio;
    
end

figure;
plot(1:maxN, kendall);
hold on;
plot(1:maxN, trends);
plot(1:maxN, ratios);
legend('kendall','trends','ratios');