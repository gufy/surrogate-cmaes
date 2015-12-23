function [ res ] = cp_eval_batch( arr_of_params, exppath_short )

if nargin < 2
    exppath_short = '.';
end

setup_mail;
%sendmail('vojtech.kopal@gmail.com', 'MATLAB Batch Started', 'Computation has started.');

try
	res = {};
	for I = 1:length(arr_of_params)
    	display(I);
		params = arr_of_params{I};
    	params = cp_prepare_exp_params(params);
        params.transformCoordinates = false;
		res{I} = cp_eval_exp_and_save(params, exppath_short);
	end
catch e
    	try
            getReport(e)
            sendmail('vojtech.kopal@gmail.com', 'MATLAB Error', getReport(e));
        catch e
        end
end

end

