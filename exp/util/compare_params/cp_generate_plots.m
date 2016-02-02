%%

cp_load_results;

%%

idx = data.mse > 0;
scatter(data.covhyp(idx & data.fun == 1), data.mse(idx & data.fun == 1))