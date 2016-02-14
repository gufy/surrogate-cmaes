function [ res ] = cp_eval_exp( params, exppath_short )

if nargin < 2
    exppath_short = '.';
end

fprintf('Running evaluation: fun=%d, dim=%d, gen=%d, numtrains=%d, trainrange=%d\n', ...
    params.fun, params.dim, params.gen, params.numtrains, params.trainrange );
d = dir([exppath_short, '/exp_data/', 'exp_cmaeslog1_purecmaes_', int2str(params.fun), '_', int2str(params.dim), 'D_*']);
load([exppath_short, '/exp_data/', d.name]);

info = '';
ErrAcc = 0;
Errs = zeros(1,30);
KendallAcc = 0;
Kendalls = zeros(1,30);
TrainN = zeros(1,30);
TestN = zeros(1,30);

for ExpId = 1:30
    try
        CmaesOut = cmaes_out{ExpId};
        G = params.gen;
        NumTrain = params.numtrains * params.dim;

        if G > length(CmaesOut.generationStarts)
            % error, nemame dost generaci
            info = 'Too Fast';
            Errs(ExpId) = NaN;
        else
            Arch = cp_init_archive(CmaesOut);
            TrainRange = params.trainrange * CmaesOut.sigmas(G)^2;
            M = CmaesOut.means(:, G);

            [X, Y] = Arch.getDataNearPoint(NumTrain, ...
                CmaesOut.means(:, G)', TrainRange, CmaesOut.sigmas(G), CmaesOut.BDs{G}, ...
                1:G );

            if isempty(Y)
                error(['Cannot train against empty set. Loaded empty set from archive for ', cp_struct2str(params)]);
            end

            X = X - repmat(mean(X,1)', 1, length(Y))';
            model = GpModel(params, zeros(1, params.dim));

            [Xtest, Dtest] = Arch.getDataFromGenerations(G + params.testgen);

            if isempty(Dtest)
                error(['Cannot test against future generation. Loaded empty set from archive for ', cp_struct2str(params)]);
            end

            model = model.train(X, Y, CmaesOut.means(:, G)', G, CmaesOut.sigmas(G), CmaesOut.BDs{G});
            Ytest = model.predict(Xtest);

            kendall = corr(Dtest, Ytest, 'type', 'Kendall');
            
            if isnan(kendall)
                kendall = 0;
            end
            
            Err = (1/length(Dtest))*(sum((Dtest - Ytest).^2));
            Errs(ExpId) = Err;
            Kendalls(ExpId) = kendall;
            ErrAcc = ErrAcc + Err;
            KendallAcc = KendallAcc + kendall;
            TrainN(ExpId) = length(Y);
            TestN(ExpId) = length(Ytest);
        end
    catch e
        
    end
end

NumSucc = sum(Errs > 0);
AvgErr = 0;
AvgKendall = 0;
if ErrAcc > 0
    AvgErr = ErrAcc/NumSucc;
    AvgKendall = KendallAcc/NumSucc;
end

res = struct('err', AvgErr, 'errors', Errs, 'kendall', AvgKendall, 'kendalls', Kendalls, 'info', info, ...
            'test_n', TestN, 'train_n', TrainN);

end

