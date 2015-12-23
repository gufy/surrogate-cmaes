function [params] = cp_get_params_from_index(id, all)
% GETPARAMSFROMINDEX Generates struct arrays with parameters accrd. to exper. ID#
  nValues = cell2mat(structMap(all, @(x) length(x.values)));
  nParams = length(nValues);
  totalCombs = prod(nValues);

  assert(id <= totalCombs && id > 0, 'cp_get_params_from_index(): the specified index is greater than total # combinations.');

  orders = size(nValues);
  for i = 1:nParams
    orders(i) = prod(nValues(i:end));
  end
  % orders =  [540   180    60    60    60    30    10    10    10     2];
  % nValues =   [3     3     1     1     2     3     1     1     5     2];
  orders = [orders 1];

  x = id-1;
  i = 1;

  % vector of integer-parameter-values:
  paramIDs = zeros(size(nValues));

  while (x >= 0 && i <= nParams)
    div = floor(x / orders(i+1));
    paramIDs(i) = div + 1;
    x = mod(x, orders(i+1));
    i = i + 1;
  end

  % parameters
  params = struct();
  for i = 1:length(all)
    params.(all(i).name) = all(i).values{paramIDs(i)};
  end

end
