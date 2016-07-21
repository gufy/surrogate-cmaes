exp_id = 'exp_doubleEC_ada_01';
exp_description = 'Surrogate CMA-ES model using double-trained EC with sd2 criterion and GPs with default population, and restrictedParam values 0.05, 0.4; 2, 3, 5, 10D; adaptive trainrange and numtrains based on GP experiments; adaptive origRatio based on rmse with default params';

% BBOB/COCO framework settings

bbobParams = { ...
  'dimensions',         { 2, 3, 5, 10 }, ...
  'functions',          num2cell(1:24), ...      % all functions: num2cell(1:24)
  'opt_function',       { @opt_s_cmaes }, ...
  'instances',          { [1:5, 41:50] }, ...    % default is [1:5, 41:50]
  'maxfunevals',        { '250 * dim' }, ...
};

% Surrogate manager parameters

surrogateParams = { ...
  'evoControl',         { 'doubletrained' }, ...    % 'none', 'individual', 'generation', 'restricted'
  'modelType',          { 'gp' }, ...               % 'gp', 'rf', 'bbob'
  'evoControlPreSampleSize', { 0 }, ...             % {0.25, 0.5, 0.75}, will be multip. by lambda
  'evoControlIndividualExtension', { [] }, ...      % will be multip. by lambda
  'evoControlBestFromExtension', { [] }, ...        % ratio of expanded popul.
  'evoControlTrainRange', { 'max(2, ceil(0.6199 + 0.1393 * dim + 0.0809 * countiter - 0.0072 * dim * countiter + 0.0004 * countiter * countiter))' }, ...               % will be multip. by sigma
  'evoControlTrainNArchivePoints', { 'max(5, ceil(-2.0468 + 0.0663 * dim + 0.1797 * countiter))' },... % will be myeval()'ed, 'nRequired', 'nEvaluated', 'lambda', 'dim' can be used
  'evoControlSampleRange', { 1 }, ...               % will be multip. by sigma
  'evoControlOrigGenerations', { [] }, ...
  'evoControlModelGenerations', { [] }, ...
  'evoControlValidatePoints', { [] }, ...
  'evoControlRestrictedParam', { 0.05, 0.4 }, ...
  'updaterType',        { 'rmse' }
};

% Model parameters

modelParams = { ...
  'useShift',           { false }, ...
  'predictionType',     { 'sd2' }, ...
  'trainAlgorithm',     { 'fmincon' }, ...
  'covFcn',             { '{@covMaterniso, 5}' }, ...
  'hyp',                { struct('lik', log(0.01), 'cov', log([0.5; 2])) }, ...
  'nBestPoints',        { 0 }, ...
  'minLeaf',            { 2 }, ...
  'inputFraction',      { 1 }, ...
  'normalizeY',         { true }, ...
};

% CMA-ES parameters

cmaesParams = { ...
  'PopSize',            { '(4 + floor(3*log(N)))'}, ...        %, '(8 + floor(6*log(N)))'};
  'Restarts',           { 4 }, ...
};

logDir = '/storage/plzen1/home/goophy/public';