function [ X, Y ] = cp_load_archive( conds, cmaes_out, limitPars )

Cond = conds(cmaes_out);

if nargin > 2
    % limit data based on distance to the mean
    Cond = Cond & (limitPars.range > sqrt(sum((cmaes_out.arxvalids - repmat(limitPars.m, 1, length(cmaes_out.arxvalids)))).^2));
end

X = cmaes_out.arxvalids(:, Cond);
Y = cmaes_out.fvalues(Cond);

if nargin > 2 && limitPars.num > 0 && length(Y) > limitPars.num
    % Limit the number of selected
    len = length(Y); k = limitPars.num;
    perm = randperm(len);
    indices = perm <= k;
    X = X(:, indices);
    Y = Y(indices);
end

end

