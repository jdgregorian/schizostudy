function metacentrum_runExperiment(expname, walltime, taskIDs, reqMemory)
% metacentrum_runExperiment(expname, walltime, taskIDs) runs tasks 
% 'taskIDs' from experiment 'expname' with Metacentrum walltime 
% 'walltime' and required memory 'memory'.
%
% Input:
%   expname  - name of the experiment | string
%   walltime - maximum (wall)time for Metacentrum machines | string
%              ('4h', '1d', '2d', ...)
%   taskIDs  - vector of task numbers to run | integer or [] to run all 
%              instances
%   reqMemory   - required memory for experiment on Metacentrum | string
%              ('500mb', '1gb', '4gb', ...)
%
% See Also:
%   runExperiment, metacentrum_task, createExperiment

  % initialization
  if nargin < 4
    reqMemory = '2gb';
    if nargin < 3
      taskIDs = [];
      if nargin < 2
        walltime = '4h';
        if nargin < 1
          help metacentrum_runExperiment
          return
        end
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
  nLoadedTasks = length(settings);
  if isempty(taskIDs)
    taskIDs = 1:nLoadedTasks;
  elseif any(strcmp(taskIDs, {'missing', 'miss'}))
    resultNames = cellfun(@eval, resultNames, 'UniformOutput', false);
    taskIDs = find(updateTaskList(foldername, resultNames));
  else
    taskIDs(taskIDs > nLoadedTasks) = [];
  end
  nTasks = length(taskIDs);
  
  % metacentrum settings
  pbs_max_workers = 50;
  pbs_params = ['-l walltime=', walltime, ',nodes=^N^:ppn=1,mem=', reqMemory, ',scratch=1gb,matlab_MATLAB_Distrib_Comp_Engine=^N^'];

  % licence loop
  while 1
    [tf, ~] = license('checkout', 'Distrib_Computing_Toolbox');
    if tf == 1
      break
    end
    display(strcat(datestr(now), ' waiting for licence '));
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
  for t = 1:nTasks
    id = taskIDs(t);
    fprintf('Setting up job ID %d / %d ...\n', id, nLoadedTasks);
    tasks(t) = createTask(job, @metacentrum_task, 0, {expname, id, settings{id}});
  end

  tasks

  % submit job
  submit(job)
  
end