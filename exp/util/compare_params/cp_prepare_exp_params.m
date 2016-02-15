function [ params ] = cp_prepare_exp_params( params )

i = params.covhyp;
params.hyp = params.covfun(i).params;
params.covFcn = params.covfun(i).name;

if params.covfun(i).isARD
  if isfield(params.hyp, 'cov')
      params.hyp.cov = [params.hyp.cov(1) repmat(params.hyp.cov(2), 1, params.dim)];
  end
end

params = rmfield(params, 'covfun');
params = rmfield(params, 'covhyp');

end
