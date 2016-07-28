classdef OrigRatioUpdaterKendall < OrigRatioUpdater
  properties
    origParams
    lastRatio
    
    parsedParams
    maxRatio
    minRatio
    updateRate
    logKendallWeights
    logKendallRatioTreshold
    
    kendall
    lastUpdateGeneration
  end
  
  methods 
    % get new value of parameter
    function newRatio = update(obj, modelY, origY, ~, ~, countiter)
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
      
      trend = aggregateKendallTrend(obj);
      
      % obj.lastRatio is initialized as 'startRatio' parameter in the
      % constructor
      newRatio = obj.lastRatio + obj.updateRate * ( -1 * trend);
      newRatio = min(max(newRatio, obj.minRatio), obj.maxRatio);
      
      obj.lastRatio = newRatio;
    end

    function obj = OrigRatioUpdaterKendall(parameters)
      % constructor
      obj = obj@OrigRatioUpdater(parameters);
      obj.parsedParams = struct(parameters{:});
      % maximal possible ratio returned by getValue
      obj.maxRatio = defopts(obj.parsedParams, 'maxRatio', 1);
      % minimal possible ratio returned by getValue
      obj.minRatio = defopts(obj.parsedParams, 'minRatio', 0.1);
      % starting value of ratio for initial generations
      obj.lastRatio = defopts(obj.parsedParams, 'startRatio', (obj.maxRatio - obj.minRatio)/2);
      % how much is the lastRatio affected by the weighted Kendall trend
      obj.updateRate = defopts(obj.parsedParams, 'updateRate', 0.45);
      % weights for the weighted sum of the log Kendall ratios
      obj.logKendallWeights = defopts(obj.parsedParams, 'logKendallWeights', [0.5, 0.3, 0.2]);
      % normalize weights
      obj.logKendallWeights = obj.logKendallWeights / sum(obj.logKendallWeights);
      obj.kendall = [];
      obj.lastUpdateGeneration = 0;
    end
    
    function value = aggregateKendallTrend(obj)
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
      DEFAULT_KENDALL = 0;
      
      nWeights = min(length(obj.kendall) - 1, length(obj.logKendallWeights));
      localKendall = obj.kendall(end - nWeights : end);
      
      local_max_kendall = 2*max(localKendall(~isnan(localKendall)));
      if isempty(local_max_kendall)
        localKendall(isnan(localKendall)) = DEFAULT_KENDALL;
      else
        localKendall(isnan(localKendall)) = local_max_kendall;
      end
      
      if length(localKendall) <= 1
        % we don't have enough Kendall history values ==> stay at the
        % current origRatio ==> set aggregateKendallTrend = 0
        value = 0;
        return
      end
      assert(length(localKendall)-1 == nWeights, 'DEBUG assertion failed: length of Kendall ~= nWeights + 1');
      
      % replace zeros for division
      localKendall(abs(localKendall) < eps) = 100*eps*sign(localKendall(abs(localKendall) < eps));
      localKendall(localKendall == 0) = 100*eps;
      
      ratios = localKendall(2:end) - localKendall(1:end-1);
      
      value = sum(obj.logKendallWeights(1:nWeights) .* ratios(end:-1:1));
    end
    
    function value = getLastRatio(obj, countiter)
      if countiter > obj.lastUpdateGeneration + 1
        obj.update([], [], [], [], countiter);
      end
      value = obj.lastRatio;
    end
    
  end
end
