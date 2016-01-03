paths_to_project = '/storage/plzen1/home/goophy/cmaes';
exp_load_eval_params;

%%

exppath_short = paths_to_project;
walltime = '4h';
 
pbs_max_workers = 50;
pbs_params = ['-l walltime=' walltime ',nodes=^N^:ppn=1,mem=1gb,scratch=1gb,matlab_MATLAB_Distrib_Comp_Engine=^N^'];

while 1
    [tf msg] = license('checkout','Distrib_Computing_Toolbox');
    if tf==1, break, end
    display(strcat(datestr(now),' waiting for licence '));
    pause(4);
end

cl = parallel.cluster.Torque;
pause(2);
[~, ~] = mkdir(exppath_short, '../matlab_jobs')
cl.JobStorageLocation = [exppath_short filesep '../matlab_jobs'];
cl.ClusterMatlabRoot = matlabroot;
cl.OperatingSystem = 'unix';
cl.ResourceTemplate = pbs_params;
cl.HasSharedFilesystem = true;
cl.NumWorkers = pbs_max_workers;

display('Creating job');
job = createJob(cl);

%%

totalComb = cp_get_total_comb_of_params(P);
batchSize = 500;

for I = 1:batchSize:totalComb 
    display(['Creating task: ', int2str(I), '/', int2str(totalComb)]);
    p = cp_get_params_from_indices(I:min(I+batchSize - 1, totalComb), P);
	createTask(job, @cp_eval_batch, 0, {p, paths_to_project});
end

submit(job);
