function [fitness_raw, arx, arxvalid, arz, counteval, surrogateStats, lambda] = surrogateManager(xmean, sigma, lambda, BD, diagD, countiter, fitfun_handle, inOpts, varargin)
% surrogateManager  controls sampling of new solutions and using a surrogate model
%
% @xmean, @sigma, @lambda, @BD, @diagD -- CMA-ES internal variables
% @countiter            the number of the current generation
% @fitfun_handle        handle to fitness function (CMA-ES uses string name of the function)
% @inOpts               options/settings for surrogate modelling
% @varargin             arguments for the fitness function (varargin from CMA-ES)
%
% returns:
% @surrogateStats       vector of numbers with variable model/surrogate statsitics

  persistent generationEC;
  % generationEC - one such instance for evolution control, persistent between
  % different calls of the surrogateManager() function
  % TODO: test, if generationEC really works; GenerationEC is now derived from handle

  persistent lastModel;         % last successfully trained model
  persistent archive;           % archive of original-evaluated individuals

  % TODO: make an array with all the status variables from each generation

  % Defaults for surrogateOpts
  sDefaults.evoControl  = 'none';                 % none | individual | generation | restricted
  sDefaults.sampleFcn   = @sampleCmaes;           % sampleCmaes | ??? TODO ???
  sDefaults.evoControlPreSampleSize       = 0.2;  % 0..1
  sDefaults.evoControlIndividualExtension = 20;   % 1..inf (reasonable 10-100)
  sDefaults.evoControlSamplePreprocessing = false;
  sDefaults.evoControlBestFromExtension   = 0.2;  % 0..1
  sDefaults.evoControlTrainRange          = 8;    % 1..inf (reasonable 1--20)
  sDefaults.evoControlSampleRange         = 1;    % 1..inf (reasonable 1--20)
  sDefaults.evoControlOrigGenerations     = 1;    % 1..inf
  sDefaults.evoControlModelGenerations    = 1;    % 0..inf
  sDefaults.evoControlTrainNArchivePoints = 0;
  sDefaults.evoControlValidatePoints      = 0;
  sDefaults.evoControlRestrictedParam     = 0.2;    % 0..1
  sDefaults.evoControlSwitchMode          = 'none'; % none | individual | generation | restricted
  sDefaults.evoControlSwitchBound         = inf;    % 1 .. inf (reasonable 10--100)
  sDefaults.evoControlSwitchPopulation    = 1;      % 1 .. inf (reasonable 1--20)
  sDefaults.evoControlSwitchPopBound      = inf;    % 1 .. inf (reasonable 10--100)
  sDefaults.modelType = '';                         % gp | rf
  sDefaults.modelOpts = [];                         % model specific options

  surrogateStats = NaN(1, 2);

  % copy the defaults settings...
  surrogateOpts = sDefaults;
  % and replace those set in the surrogateOpts:
  for fname = fieldnames(inOpts)'
    surrogateOpts.(fname{1}) = inOpts.(fname{1});
  end

  assert(size(xmean,2) == 1, 'surrogateManager(): xmean is not a column vector!');
  dim = size(xmean,1);

  % switching evolution control
  if surrogateOpts.sampleOpts.counteval > surrogateOpts.evoControlSwitchBound*dim
    surrogateOpts.evoControl = surrogateOpts.evoControlSwitchMode;
  end
  
  if surrogateOpts.sampleOpts.origPopSize == lambda && surrogateOpts.sampleOpts.counteval > surrogateOpts.evoControlSwitchPopBound*dim
    lambda = ceil(surrogateOpts.evoControlSwitchPopulation * lambda);
  end

  % evolution control -- use model? individual? generation?
  if (strcmpi(surrogateOpts.evoControl, 'none'))
    % No model at all
    if (strcmpi(func2str(surrogateOpts.sampleFcn), 'samplecmaes'))
      [fitness_raw, arx, arxvalid, arz, counteval] = sampleCmaes(xmean, sigma, lambda, BD, diagD, fitfun_handle, surrogateOpts.sampleOpts, varargin{:});
      surrogateOpts.sampleOpts.counteval = counteval;
    else
      error('surrogateManager: the only sampling method without model is "sampleCmaes()"');
    end
    return;
  end

  if (countiter == 1)
    archive = Archive(dim);
    ec = ECFactory.createEC(surrogateOpts);
  end
  
  cmaesState = struct( ...
    'xmean', xmean, ...
    'sigma', sigma, ...
    'lambda', lambda, ...
    'BD', BD, ...
    'diagD', diagD, ...
    'fitfun_handle', fitfun_handle, ...
    'countiter', countiter, ...
    'sampleOpts', surrogateOpts.sampleOpts);
  
  [fitness_raw, arx, arxvalid, arz, counteval, lambda, archive, surrogateStats] = ec.runGeneration(cmaesState, archive);
  surrogateOpts.sampleOpts.counteval = counteval;
  
  if (size(fitness_raw, 2) < lambda)
    % the model was in fact not trained
    disp('surrogateManager(): the model was not successfully trained.');
    [yNew, xNew, xNewValid, zNew, counteval] = sampleCmaes(xmean, sigma, lambda - size(fitness_raw, 2), BD, diagD, fitfun_handle, surrogateOpts.sampleOpts, varargin{:});
    surrogateOpts.sampleOpts.counteval = counteval;
    archive = archive.save(xNewValid', yNew', countiter);

    % save the resulting re-evaluated population as the returning parameters
    fitness_raw = [fitness_raw yNew];
    arx = [arx xNew];
    arxvalid = [arxvalid xNewValid];
    arz = [arz zNew];
  end
  
  assert(min(fitness_raw) >= min(archive.y), 'Assertion failed: minimal predicted fitness < min in archive by %e', min(archive.y) - min(fitness_raw));

  if (strcmpi(surrogateOpts.evoControl, 'generation'))
    % Generation-based evolution control

    % Call this only once (during the first generation)
    if (countiter == 1)
      if (isfield(surrogateOpts, 'evoControlInitialGenerations'))
        initialGens = surrogateOpts.evoControlInitialGenerations;
      else
        initialGens = 0;
      end
      generationEC = GenerationEC(surrogateOpts.evoControlOrigGenerations, ...
        surrogateOpts.evoControlModelGenerations, initialGens);
    end

    sampleSigma = surrogateOpts.evoControlSampleRange * sigma;

    if (generationEC.evaluateOriginal)
      %
      % original-evaluated generation
      %
      [fitness_raw, arx, arxvalid, arz, counteval] = sampleCmaes(xmean, sampleSigma, lambda, BD, diagD, fitfun_handle, surrogateOpts.sampleOpts, varargin{:});

      surrogateOpts.sampleOpts.counteval = counteval;
      archive = archive.save(arxvalid', fitness_raw', countiter);
      if (~ generationEC.isNextOriginal())
        % we will switch to 'model'-mode in the next generation
        % prepare data for a new model

        [newModel, surrogateStats, isTrained] = trainGenerationECModel(newModel, archive, xmean, sigma, lambda, BD, diagD, surrogateOpts, countiter);

        if (isTrained)
          % TODO: archive the lastModel...?
          lastModel = newModel;
        else
          % not enough training data :( -- continue with another
          % 'original'-evaluated generation
          generationEC = generationEC.holdOn();
          return;
        end
      end       % ~ generationEC.isNextOriginal()

    else        % generationEC.evaluateModel() == true
      %
      % evalute the current population with the @lastModel
      %
      % TODO: implement other re-fitting strategies for an old model

      if (isempty(lastModel))
        warning('surrogateManager(): we are asked to use an EMPTY MODEL! Using CMA-ES.');
        [fitness_raw, arx, arxvalid, arz, counteval] = sampleCmaes(xmean, sampleSigma, lambda, BD, diagD, fitfun_handle, surrogateOpts.sampleOpts, varargin{:});
        surrogateOpts.sampleOpts.counteval = counteval;
        archive = archive.save(arxvalid', fitness_raw', countiter);
        return;
      end

      % generate the new population (to be evaluated by the model)
      [arx, arxvalid, arz] = ...
          sampleCmaesNoFitness(xmean, sigma, lambda, BD, diagD, surrogateOpts.sampleOpts);

      % generate validating population (for measuring error of the prediction)
      % this is with the *original* sigma
      [~, xValidValid, zValid] = ...
          sampleCmaesNoFitness(xmean, sigma, lambda, BD, diagD, surrogateOpts.sampleOpts);
      % shift the model (and possibly evaluate some new points newX, newY = f(newX) )
      % newX = []; newY = []; newZ = []; evals = 0;
      [shiftedModel, evals, newX, newY, newZ] = lastModel.generationUpdate(xmean', xValidValid', zValid', surrogateOpts.evoControlValidatePoints, fitfun_handle, varargin{:});
      % count the original evaluations
      surrogateOpts.sampleOpts.counteval = surrogateOpts.sampleOpts.counteval + evals;
      counteval = surrogateOpts.sampleOpts.counteval;
      fitness_raw = zeros(1,lambda);
      % use the original-evaluated xValid points to the new generation:
      if (evals > 0)
        archive = archive.save(newX, newY, countiter);
        % calculate 'z' for the shifted archive near-mean point
        % because this near-mean is not sampled as Z ~ N(0,1)
        newZ(1,:) = ((BD \ (newX(1,:)' - xmean)) ./ sigma)';
        % save this point to the final population
        arx(:,1) = newX(1,:)';
        % this is a little hack :/ -- we suppose that all the newX are valid
        % but this should be true since 'newX' is derived from 'xValidValid'
        arxvalid(:,1) = newX(1,:)';
        arz(:,1) = newZ(1,:)';
        fitness_raw(1) = newY(1)';
        remainingIdx = 2:lambda;
      else
        remainingIdx = 1:lambda;
      end
      % calculate/predict the fitness of the not-so-far evaluated points
      if (~isempty(shiftedModel))
        % we've got a valid model, so we'll use it!
        [predict_fitness_raw, ~] = shiftedModel.predict(arx(:,remainingIdx)');
        fitness_raw(remainingIdx) = predict_fitness_raw';
        disp(['Model.generationUpdate(): We are using the model for ' num2str(length(remainingIdx)) ' individuals.']);
        % shift the predicted fitness: the best predicted fitness
        % could not be better than the so-far best fitness -- it would fool CMA-ES!
        % TODO: test if shifting ALL THE INDIVIDUALS (not only predicted) would help?
        bestFitnessArchive = min(archive.y);
        bestFitnessPopulation = min(fitness_raw);
        diff = max(bestFitnessArchive - bestFitnessPopulation, 0);
        fitness_raw = fitness_raw + diff;

        % DEBUG:
        fprintf('  test ');
        surrogateStats = getModelStatistics(shiftedModel, xmean, sigma, lambda, BD, diagD, surrogateOpts, countiter);

      else
        % we don't have a good model, so original fitness will be used
        [fitness_raw_, arx_, arxvalid_, arz_, counteval] = ...
            sampleCmaesOnlyFitness(arx(:,remainingIdx), arxvalid(:,remainingIdx), arz(:,remainingIdx), xmean, sigma, length(remainingIdx), BD, diagD, fitfun_handle, surrogateOpts.sampleOpts, varargin{:});
        surrogateOpts.sampleOpts.counteval = counteval;
        arx(:,remainingIdx) = arx_;
        arxvalid(:,remainingIdx) = arxvalid_;
        arz(:,remainingIdx) = arz_;
        fitness_raw(remainingIdx) = fitness_raw_;
        archive = archive.save(arxvalid_', fitness_raw_', countiter);

        % train a new model for the next generation
        [newModel, surrogateStats, isTrained] = trainGenerationECModel(newModel, archive, xmean, sigma, lambda, BD, diagD, surrogateOpts, countiter);

        if (isTrained)
          % TODO: archive the lastModel...?
          lastModel = newModel;
          % leave the next generation as a model-evaluated:
          generationEC = generationEC.holdOn();
        else
          % not enough training data :( -- continue with
          % 'original'-evaluated generation
          generationEC = generationEC.setNextOriginal();
        end
      end
      % and set the next as original-evaluated (later .next() will be called)
    end
    generationEC = generationEC.next();
    %
    % end of Generation-based evolution control

    % DEBUG
    % disp(fitness_raw);

  else
    error('surrogateManager(): wrong evolution control method');
  end
end

function [newModel, surrogateStats, isTrained] = trainGenerationECModel(model, archive, xmean, sigma, lambda, BD, diagD, surrogateOpts, countiter)
  surrogateStats = NaN(1, 2);
% train the 'model' on the relevant data in 'archive'
  isTrained = false;
  dim = model.dim;

  trainSigma = surrogateOpts.evoControlTrainRange * sigma;
  nArchivePoints = myeval(surrogateOpts.evoControlTrainNArchivePoints);

  nRequired = model.getNTrainData();
  [X, y] = archive.getDataNearPoint(nArchivePoints, ...
      xmean', surrogateOpts.evoControlTrainRange, trainSigma, BD);
  if (length(y) >= nRequired)
    % we have got enough data for new model! hurraayh!
    sampleVariables = struct( ...
      'xmean', xmean, ...
      'sigma', sigma, ...
      'lambda', lambda, ...
      'BD', BD, ...
      'diagD', diagD, ...
      'sampleOpts', surrogateOpts.sampleOpts);
    % TODO: omit the unnecessary variables xmean, sigma and BD
    % as they are already in sampleVariables
    newModel = model.train(X, y, xmean', countiter, sigma, BD, sampleVariables);
    isTrained = (newModel.trainGeneration > 0);

    % DEBUG: print and save the statistics about the currently
    % trained model on testing data (RMSE and Kendall's correlation)
    if (isTrained)
      fprintf('  model trained on %d points, train ', length(y));
      surrogateStats = getModelStatistics(newModel, xmean, sigma, lambda, BD, diagD, surrogateOpts, countiter);
    end
  else
    newModel = model;
    isTrained = false;
  end
end
