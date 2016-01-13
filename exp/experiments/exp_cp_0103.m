paths_to_project = '/Users/vojta/Documents/MATLAB/regression-models';
exp_load_eval_params;

%%

exppath_short = paths_to_project;

%%

totalComb = cp_get_total_comb_of_params(P);
batchSize = 500;

for I = 1:batchSize:totalComb 
    display(['Running task: ', int2str(I), '/', int2str(totalComb)]);
    p = cp_get_params_from_indices(I:min(I+batchSize - 1, totalComb), P);
    cp_eval_batch(p, paths_to_project);
end
