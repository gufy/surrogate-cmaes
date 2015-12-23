function [ params ] = cp_prepare_exp_params( params )

i = params.covhyp;
params.covhyp = params.covfun(i).params;
params.covfun = params.covfun(i).name;

end
