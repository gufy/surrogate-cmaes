function [ res ] = cp_eval_exp( params, exppath_short )

if nargin < 2
    exppath_short = '.';
end

fprintf('Running evaluation: dim=%d, gen=%d, numtrains=%d, trainrange=%d\n', ...
    params.dimensions, params.gen, params.numtrains, params.trainrange );
d = dir([exppath_short, '/exp_data/', 'exp_cmaeslog1_purecmaes_', int2str(params.functions), '_', int2str(params.dimensions), 'D_*']);
load([exppath_short, '/exp_data/', d.name]);

info = '';
ErrAcc = 0;
Errs = zeros(1,30);
for ExpId = 1:30
    CmaesOut = cmaes_out{ExpId};
    G = params.gen;
    NumTrain = params.numtrains * params.dimensions;
    
    if G > length(CmaesOut.generationStarts)
        % error, nemame dost generaci
        info = 'Too Fast';
        Errs(ExpId) = NaN;
    else
        TrainRange = params.trainrange * CmaesOut.sigmas(G)^2;
        M = CmaesOut.means(:, G);

        [X, Y] = cp_load_archive(@(x) (x.generations <= G), CmaesOut, ...
            struct('m', M, 'range', TrainRange, 'num', NumTrain));

        X = X - repmat(mean(X,2), 1, length(Y));
        model = GpModel(params, [0 0]);
        [Xtrain, Dtrain] = cp_load_archive(@(x) (x.generations == G + params.testgen), CmaesOut);
        model = model.train(Xtrain', Dtrain', 1, 1, 1, 1);

        Err = (1/length(Dtrain))*(sum((Dtrain - model.predict(Xtrain')').^2));
        Errs(ExpId) = Err;
        ErrAcc = ErrAcc + Err;
    end
end

res = struct('err', ErrAcc/30, 'errors', Errs, 'info', info);

end

