% create all params
i=1;

% dimension \in {5, 10, 20}  3
P(i).name = 'dimensions';
P(i).values = {2};% {5 10 20}; %{2 5 10 20};
i = i + 1;

% function \in {1, 2, ?, 24}  24
P(i).name = 'functions';
P(i).values = num2cell(1:24);
i = i + 1;

% covariance function \in {SEiso, Matern3iso, Matern5iso, ARD versions}  3+3
P(i).name = 'covfun';
P(i).values = {
    struct('name', 'SEiso', 'params', {
        struct('sn', 0.05)
        struct('sn', 0.1)
        struct('sn', 0.25)
        struct('sn', 0.5)
        struct('sn', 1)
    })
    struct('name', 'Matern3iso', 'params', {
        struct('sn', 0.05)
        struct('sn', 0.1)
        struct('sn', 0.25)
        struct('sn', 0.5)
        struct('sn', 1)
    })
    struct('name', 'Matern5iso', 'params', {
        struct('sn', 0.05)
        struct('sn', 0.1)
        struct('sn', 0.25)
        struct('sn', 0.5)
        struct('sn', 1)
    })
    struct('name', 'SEard', 'params', {
        struct('sn', 0.05)
        struct('sn', 0.1)
        struct('sn', 0.25)
        struct('sn', 0.5)
        struct('sn', 1)
    })
    struct('name', 'Matern3ard', 'params', {
        struct('sn', 0.05)
        struct('sn', 0.1)
        struct('sn', 0.25)
        struct('sn', 0.5)
        struct('sn', 1)
    })
    struct('name', 'Matern5ard', 'params', {
        struct('sn', 0.05)
        struct('sn', 0.1)
        struct('sn', 0.25)
        struct('sn', 0.5)
        struct('sn', 1)
    })
};
i = i + 1;

% starting values of hyperparameters ? 5 different value-set for each cov. function  5
P(i).name = 'covhyp';
P(i).values = {1 2 3 4 5};
i = i + 1;

% lower/upper bounds on hyperparameters ? how to set this?  1
%P(i).name = 'covhyp_limit';
%P(i).values = {0}; %{0, 1}; %TODO: Implement
%i = i + 1;

% mean function ? {fixed as mean from dataset (@meanZero), trained as a hyperparameter (@meanConst)}  2
P(i).name = 'cov_trainMean';
P(i).values = {0}; %{0, 1}; %TODO: Implement
i = i + 1;

% run the fitting and testing in different phases of the algorithm progress
P(i).name = 'gen';
P(i).values = {20, 40, 100, 200};
i = i + 1;

% number of training data {5*dim, 10*dim, 20*dim, 40*dim}  4
P(i).name = 'numtrains';
P(i).values = {5, 10, 20, 40};
i = i + 1;

% training range ? multiplicator of \sigma^2 * C \in {2, 4, 8, 12, 16}  5
P(i).name = 'trainrange';
P(i).values = {2, 4, 8, 12, 16};
i = i + 1;

% clustering ? ? choose only the specif. number of the training data from the training range (clustering), or use all of them (no clustering)? ? {yes, no}  2
P(i).name = 'clustertrain';
P(i).values = {0}; %{0, 1}; %TODO: Implement
i = i + 1;

% testing dataset from generation \in {+1, +5}  2
P(i).name = 'testgen';
P(i).values = {1 5};
i = i + 1;

% algorithm \in {minimize(), fmincon(), CMA-ES}  3
P(i).name = 'optalg';
P(i).values = {'minimize'}; %{'minimize', 'fmincon', 'cmaes'}; %TODO: Implement
i = i + 1;

