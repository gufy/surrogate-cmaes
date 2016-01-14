function [ res ] = cp_eval_exp_and_save( params, exppath_short )

if nargin < 2
    exppath_short = '.';
end

err = 0;
err_report = '';

tic;
try
	res = cp_eval_exp(params, exppath_short);
catch e
	res = struct();
	err = 1;
	err_report = getReport(e);
end
t = toc;

% and save

params.time = t;

if err
	params.error = 1;
	params.error_msg = err_report;
else
	params.mse = res.err;
	params.info = res.info;
	params.mse_all = mat2str(res.errors);
    params.kendall = res.kendall;
    params.kendall_all = mat2str(res.kendalls);
end

paramstr = cp_struct2str(params, '&');

url = ['http://vojtechkopal.cz/regressions/save.php?', paramstr];
sent = 0;
numtry = 1;

while sent == 0
try
	%urlread(url);    
    if err
        display(err_report);
    end
	sent = 1;
catch e
	if numtry < 5
		display(['Faild to save result: ', url]);
        display('Trying again ...');
		pause(2^(numtry-1));
		numtry = numtry + 1;
	else
		m = ['Cannot save result: ', url];
		if err
			m = [ m , ' ', err_report ] ; 
		end
		error(m);
	end
end
end

end

