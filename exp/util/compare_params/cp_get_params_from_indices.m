function [params] = cp_get_params_from_indices(ids, all)
    params = {};
    for I = 1:length(ids)
        params{I} = cp_get_params_from_index(ids(I), all);
    end
end
