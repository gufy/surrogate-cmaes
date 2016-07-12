opt_function = @opt_adaptive;
dim = 5;
maxfunevals = 500;
exppath = '/Users/vojta/Documents/MATLAB/surrogate-cmaes/exp/experiments/exp_adaptive_01_05D/';
load([exppath 'scmaes_params.mat'], 'bbParamDef', 'sgParamDef', 'cmParamDef', 'exp_id', 'exppath_short', 'logDir');

id = 1;
bbob_function = 101;
iinstance = 1;
datapath = '/Users/vojta/Documents/MATLAB/surrogate-cmaes/exp/experiments/exp_adaptive_01_05D/bbob_output';
opt = struct('comments', '', 'algName', 'exp_adaptive_01_05D');

fgeneric('initialize', bbob_function, iinstance, datapath, opt); 
opt_function('fgeneric', dim, fgeneric('ftarget'), maxfunevals, id, exppath);

%%

load('all.mat');

bbob_function = 101;
iinstance = 1;
opt = struct('comments', '', 'algName', 'exp_adaptive_01_05D');
datapath = '/Users/vojta/Documents/MATLAB/surrogate-cmaes/exp/experiments/exp_adaptive_01_05D/bbob_output';
fgeneric('initialize', bbob_function, iinstance, datapath, opt); 

sigma = [];
fun = @(x) model.modelPredict(x');

sgParams.modelType = 'gp';
sgParams.warmup = struct('numGenerations', 5, 'fun', fun);

%[xCm, fminCm, ~, stopflagCm, ~, besteverCm, ~] = s_cmaes(fun, xbest, sigma, cmOpts);

s_cmaes('fgeneric', xbest, 8/3, cmOpts, 'SurrogateOptions', sgParams);

%%

bbob_test_01(1, 'exp_restrEC_10_2pop_ada', '/Users/vojta/Documents/MATLAB/surrogate-cmaes/exp/experiments')

%%

funcSet = struct('BBfunc', 1, 'dims', 2);
[evals, settings] = dataReady(exppath, funcSet);

colors = [1];
datanames = {'1'};
data = {evals{1}};
plotDims = [2];

han = relativeFValuesPlot(data, ...
          'DataNames', datanames, 'DataDims', funcSet.dims, ...
          'DataFuns', funcSet.BBfunc, 'Colors', colors, ...
          'PlotFuns', funcSet.BBfunc, 'PlotDims', plotDims, ...
          'AggregateDims', false, 'OneFigure', true, ...
          'Statistic', @median, 'AggregateFuns', true, ...
          'LegendOption', 'show', 'MaxEval', 100);
          