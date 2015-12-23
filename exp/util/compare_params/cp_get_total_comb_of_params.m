function [totalCombs] = cp_get_params_from_index(all)

  nValues = cell2mat(structMap(all, @(x) length(x.values)));
  totalCombs = prod(nValues);

end
