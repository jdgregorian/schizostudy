function metacentrum_runExperiment2(expname, walltime, numOfMachines)
% metacentrum_runExperiment2(expname, walltime, numOfMachines) runs not 
% finished or not running tasks from experiment 'expname' on 
% 'numOfMachines' machines with Metacentrum walltime 'walltime'.
%
% NOT FUNCTIONAL
%
% Input:
%   expname  - name of the experiment | string
%   walltime - maximum (wall)time for Metacentrum machines | string
%              ('4h', '1d', '2d', ...)
%   taskIDs  - vector of task numbers to run | integer or [] to run all 
%              instances
%   numOfMachines - number of machines in Metacentrum | integer
%
% See Also:
%   metacentrum_runExperiment, runExperiment, createExperiment

  % initialization
  if nargin < 3
    numOfMachines = 10;
    if nargin < 2
      walltime = '4h';
      if nargin < 1
        help metacentrum_runExperiment
        return
      end
    end
  end
  
  metafolder = [filesep, fullfile('storage', 'plzen1', 'home', getenv('LOGNAME'), 'prg', 'schizostudy')];
  expfolder = fullfile('exp', 'experiments');
  foldername = fullfile(expfolder, expname);
  scriptname = fullfile(foldername, [expname, '_runscript.m']);

  % if experiment was not created yet
  if ~isdir(foldername) || ~exist(scriptname, 'file')
    metacentrum_createExperiment(foldername, expfolder, metafolder)
    fprintf('Experiment created\n')
  end
  
  % load individual settings
  [settings, resultNames] = loadSettings({scriptname});
  
  % metacentrum settings
  pbs_max_workers = 50;
  pbs_params = ['-l walltime=', walltime, ',nodes=^N^:ppn=1,mem=2gb,scratch=1gb,matlab_MATLAB_Distrib_Comp_Engine=^N^'];

  % licence loop
  while 1
    [tf, ~] = license('checkout', 'Distrib_Computing_Toolbox');
    if tf == 1
      break
    end
    display(strcat(datestr(now),' waiting for licence '));
    pause(4);
  end

  % job settings
  cl = parallel.cluster.Torque;
  pause(2);
  if ~isdir(fullfile(foldername, 'matlab_jobs'))
    mkdir(fullfile(foldername, 'matlab_jobs'))
  end
  cl.JobStorageLocation = fullfile(foldername, 'matlab_jobs');
  cl.ClusterMatlabRoot = matlabroot;
  cl.OperatingSystem = 'unix';
  cl.ResourceTemplate = pbs_params;
  cl.HasSharedFilesystem = true;
  cl.NumWorkers = pbs_max_workers;

  job = createJob(cl);

  % tasks creating
  for id = 1:numOfMachines
    fprintf('Setting up job ID %d / %d ...\n', id, numOfMachines);
    tasks(id) = createTask(job, @metacentrum_task2, 0, {expname, id, settings, resultNames});
  end

  tasks

  % submit job
  submit(job)
  
end
