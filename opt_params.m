dim = [ 5 5 5 10 10 10 20 20 20 20 ];
gen = [ 20 40 100 20 40 100 20 40 100 200 ];
numtrains = [ 5 5 10 5 5 20 5 5 10 40 ];
trainrange = [ 2 4 12 2 4 4 2 2 2 8 ];

%%

mdl = fitlm([dim; gen]', numtrains);
y = max(5, ceil([ones(1, length(dim)); dim; gen]' * mdl.Coefficients.Estimate))
mdl.Coefficients.Estimate

%%

mdl = fitlm([dim; gen]', trainrange, 'y ~ x1 + x2 + x1*x2 + x2^2')
y = max(2, ceil([ones(1, length(dim)); dim; gen; dim .* gen; gen .* gen]' * mdl.Coefficients.Estimate))
mdl.Coefficients.Estimate