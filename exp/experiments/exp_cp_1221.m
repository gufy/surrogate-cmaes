paths_to_project = '/storage/plzen1/home/goophy/cmaes';
exp_load_eval_params;

totalComb = cp_get_total_comb_of_params(P);
batchSize = 500;

for I = 1:batchSize:totalComb 
    p = cp_get_params_from_indices(I:(I+batchSize - 1), P);
    cp_eval_batch(p, paths_to_project);
end
