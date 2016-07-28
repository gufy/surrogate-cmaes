function tests = origRatioUpdaterKendallTest
  tests = functiontests(localfunctions);
end

function testAggregateTest(testCase)
    updater = OrigRatioUpdaterKendall({});
   
    verifyEqual(testCase, updater.aggregateKendallTrend(), 0);
    
    updater.kendall = [1 1 1 1 1 1 1];
    
    verifyEqual(testCase, updater.aggregateKendallTrend(), 0);
    
    updater.kendall = [0.3 0.2 0.1 0 -0.1 -0.2];
    
    verifyLessThan(testCase, updater.aggregateKendallTrend(), 0);
    
    updater.kendall = [-0.3 -0.2 -0.1 0 0.1 0.2];
    trend = updater.aggregateKendallTrend();
    display(trend);
    verifyGreaterThan(testCase, trend, 0);
    
    updater.kendall = [-0.6 -0.4 -0.2 0 0.2 1];
    biggerTrend = updater.aggregateKendallTrend();
    display(biggerTrend);
    verifyGreaterThan(testCase, biggerTrend, trend);
end

function testUpdateTest(testCase) 
    updater = OrigRatioUpdaterKendall({});
    
    %display(updater.kendall);
    %display(updater.aggregateKendallTrend());
    %display(updater.getLastRatio(4));
    
    for I = 1:100
        updater.update([0 1 2 3 4]', [4 3 2 1 0]', {}, {}, I);
    end
    % bad kendall
    verifyLessThan(testCase, updater.getLastRatio(4), 0.5);
    
    for I = 1:100
        updater.update([0 1 2 3 4]', [0 1 2 3 4]', {}, {}, I);
    end
    % great kendall
    verifyGreaterThan(testCase, updater.getLastRatio(4), 0.5);
    
end

% 
% function test1DSinTest(testCase)
%   X = (0:0.1:2)';
%   y = sin(X);
%   
%   % Test this:
%   m = RfModel([], 1);
%   m = m.train(X, y, 1, 1);
%   [yPred, dev] = m.predict(X);
%   
%   mse = mean((y - yPred).^2);
%   verifyLessThan(testCase, mse, 0.2);
%   disp(['Random forrest MSE = ' num2str(mse)]);
%   verifyLessThan(testCase, dev, 0.3);
%   disp(['Random forrest mean std = ' num2str(mean(dev))]);
% end
