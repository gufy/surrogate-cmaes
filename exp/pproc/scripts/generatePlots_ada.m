%% PPSN 2016 article plots
% Script for making graphs showing the dependence of minimal function
% values on the number of function values and graphs showing the speed up
% of GP DTS-CMA-ES.
% 
% Created for PPSN 2016 article.

%% load data

% checkout file containing all loaded data
if ispc
  osTmp = fullfile('exp', 'pproc', 'scripts', 'tmp');
  if ~exist(osTmp, 'dir')
    mkdir(osTmp)
  end
else
  osTmp = '/tmp';
end
tmpFName = fullfile(osTmp, 'localdata.mat');
if (0 && exist(tmpFName', 'file'))
  load(tmpFName);
else
  
% folder for results
actualFolder = pwd;
articleFolder = fullfile(actualFolder(1:end - 1 - length('surrogate-cmaes')), 'latex_scmaes', 'ppsn2016paper');
plotResultsFolder = fullfile(articleFolder, 'images');
tableFolder = fullfile(articleFolder, 'tex');

% path settings
exppath = fullfile('exp', 'experiments');

sd2_r10_20_path = fullfile(exppath, 'exp_restrEC_10_2pop_ada');

cmaespath = fullfile(exppath, 'CMA-ES');
smac_path = fullfile(exppath, 'SMAC');

mgso_matern_path = fullfile(exppath, 'MGSO_Matern');
mgso_se_path = fullfile(exppath, 'MGSO_SE');

% needed function and dimension settings
funcSet.BBfunc = 1:24;
funcSet.dims = [2, 3, 5, 10];

% loading data
[sd2_r10_20_evals, sd2_r10_20_settings] = dataReady(sd2_r10_20_path, funcSet);

% concatenate cmaes 2-10D
cmaes_evals = bbobDataReady(cmaespath, funcSet);
smac_evals = readSMACResults(smac_path, funcSet);
mgso_matern_evals = bbobDataReady(mgso_matern_path, funcSet);
mgso_se_evals = bbobDataReady(mgso_se_path, funcSet);

%for f = 1:size(cmaes_evals, 1)
%  for d = 1:size(cmaes_evals, 2)
%    notEmptyId = ~cellfun(@isempty, cmaes_evals(f, d, :));
%    cmaes_evals{f,d,1} = cmaes_evals{f, d, notEmptyId};
%  end
%end
%cmaes_evals = cmaes_evals(:, :, 1);

% Uncomment if necessary:
% This is a hack due to distributed and merged part of 20D experiment:
% if (length(gen_settings_20D) > 4)
%   gen_settings_20D(1:4) = gen_settings_20D((end-3):end);
%   gen_settings_20D(5:end) = [];
% end

% finding data indexes
clear set
set.modelType = 'gp';
set.modelOpts.normalizeY = true;
set.evoControlModelGenerations = 5;

set = rmfield(set, 'evoControlModelGenerations');
set.modelOpts.predictionType = 'sd2';
set.PopSize = '(4 + floor(3*log(N)))';
set.evoControlRestrictedParam = 0.05;
sd2_r05_2pop_ada_Id = getStructIndex(sd2_r10_20_settings, set);

set.evoControlRestrictedParam = 0.4;
sd2_r40_2pop_ada_Id = getStructIndex(sd2_r10_20_settings, set);

% concatenate data

sd2Data_05_2pop = sd2_r10_20_evals(:, :, sd2_r05_2pop_ada_Id);
sd2Data_40_2pop = sd2_r10_20_evals(:, :, sd2_r40_2pop_ada_Id);
cmaesData = cmaes_evals;
smacData = smac_evals;
mgsoMaternData = mgso_matern_evals;
mgsoSeData = mgso_se_evals;

% color settings
cmaesCol = [22 22 138];
smacCol = [255, 155, 0];

sd2Col = [0,0,0];

sd2Col_05 = [255,0,147-96];
sd2Col_40 = [255,20+96,147+96];

mgsoCol_matern = [148,0,211];
mgsoCol_se = [200,170,39];

sd2Col_05_2pop = [154 205 50];
sd2Col_10_2pop = [34,139,34];
sd2Col_20_2pop = [0,128,128];
sd2Col_40_2pop = [70,130,180];

% evaluation target settings
defTargets = floor(power(20, linspace(1, log(250)/log(20), 25)));

if (~exist(tmpFName, 'file'))
  save(tmpFName);
end

end

%% Used Output

%% Criterion comparison: EI, PoI, lcb, sd2
% Aggregation of function values across dimensions  5, 20.

data = {sd2Data_05_2pop, ...
        sd2Data_40_2pop,  ...
        cmaesData, ...
        smacData, ...
        mgsoMaternData, ...
        mgsoSeData ...
        };

datanames = {'ada 0.05', 'ada 0.40', 'CMA-ES', 'SMAC', 'MGSO Matern', 'MGSO SE'};

colors = [sd2Col_05; sd2Col_40; cmaesCol; smacCol; mgsoCol_matern; mgsoCol_se]/255;

plotDims = [2,3,5,10];

clear pdfNames
pdfNames = fullfile(plotResultsFolder, 'crit5_20D');

close all
han = relativeFValuesPlot(data, ...
                              'DataNames', datanames, 'DataDims', funcSet.dims, ...
                              'DataFuns', funcSet.BBfunc, 'Colors', colors, ...
                              'PlotFuns', funcSet.BBfunc, 'PlotDims', plotDims, ...
                              'AggregateDims', false, 'OneFigure', true, ...
                              'Statistic', @median, 'AggregateFuns', true, ...
                              'LegendOption', 'show', 'MaxEval', 100);
                            
print2pdf(han, pdfNames, 1)

%% Population size comparison: default, 2*default
% Aggregation of function values across dimensions 5, 20.

data = {sd2Data_05_2pop, ...
        sd2Data_40_2pop  ...
        };

datanames = {'0.05 2pop ada', '0.40  2pop ada'};

colors = [sd2Col_05_2pop; sd2Col_40_2pop]/255;
        
plotDims = [5];

clear pdfNames
pdfNames = fullfile(plotResultsFolder, 'pop5_20D');

close all
han = relativeFValuesPlot(data, ...
                              'DataNames', datanames, 'DataDims', funcSet.dims, ...
                              'DataFuns', funcSet.BBfunc, 'Colors', colors, ...
                              'PlotFuns', funcSet.BBfunc, 'PlotDims', plotDims, ...
                              'AggregateDims', false, 'OneFigure', true, ...
                              'Statistic', @median, 'AggregateFuns', true, ...
                              'LegendOption', 'show', 'MaxEval', 100);
                            
print2pdf(han, pdfNames, 1)

%% Algorithm comparison: DTS-CMA-ES, S-CMA-ES, saACMES, SMAC, CMA-ES
% Aggregation of function values across dimensions 2, 5, 10, 20.

data = {sd2Data_05_2pop, ...
        sd2Data_40_2pop  ...
        };

datanames = {'DTS 0.05 2pop', 'DTS 0.40 2pop'};

colors = [sd2Col_05_2pop; sd2Col_40_2pop]/255;

plotDims = [2, 3, 5, 10];

clear pdfNames
pdfNames = fullfile(plotResultsFolder, 'alg2_5_10_20D');

close all
han = relativeFValuesPlot(data, ...
                              'DataNames', datanames, 'DataDims', funcSet.dims, ...
                              'DataFuns', funcSet.BBfunc, 'Colors', colors, ...
                              'PlotFuns', funcSet.BBfunc, 'PlotDims', plotDims, ...
                              'AggregateDims', false, 'OneFigure', true, ...
                              'Statistic', @median, 'AggregateFuns', true, ...
                              'LegendOption', 'split', 'MaxEval', 100);
                            
print2pdf(han, pdfNames, 1)

%% Algorithm ranking comparison: DTS 0.1 1pop, DTS 0.05 2pop, S-CMA-ES, saACMES, SMAC, CMA-ES
% Aggregation of function values across dimensions 2, 3, 5, 10, 20.

close all

data = {sd2Data_05_2pop, ...
        sd2Data_40_2pop};

datanames = {'DTS 0.05 2pop', 'DTS 0.40 2pop'};

tableFunc = funcSet.BBfunc;
tableDims = funcSet.dims;

resultTable = fullfile(tableFolder, 'rankTable.tex');
      
[table, ranks] = rankingTable(data, 'DataNames', datanames, ...
                           'DataFuns', funcSet.BBfunc, 'DataDims', funcSet.dims, ...
                           'TableFuns', tableFunc, 'TableDims', tableDims,...
                           'Evaluations', [20 40 80], ...
                           'ResultFile', resultTable);
                         
%% Testing Output


%% Criterion comparison: EI, PoI, lcb, sd2
% Aggregation of function values across dimensions 2, 3, 5, 10, 20.

data = {sd2Data_05_2pop, ...
        sd2Data_40_2pop};

datanames = {'sd2 0.05', 'sd2 0.40'};

colors = [sd2Col; sd2Col]/255;

plotDims = [2, 3, 5, 10];

for f = funcSet.BBfunc

  %% 
  close all

  fprintf('Function %d\n', f)
  han = relativeFValuesPlot(data, ...
                              'DataNames', datanames, 'DataDims', funcSet.dims, ...
                              'DataFuns', funcSet.BBfunc, 'Colors', colors, ...
                              'PlotFuns', f, 'PlotDims', plotDims, ...
                              'AggregateDims', true, 'SplitLegend', true, ...
                              'Statistic', @median, 'AggregateFuns', false);
end
%%
close all
han = relativeFValuesPlot(data, ...
                              'DataNames', datanames, 'DataDims', funcSet.dims, ...
                              'DataFuns', funcSet.BBfunc, 'Colors', colors, ...
                              'PlotFuns', funcSet.BBfunc, 'PlotDims', plotDims, ...
                              'AggregateDims', false, 'SplitLegend', true, ...
                              'Statistic', @median, 'AggregateFuns', true);

%% Restricted parameter comparison: 0.05, 0.1, 0.2. 0.4
% Aggregation of function values across dimensions 2, 3, 5, 10, 20.

% data = {sd2Data_05, ...
%         sd2Data_10, ...
%         sd2Data_20, ...
%         sd2Data_40, ...
%         saacmesData, ...
%         cmaesData};
% 
% datanames = {'0.05', '0.1', '0.2', '0.4', 'saACMES', 'CMA-ES'};
% 
% colors = [sd2Col_05; sd2Col_10; sd2Col_20; sd2Col_40; saacmesCol; cmaesCol]/255;
% 
% plotDims = [2, 3, 5, 10, 20];
% 
% for f = funcSet.BBfunc
% 
%   %% 
%   close all
% 
%   fprintf('Function %d\n', f)
%   han = relativeFValuesPlot(data, ...
%                               'DataNames', datanames, 'DataDims', funcSet.dims, ...
%                               'DataFuns', funcSet.BBfunc, 'Colors', colors, ...
%                               'PlotFuns', f, 'PlotDims', plotDims, ...
%                               'AggregateDims', true, 'SplitLegend', true, ...
%                               'Statistic', @median, 'AggregateFuns', false);
% end
% %%
% close all
% han = relativeFValuesPlot(data, ...
%                               'DataNames', datanames, 'DataDims', funcSet.dims, ...
%                               'DataFuns', funcSet.BBfunc, 'Colors', colors, ...
%                               'PlotFuns', funcSet.BBfunc, 'PlotDims', plotDims, ...
%                               'AggregateDims', false, 'SplitLegend', true, ...
%                               'Statistic', @median, 'AggregateFuns', true);


%% Population size comparison: default, 2*default
% Aggregation of function values across dimensions 2, 3, 5, 10, 20.

data = {sd2Data_05, ...
        sd2Data_10, ...
        sd2Data_20, ...
        sd2Data_40, ...
        sd2Data_05_2pop, ...
        sd2Data_10_2pop, ...
        sd2Data_20_2pop, ...
        sd2Data_40_2pop, ...
        cmaesData};

datanames = {'0.05 1pop', '0.1  1pop', '0.2  1pop', '0.4  1pop', ...
             '0.05 2pop', '0.1  2pop', '0.2  2pop', '0.4  2pop', ...
             'CMA-ES'};

colors = [sd2Col_05; sd2Col_10; sd2Col_20; sd2Col_40; ...
          sd2Col_05_2pop; sd2Col_10_2pop; sd2Col_20_2pop; sd2Col_40_2pop; ...
          cmaesCol]/255;

plotDims = [2, 3, 5, 10, 20];

for f = funcSet.BBfunc

  %% 
  close all

  fprintf('Function %d\n', f)
  han = relativeFValuesPlot(data, ...
                              'DataNames', datanames, 'DataDims', funcSet.dims, ...
                              'DataFuns', funcSet.BBfunc, 'Colors', colors, ...
                              'PlotFuns', f, 'PlotDims', plotDims, ...
                              'AggregateDims', true,...
                              'Statistic', @median, 'AggregateFuns', false);
end
%%
close all
han = relativeFValuesPlot(data, ...
                              'DataNames', datanames, 'DataDims', funcSet.dims, ...
                              'DataFuns', funcSet.BBfunc, 'Colors', colors, ...
                              'PlotFuns', funcSet.BBfunc, 'PlotDims', plotDims, ...
                              'AggregateDims', false, 'SplitLegend', true, ...
                              'Statistic', @median, 'AggregateFuns', true);


%% Algorithm comparison: DTS-CMA-ES, S-CMA-ES, saACMES, SMAC, CMA-ES
% Aggregation of function values across dimensions 2, 3, 5, 10, 20.

data = {sd2Data_10, ...
        sd2Data_05_2pop, ...
        genData, ...
        saacmesData, ...
        smacData, ...
        cmaesData};


datanames = {'DTS 0.1  1pop', 'DTS 0.05 2pop', 'S-CMA-ES', 'BIPOP-{}^{s*}ACMES-k', 'SMAC', 'CMA-ES'};

colors = [sd2Col_10; sd2Col_05_2pop; genCol; saacmesCol; smacCol; cmaesCol]/255;

plotDims = [2, 3, 5, 10, 20];

for f = funcSet.BBfunc

  %% 
  close all

  fprintf('Function %d\n', f)
  han = relativeFValuesPlot(data, ...
                              'DataNames', datanames, 'DataDims', funcSet.dims, ...
                              'DataFuns', funcSet.BBfunc, 'Colors', colors, ...
                              'PlotFuns', f, 'PlotDims', plotDims, ...
                              'AggregateDims', false, 'SplitLegend', true, ...
                              'Statistic', @median, 'AggregateFuns', false);
end
% %%
% close all
% han = relativeFValuesPlot(data, ...
%                               'DataNames', datanames, 'DataDims', funcSet.dims, ...
%                               'DataFuns', funcSet.BBfunc, 'Colors', colors, ...
%                               'PlotFuns', funcSet.BBfunc, 'PlotDims', plotDims, ...
%                               'AggregateDims', false,...
%                               'Statistic', @median, 'AggregateFuns', true);



%% EI, PoI, lcb, sd2: f-values comparison

% data = {eiData, ...
%         poiData, ...
%         lcbData, ...
%         sd2Data_10, ...
%         cmaesData};
% 
% datanames = {'EI', 'poi', 'lcb', 'sd2', 'CMA-ES'};
% 
% colors = [eiCol; poiCol; lcbCol; sd2Col; cmaesCol]/255;
% 
% defTargets = floor(power(20,linspace(1,log(250)/log(20),25)));
% 
% for d = funcSet.dims
%   for f = funcSet.BBfunc
%     
%     %% 
%     close all
%     
%     fprintf('Function %d, dimension %d\n', f, d)
%     fValuesPlot(data, 'DataNames', datanames, 'DataDims', funcSet.dims, ...
%                         'DataFuns', funcSet.BBfunc, 'Colors', colors, ...
%                         'PlotFuns', f, 'PlotDims', d, ...
%                         'Statistic', 'median', 'AggregateDims', false, ...
%                         'Dependency', 'alg');
%                       
%     reverseDistributionPlot(data, ...
%                               'DataNames', datanames, 'DataDims', funcSet.dims, ...
%                               'DataFuns', funcSet.BBfunc, 'Colors', colors, ...
%                               'PlotFuns', f, 'PlotDims', d, ...
%                               'DefaultTargets', defTargets, 'AggregateDims', false);
%   end
% end

%% EI, PoI, lcb, sd2: f-values comparison
% 
% close all
% 
% data = {eiData, ...
%         poiData, ...
%         lcbData, ...
%         sd2Data_10, ...
%         cmaesData};
% 
% datanames = {'EI', 'poi', 'lcb', 'sd2', 'CMA-ES'};
% 
% colors = [eiCol; poiCol; lcbCol; sd2Col; cmaesCol]/255;
% 
% % for i = 1:length(funcSet.BBfunc)
% %   pdfNames{i} = fullfile(plotResultsFolder, ['f', num2str(funcSet.BBfunc(i))]);
% % end
% 
% han = fValuesPlot(data, 'DataNames', datanames, 'DataDims', funcSet.dims, ...
%                         'DataFuns', funcSet.BBfunc, 'Colors', colors, ...
%                         'Statistic', 'median', 'AggregateDims', false, ...
%                         'Dependency', 'alg');
% %   print2pdf(han, pdfNames, 1)
% 

%% Algorithm comparison: DTS-CMA-ES, S-CMA-ES, saACMES, SMAC, CMA-ES
% Aggregation of function values across dimensions 2, 3, 5, 10, 20.

% close all
% 
% data = {sd2Data_10, ...
%         genData, ...
%         saacmesData, ...
%         smacData, ...
%         cmaesData};
% 
% datanames = {'DTS-CMA-ES', 'S-CMA-ES', 'saACMES', 'SMAC', 'CMA-ES'};
% 
% colors = [sd2Col; genCol; saacmesCol; smacCol; cmaesCol]/255;
% 
% plotFunc = 1:4;
% plotDims = [3 20];
%       
% han = relativeFValuesPlot(data, ...
%                               'DataNames', datanames, 'DataDims', funcSet.dims, ...
%                               'DataFuns', funcSet.BBfunc, 'Colors', colors, ...
%                               'PlotFuns', plotFunc, 'PlotDims', plotDims,...
%                               'DefaultTargets', 10*(1:25), 'AggregateDims', false,...
%                               'Statistic', @median, 'AggregateFuns', false);
%                             
% han = relativeFValuesPlot(data, ...
%                               'DataNames', datanames, 'DataDims', funcSet.dims, ...
%                               'DataFuns', funcSet.BBfunc, 'Colors', colors, ...
%                               'PlotFuns', plotFunc, 'PlotDims', plotDims,...
%                               'DefaultTargets', 10*(1:25), 'AggregateDims', false,...
%                               'Statistic', @median, 'AggregateFuns', true);

%% final clearing
close all
