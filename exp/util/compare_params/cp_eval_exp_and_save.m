function [ res ] = cp_eval_exp_and_save( params, exppath_short )

if nargin < 2
    exppath_short = '.';
end

tic;
res = cp_eval_exp(params, exppath_short);
t = toc;

% and save

params.mse = res.err;
params.info = res.info;
params.mse_all = mat2str(res.errors);
params.time = t;
paramstr = cp_struct2str(params, '&');

url = ['http://vojtechkopal.cz/regressions/save.php?', paramstr];
urlread(url);    

end

