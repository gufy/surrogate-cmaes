function [xbest, fmin, counteval, stopflag, y_eval] = adaptive(fitfun, xstart, gpopOpts, cmOpts, modelOpts, cmOptions, sgParams)
%
% uses gpop and s_cmaes


if isfield(gpopOpts, 'maxFunEvals') 
    gpopOpts.maxFunEvals = gpopOpts.maxFunEvals / 5;
end

if isfield(gpopOpts, 'maxIter') 
    gpopOpts.maxIter = gpopOpts.maxIter / 5;
end

[xbest, fmin, counteval, stopflag, y_eval, model] = gpop(fitfun, xstart, gpopOpts, cmOpts, modelOpts);

display('*******');
display('*******');

display(['Result: ', mat2str(xbest), '=', num2str(fmin)]);

display('*******');
display('*******');

%sgParams.modelType = model;
%save('gpModel.mat', 'model');

sigma = 8/3;
fun = @(x) model.modelPredict(x');
sgParams.modelType = 'gp';
sgParams.warmup = struct('numGenerations', 5, 'fun', fun);

[xbest, fmin, counteval2, stopflag, out, bestever, y_eval] = s_cmaes('fgeneric', xbest, sigma, cmOpts, 'SurrogateOptions', sgParams);

counteval = counteval + counteval2

end

