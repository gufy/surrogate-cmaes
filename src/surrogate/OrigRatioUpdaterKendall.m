classdef OrigRatioUpdaterKendall < OrigRatioUpdater
  % TODO:
  % [ ] use just the real values of kendall
    
  properties
    origParams
    lastRatio
    
    parsedParams
    maxRatio
    minRatio
    updateRate
    logKendallRatioTreshold
    
    kendall
    lastUpdateGeneration
    
    plotDebug = 1;
    historyKendall = [];
    historyRatio = [];
    historyTrend = [];
    fh
  end
  
  methods 
    % get new value of parameter
    function newRatio = update(obj, modelY, origY, ~, ~, countiter, nWeights)
      % ratio is updated according to the following formula
      %
      % newRatio = lastRatio + updateRate*(logKendallWeights.*logKendall - logKendallRatioTreshold)     (eqn. 1)
      % newRatio = min(max(newRatio, minRatio), maxRatio)
      %
      % Notes:
      % - update() should be called every generation; if all the samples
      %   were evaluated with the original fitness, model should be also
      %   constructed and reasonable modelY values should be passed here
      % - if update() is not called in any particular generation(s),
      %   it results in zero NaN entry for that generation(s)
      
      obj.kendall((obj.lastUpdateGeneration+1):(countiter-1)) = NaN;
      
      obj.lastUpdateGeneration = countiter;
            
      if isempty(modelY) || std(modelY) == 0 || std(origY) == 0
        obj.kendall(countiter) = NaN;
      else
        obj.kendall(countiter) = corr(modelY, origY, 'type', 'Kendall');
      end
      
      ratio = aggregateKendallTrend(obj, nWeights);
      
      % obj.lastRatio is initialized as 'startRatio' parameter in the
      % constructor
      
      if ratio < obj.lastRatio 
        newRatio = obj.minRatio;
      else
        newRatio = obj.lastRatio + obj.updateRate * (ratio - obj.lastRatio);
      end
      newRatio = min(max(newRatio, obj.minRatio), obj.maxRatio);
      
      if obj.plotDebug
          fprintf('New ratio=%0.2f based on kendall trend=%0.2f\n', newRatio, ratio);

          obj.historyRatio = [obj.historyRatio newRatio];
          obj.historyKendall = [obj.historyKendall obj.kendall(countiter)];
          obj.historyTrend = [obj.historyTrend ratio];
      end
      
      obj.lastRatio = newRatio;
    end

    function obj = OrigRatioUpdaterKendall(parameters)
      % constructor
      obj = obj@OrigRatioUpdater(parameters);
      obj.parsedParams = struct(parameters{:});
      % maximal possible ratio returned by getValue
      obj.maxRatio = defopts(obj.parsedParams, 'maxRatio', 1);
      % minimal possible ratio returned by getValue
      obj.minRatio = defopts(obj.parsedParams, 'minRatio', 0);
      % starting value of ratio for initial generations
      obj.lastRatio = defopts(obj.parsedParams, 'startRatio', (obj.maxRatio - obj.minRatio)/2);
      % how much is the lastRatio affected by the weighted Kendall trend
      obj.updateRate = defopts(obj.parsedParams, 'updateRate', 0.45);
      
      obj.kendall = [];
      obj.lastUpdateGeneration = 0;
      
      if obj.plotDebug 
        figure;
        obj.fh = axes;
      end
    end
    
    function value = aggregateKendallTrend(obj, nWeights)
      % aggregate last Kendall's into one value expressing an increasing or
      % decreasing trend
      %
      % This implementation:
      % - replaces NaN's with maximal values from the last Kendall entries
      % - calculates aggregate value as
      %
      %   partsum(i) = weights(i) * log(kendall(end-i+1) / kendall(end-i)
      %   value      = sum( partsum )
      
      % default value of imaginary Kendall when all Kendall values are NaN
      % in the last obj.kendall entries
      
      logKendallWeights = exp(1:nWeights);
      logKendallWeights = logKendallWeights / sum(logKendallWeights);
      nWeights = min(length(obj.kendall) - 1, length(logKendallWeights));
      localKendall = obj.kendall(end - nWeights + 1 : end);
      weights = logKendallWeights(1:nWeights);
      weights = weights(~isnan(localKendall));
      localKendall = localKendall(~isnan(localKendall));
      weights = weights / sum(weights);
      weightedKendall = weights .* localKendall;
      
      if length(weightedKendall) < 1
        % we don't have enough Kendall history values ==> stay at the
        % current origRatio ==> set aggregateKendallTrend = 0
        value = 0;
        return
      end
      
      % replace zeros for division
      weightedKendall(abs(weightedKendall) < eps) = 100*eps*sign(weightedKendall(abs(weightedKendall) < eps));
      weightedKendall(weightedKendall == 0) = 100*eps;
      
      avgKendall = sum(weightedKendall);
      value = avgKendall;
    end
    
    function value = getLastRatio(obj, countiter, nWeights)
      if countiter > obj.lastUpdateGeneration + 1
        obj.update([], [], [], [], countiter, nWeights);
      end
      value = obj.lastRatio;
      
      if obj.plotDebug
          scatter(1:length(obj.historyKendall), obj.historyKendall, 140, '.');
          hold on;
          scatter(1:length(obj.historyTrend), obj.historyTrend, 140, '.');
          scatter(1:length(obj.historyRatio), obj.historyRatio, 140, '.');
          legend('Kendall', 'Trend', 'Ratio');
          hold off;
          pause(0.0001);    
      end
      
    end
    
  end
end
