classdef DTScreenStatistics < Observer
%SCREENSTATISTICS -- print statistics from DoubleTrainEC on screen
  properties
    verbosity
  end

  methods
    function obj = DTScreenStatistics(params)
      obj@Observer();
      verbosity = defopts(params, 'verbose', 5);
    end

    function notify(obj, ec, varargin)
      % get the interesting data and process them
      if (mod(ec.cmaesState.countiter, 10) == 1)
        fprintf('####### iter /evals(or) | D_fopt. | rmseRee | rnkR | rnk2 | .rankErrValid. | M nData | ..sigma.\n');
      end
      model = '.';
      nTrainData = 0;
      if (~isempty(ec.model) && ec.model.isTrained() ...
          && ec.model.trainGeneration == ec.cmaesState.countiter)
        model = '+'; nTrainData = ec.model.getTrainsetSize(); end
      if (~isempty(ec.retrainedModel) && ec.retrainedModel.isTrained() ...
          && ec.retrainedModel.trainGeneration == ec.cmaesState.countiter)
        model = '#'; nTrainData = ec.retrainedModel.getTrainsetSize(); end
      %       '##### iter /evals(or) |D_fopt.|rmseRee|rnkR| rnk2 |rankErrValid| M nData | ..sigma.\n');
      fprintf('=[DTS]= %4d /%5d(%2d) | %.1e | %.1e | %.2f | %.2f | %.2f %s | %s %2d/%2d | %.2e\n', ...
          ec.cmaesState.countiter, ec.counteval, sum(ec.pop.origEvaled), ...
          ec.stats.fmin - ec.surrogateOpts.fopt, ...
          ec.stats.rmseReeval, ...
          ec.stats.rankErrReeval, ...
          ec.stats.rankErr2Models, ...
          ec.stats.rankErrValid, decorateKendall(1-2*ec.stats.rankErrValid), ...
          model, nTrainData, ec.stats.nDataInRange, ...
          ec.cmaesState.sigma ...
          );
    end
  end
end
