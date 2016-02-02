data = cp_query(struct('trainrange', 2, 'testgen', 1, 'numtrains', 5, 'transformCoordinates', 1));

%%

covfuns = unique(data.covfun);
funs = unique(data.fun);
gens = unique(data.gen);
wins = zeros(length(gens), length(funs));

counter = 0;
clear results;

for F = 1:length(funs)
    fun = funs(F);
    idfx = data.fun == fun;
    
    for K = 1:length(gens)
        gen = gens(K);
        idgx = idfx & (data.gen == gen);
        
        opt_covhyp = '';
        opt_covfun = '';
        opt_mse = 2^31; % huge number
        
        for I = 1:length(covfuns)
            covfun = covfuns{I};
            idcx = idgx & strcmp(data.covfun, covfun);
            covhyps = unique(data.covhyp(idcx));
            
            for J = 1:length(covhyps)
                covhyp = covhyps{J};
                idhx = idcx & strcmp(data.covhyp, covhyp);

                x = data.fun(idhx);
                y = data.mse(idhx);

                if y < opt_mse
                    opt_mse = y;
                    opt_covfun = covfun;
                    opt_covhyp = covhyp;
                end
                
                %[ys, id] = sort(y);
                %xs = x(id);
                %[ys(1:3), xs(1:3)]
                %wins(gens == gen, funs == xs(1)) = wins(gens == gen, funs == xs(1)) + 1;
            end
        end
        
        counter = counter + 1;
        results(counter).fun = fun;
        results(counter).gen = gen;
        results(counter).mse = opt_mse;
        results(counter).covhyp = opt_covhyp;
        results(counter).covfun = opt_covfun;
    end
end

results = struct2table(results);

%%

gens = unique(results.gen);
for I = 1:length(gens)
    gen = gens(I);
    idx = results.gen == gen;
    
    display(['Results for gen=', int2str(gen)]);
    display(results(idx, :));
end